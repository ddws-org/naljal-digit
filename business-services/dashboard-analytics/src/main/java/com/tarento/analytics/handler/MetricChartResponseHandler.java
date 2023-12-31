package com.tarento.analytics.handler;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.amazonaws.event.DeliveryMode.Check;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.tarento.analytics.ConfigurationLoader;
import com.tarento.analytics.dto.AggregateDto;
import com.tarento.analytics.dto.AggregateRequestDto;
import com.tarento.analytics.dto.Data;
import com.tarento.analytics.helper.ComputeHelper;
import com.tarento.analytics.helper.ComputeHelperFactory;

import com.tarento.analytics.utils.ResponseRecorder;

/**
 * This handles ES response for single index, multiple index to represent single data value
 * Creates plots by merging/computing(by summation or by percentage) index values for same key
 * ACTION:  for the chart config defines the type either summation or computing percentage
 * AGGS_PATH : this defines the path/key to be used to search the tree
 *
 */
@Component
public class MetricChartResponseHandler implements IResponseHandler{
    public static final Logger logger = LoggerFactory.getLogger(MetricChartResponseHandler.class);
    
    char insightPrefix = 'i';

    @Autowired
    ConfigurationLoader configurationLoader;
    
    @Autowired 
    ComputeHelperFactory computeHelperFactory; 
    
    @Autowired
    ResponseRecorder responseRecorder;


    /**
     * Adds the data into ResponseResponder
     * @param request
     * @param aggregations
     * @return
     * @throws IOException
     */

    @Override
    public AggregateDto translate(AggregateRequestDto request, ObjectNode aggregations) throws IOException {
        List<Data> dataList = new ArrayList<>();
        String requestId = request.getRequestId(); 
        String visualizationCode = request.getVisualizationCode();

        JsonNode aggregationNode = aggregations.get(AGGREGATIONS);
        JsonNode chartNode = null; 

        // Fetches the chart config
        if(request.getVisualizationCode().charAt(0) == insightPrefix) { 
        	String internalChartId = request.getVisualizationCode().substring(1);
        	chartNode = configurationLoader.get(API_CONFIG_JSON).get(internalChartId);
        } else {
        	chartNode = configurationLoader.get(API_CONFIG_JSON).get(request.getVisualizationCode());
        }

        List<Double> totalValues = new ArrayList<>();
        String chartName = chartNode.get(CHART_NAME).asText();
        String action = chartNode.get(ACTION).asText();


        /*
        * Aggreagation paths are the name of aggregations
        * Could have been inferred from aggregationNode i.e from query Dont know why it was added in config?
        * */
        List<Double> percentageList = new ArrayList<>();
        ArrayNode aggrsPaths = (ArrayNode) chartNode.get(AGGS_PATH);

        /*
        * Sums all value of all aggrsPaths i.e all aggregations
        * */
       boolean isRoundOff = (chartNode.get(IS_ROUND_OFF)!=null && chartNode.get(IS_ROUND_OFF).asBoolean()) ? true : false;

		aggrsPaths.forEach(headerPath -> {
			List<JsonNode> values = aggregationNode.findValues(headerPath.asText());
			values.stream().parallel().forEach(value -> {
				if (isRoundOff) {
					ObjectMapper mapper = new ObjectMapper();
					JsonNode node = value.get("value");
					if(node != null) {
						Double roundOff = 0.0d;
						try {
							roundOff = mapper.treeToValue(node, Double.class);
						} catch (JsonProcessingException e) {
							e.printStackTrace();
						}
						if(roundOff!=null) {
							int finalvalue = (int) Math.round(roundOff);
							((ObjectNode) value).put("value", finalvalue);
						}
					}
					
				}
				List<JsonNode> valueNodes = value.findValues(VALUE).isEmpty() ? value.findValues(DOC_COUNT)
						: value.findValues(VALUE);
				Double sum = valueNodes.stream().mapToDouble(o -> o.asDouble()).sum();
				// Why is aggrsPaths.size()==2 required? Is there validation if action =
				// PERCENTAGE and aggrsPaths > 2
				if (action.equals(PERCENTAGE) && aggrsPaths.size() == 2) {
					percentageList.add(sum);
				} else {
					totalValues.add(sum);
				}
			});
		});

        String symbol = chartNode.get(IResponseHandler.VALUE_TYPE).asText();
        try{
            Data data = new Data(chartName, action.equals(PERCENTAGE) && aggrsPaths.size()==2? percentageValue(percentageList, isRoundOff) : (totalValues==null || totalValues.isEmpty())? 0.0 :totalValues.stream().reduce(0.0, Double::sum), symbol);
            responseRecorder.put(visualizationCode, request.getModuleLevel(), data);
            dataList.add(data);
            if(chartNode.get(POST_AGGREGATION_THEORY) != null) { 
            	ComputeHelper computeHelper = computeHelperFactory.getInstance(chartNode.get(POST_AGGREGATION_THEORY).asText());
            	computeHelper.compute(request, dataList); 
            }
        }catch (Exception e){
            logger.info("data chart name = "+chartName +" ex occurred "+e.getMessage());
        }

        return getAggregatedDto(chartNode, dataList, request.getVisualizationCode());
    }
}
