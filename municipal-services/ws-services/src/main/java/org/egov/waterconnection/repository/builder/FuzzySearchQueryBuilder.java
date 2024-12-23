
package org.egov.waterconnection.repository.builder;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.config.WSConfiguration;
import org.egov.waterconnection.web.models.SearchCriteria;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class FuzzySearchQueryBuilder {


    private ObjectMapper mapper;

    private WSConfiguration config;


    @Autowired
    public FuzzySearchQueryBuilder(ObjectMapper mapper, WSConfiguration config) {
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

    /**
     * Builds a elasticsearch search query based on the fuzzy search criteria
     * @param criteria
     * @return
     */
    public String getFuzzySearchQuery(SearchCriteria criteria, List<String> ids){

        String finalQuery;

        try {
            String baseQuery = addPagination(criteria);
            JsonNode node = mapper.readTree(baseQuery);
            ObjectNode insideMatch = (ObjectNode)node.get("query");
            List<JsonNode> fuzzyClauses = new LinkedList<>();

            if(StringUtils.isNotBlank(criteria.getName())){
                fuzzyClauses.add(getInnerNode(criteria.getName(),"Data.connectionHolders.name",config.getNameFuziness()));
            }
            if(StringUtils.isNotBlank(criteria.getMobileNumber())) {
            	fuzzyClauses.add(getInnerNode(criteria.getMobileNumber(),"Data.connectionHolders.mobileNumber",config.getMobileNoFuziness()));
            }
            if(StringUtils.isNotBlank(criteria.getTextSearch())) {
            	fuzzyClauses.add(getInnerNode(criteria.getTextSearch(),"Data.connectionHolders.name" , config.getNameFuziness()));
            }
            
            if(StringUtils.isNotBlank(criteria.getTenantId())) {
            	fuzzyClauses.add(getInnerNode(criteria.getTenantId(),"Data.tenantId.keyword" , config.getTenantFuziness()));
            }
            
            JsonNode mustNode = mapper.convertValue(new HashMap<String, List<JsonNode>>(){{put("must",fuzzyClauses);}}, JsonNode.class);

            insideMatch.put("bool",mustNode);
            ObjectNode boolNode = (ObjectNode)insideMatch.get("bool");


            if(!CollectionUtils.isEmpty(ids)){
                JsonNode jsonNode = mapper.convertValue(new HashMap<String, List<String>>(){{put("Data.id.keyword",ids);}}, JsonNode.class);
                ObjectNode parentNode = mapper.createObjectNode();
                parentNode.put("terms",jsonNode);
                boolNode.put("filter", parentNode);
            }

            finalQuery = mapper.writeValueAsString(node);

        }
        catch (Exception e){
            log.error("ES_ERROR",e);
            throw new CustomException("JSONNODE_ERROR","Failed to build json query for fuzzy search");
        }

        return finalQuery;

    }


    /**
     * Creates inner query using the query template
     * @param param
     * @param var
     * @param fuziness
     * @return
     * @throws JsonProcessingException
     */
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


    private String addPagination(SearchCriteria criteria) {
    	
        Long limit = config.getDefaultLimit().longValue();
        Long offset = config.getDefaultOffset().longValue();

        if (criteria.getLimit() != null && criteria.getLimit() <= config.getMaxLimit().longValue())
            limit = criteria.getLimit().longValue();

        if (criteria.getLimit() != null && criteria.getLimit() > config.getMaxLimit().longValue())
            limit = config.getMaxLimit().longValue();

        if (criteria.getOffset() != null)
            offset = criteria.getOffset().longValue();

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
