package org.egov.hrms.repository;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import lombok.extern.slf4j.Slf4j;
import org.egov.hrms.config.PropertiesManager;
import org.egov.hrms.web.contract.EmployeeSearchCriteria;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.util.CollectionUtils;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

@Repository
@Slf4j
public class FuzzySearchQueryBuilder {
    private ObjectMapper mapper;

    private PropertiesManager config;

    @Autowired
    public FuzzySearchQueryBuilder(ObjectMapper mapper, PropertiesManager config) {
        this.mapper = mapper;
        this.config = config;
    }

    private static final String BASE_QUERY = "{\n" +
            "  \"from\": {{OFFSET}},\n" +
            "  \"size\": {{LIMIT}},\n" +
            "  \"sort\": {\n" +
            "    \"_score\": {\n" +
            "      \"order\": \"desc\"\n" +
            "    }\n" +
            "  },\n" +
            "  \"query\": {\n" +
            "  }\n" +
            "}";

    private static final String fuzzyQueryTemplate = "{\n" +
            "          \"match\": {\n" +
            "            \"{{VAR}}\": {\n" +
            "              \"query\": \"{{PARAM}}\",\n" +
            "              \"fuzziness\": \"{{FUZZINESS}}\"\n" +
            "            }\n" +
            "          }\n" +
            "        }";

    private static final String wildCardQueryTemplate = "{\n" +
            "          \"query_string\": {\n" +
            "            \"default_field\": \"{{VAR}}\",\n" +
            "            \"query\": \"*{{PARAM}}*\"\n" +
            "          }\n" +
            "        }";

    private static final String filterTemplate   = "\"filter\": { " +
            "      }";

    public String getFuzzySearchQuery(EmployeeSearchCriteria criteria, List<String> ids){

        String finalQuery;

        try {
            // Generate base query with pagination
            String baseQuery = addPagination(criteria);
            JsonNode node = mapper.readTree(baseQuery);
            ObjectNode insideMatch = (ObjectNode)node.get("query");
            List<JsonNode> fuzzyClauses = new LinkedList<>();

            if(criteria.getName() != null){
                fuzzyClauses.add(getInnerNode(criteria.getName(),"Data.user.name",config.getNameFuziness()));
            }

            // Create 'must' node with fuzzy clauses
            JsonNode mustNode = mapper.convertValue(new HashMap<String, List<JsonNode>>() {{
                put("must", fuzzyClauses);
            }}, JsonNode.class);

            insideMatch.put("bool", mustNode);
            ObjectNode boolNode = (ObjectNode) insideMatch.get("bool");

            // Add filter by IDs if the list is not empty
            if (!CollectionUtils.isEmpty(ids)) {
                JsonNode jsonNode = mapper.convertValue(new HashMap<String, List<String>>() {{
                    put("Data.id.keyword", ids);
                }}, JsonNode.class);
                ObjectNode parentNode = mapper.createObjectNode();
                parentNode.put("terms", jsonNode);
                boolNode.put("filter", parentNode);
            }

            // Add filter for tenantId
            if (criteria.getTenantId() != null) {
                if (criteria.getTenantIds() instanceof List) {
                    // Handle tenantId as a list
                    JsonNode tenantIdNode = mapper.convertValue(new HashMap<String, List<String>>() {{
                        put("Data.tenantId", (List<String>) criteria.getTenantIds());
                    }}, JsonNode.class);
                    ObjectNode tenantParentNode = mapper.createObjectNode();
                    tenantParentNode.put("terms", tenantIdNode);
                    boolNode.put("filter", tenantParentNode);
                } else{
                    // Handle tenantId as a single value
                    JsonNode tenantIdNode = mapper.convertValue(new HashMap<String, String>() {{
                        put("Data.tenantId", (String) criteria.getTenantId());
                    }}, JsonNode.class);
                    ObjectNode tenantParentNode = mapper.createObjectNode();
                    tenantParentNode.put("term", tenantIdNode);
                    boolNode.put("filter", tenantParentNode);
                }
            }

            if (criteria.getRoles()!=null) {
                // Create a "terms" filter for roles
                JsonNode rolesNode = mapper.convertValue(new HashMap<String, List<String>>() {{
                    put("Data.user.roles.code", criteria.getRoles());
                }}, JsonNode.class);
                ObjectNode rolesFilterNode = mapper.createObjectNode();
                rolesFilterNode.put("terms", rolesNode);
                boolNode.put("filter", rolesFilterNode);
            }

            // Convert the final JSON node back to a string
            finalQuery = mapper.writeValueAsString(node);
        } catch (Exception e) {
            log.error("ES_ERROR", e);
            throw new CustomException("JSONNODE_ERROR", "Failed to build json query for fuzzy search");
        }

        log.info("finalQuery {}",finalQuery);
        return finalQuery;
    }

    private JsonNode getInnerNode(String param, String var, String fuziness) throws JsonProcessingException {

        String template;
        if(config.getIsSearchWildcardBased())
            template = wildCardQueryTemplate;
        else
            template = fuzzyQueryTemplate;
        String innerQuery = template.replace("{{PARAM}}",getEscapedString(param));
        innerQuery = innerQuery.replace("{{VAR}}",var);

        if(!config.getIsSearchWildcardBased())
            innerQuery = innerQuery.replace("{{FUZZINESS}}", fuziness);

        JsonNode innerNode = mapper.readTree(innerQuery);
        return innerNode;
    }

    private String addPagination(EmployeeSearchCriteria criteria) {

        Long limit = config.getDefaultLimit();
        Long offset = config.getDefaultOffset();

        if (criteria.getLimit() != null && criteria.getLimit() <= config.getMaxSearchLimit())
            limit = criteria.getLimit();

        if (criteria.getLimit() != null && criteria.getLimit() > config.getMaxSearchLimit())
            limit = config.getMaxSearchLimit();

        if (criteria.getOffset() != null)
            offset = criteria.getOffset();

        String baseQuery = BASE_QUERY.replace("{{OFFSET}}", offset.toString());
        baseQuery = baseQuery.replace("{{LIMIT}}", limit.toString());

        return baseQuery;
    }

    /**
     * Escapes special characters in given string
     * @param inputString
     * @return
     */
    private String getEscapedString(String inputString){
        final String[] metaCharacters = {"\\","/","^","$","{","}","[","]","(",")",".","*","+","?","|","<",">","-","&","%"};
        for (int i = 0 ; i < metaCharacters.length ; i++) {
            if (inputString.contains(metaCharacters[i])) {
                inputString = inputString.replace(metaCharacters[i], "\\\\" + metaCharacters[i]);
            }
        }
        return inputString;
    }
}
