package org.egov.waterconnection.web.controller;

import java.util.List;

import jakarta.validation.Valid;

import org.egov.waterconnection.constants.WCConstants;
import org.egov.waterconnection.service.SchedulerService;
import org.egov.waterconnection.service.WaterService;
import org.egov.waterconnection.util.ResponseInfoFactory;
import org.egov.waterconnection.web.models.FeedbackRequest;
import org.egov.waterconnection.web.models.FeedbackResponse;
import org.egov.waterconnection.web.models.FeedbackSearchCriteria;
import org.egov.waterconnection.web.models.RequestInfoWrapper;
import org.egov.waterconnection.web.models.SearchCriteria;
import org.egov.waterconnection.web.models.WaterConnection;
import org.egov.waterconnection.web.models.WaterConnectionRequest;
import org.egov.waterconnection.web.models.WaterConnectionResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
@RestController
@RequestMapping("/wc")
public class WaterController {

	@Autowired
	private WaterService waterService;

	@Autowired
	private final ResponseInfoFactory responseInfoFactory;

	
	@Autowired
	private SchedulerService schedulerService;

	@RequestMapping(value = "/_create", method = RequestMethod.POST, produces = "application/json")
	public ResponseEntity<WaterConnectionResponse> createWaterConnection(
			@Valid @RequestBody WaterConnectionRequest waterConnectionRequest) {
		List<WaterConnection> waterConnection = waterService.createWaterConnection(waterConnectionRequest);
		WaterConnectionResponse response = WaterConnectionResponse.builder().waterConnection(waterConnection)
				.responseInfo(responseInfoFactory
						.createResponseInfoFromRequestInfo(waterConnectionRequest.getRequestInfo(), true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@RequestMapping(value = "/_search", method = RequestMethod.POST)
	public ResponseEntity<WaterConnectionResponse> search(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute SearchCriteria criteria) {
		WaterConnectionResponse response = waterService.search(criteria, requestInfoWrapper.getRequestInfo());
		response.setResponseInfo(
				responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true));
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@RequestMapping(value = "/_update", method = RequestMethod.POST, produces = "application/json")
	public ResponseEntity<WaterConnectionResponse> updateWaterConnection(
			@Valid @RequestBody WaterConnectionRequest waterConnectionRequest) {
		List<WaterConnection> waterConnection = waterService.updateWaterConnection(waterConnectionRequest);
		WaterConnectionResponse response = WaterConnectionResponse.builder().waterConnection(waterConnection)
				.responseInfo(responseInfoFactory
						.createResponseInfoFromRequestInfo(waterConnectionRequest.getRequestInfo(), true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);

	}
	
	@RequestMapping(value = "/_submitfeedback", method = RequestMethod.POST)
	public ResponseEntity<String> submitFeedback(@Valid @RequestBody FeedbackRequest feedbackrequest) {

		waterService.submitFeedback(feedbackrequest);

		return new ResponseEntity<>(WCConstants.SUCCESSFUL_FEEDBACK_SUBMIT, HttpStatus.OK);

	}

	@RequestMapping(value = "/_getfeedback", method = RequestMethod.POST)
	public ResponseEntity<FeedbackResponse> getFeedback(
			@Valid @ModelAttribute FeedbackSearchCriteria feedbackSearchCriteria, @RequestBody RequestInfoWrapper requestInfoWrapper) throws JsonMappingException, JsonProcessingException {

		Object feedbackList = waterService.getFeedback(feedbackSearchCriteria);

		FeedbackResponse feedbackResponse = FeedbackResponse.builder()
				.responseInfo(responseInfoFactory
						.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
				.feedback(feedbackList).build();

		return new ResponseEntity<>(feedbackResponse, HttpStatus.OK);
	}
	
//	@PostMapping("/_schedulerpendingcollection")
//	public void schedulerpendingcollection(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
//		schedulerService.sendPendingCollectionEvent(requestInfoWrapper.getRequestInfo());
//	}

	@PostMapping("/_schedulergeneratedemand")
	public void schedulergeneratedemand(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
		schedulerService.sendGenerateDemandEvent(requestInfoWrapper.getRequestInfo());
	}
	
//	@PostMapping("/_schedulerTodaysCollection")
//	public void schedulerTodaysCollection(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
//		schedulerService.sendTodaysCollection(requestInfoWrapper.getRequestInfo());
//	}
	
	 @PostMapping("/fuzzy/_search")
	    public ResponseEntity<WaterConnectionResponse> fuzzySearch(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
	                                                      @Valid @ModelAttribute SearchCriteria criteria) {

		 WaterConnectionResponse response = waterService.getWCListFuzzySearch(criteria, requestInfoWrapper.getRequestInfo()); 
		 response.setResponseInfo(
					responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true));
			return new ResponseEntity<>(response, HttpStatus.OK);
	    }
	 
	 @RequestMapping(value = "/_plainsearch", method = RequestMethod.POST)
		public ResponseEntity<WaterConnectionResponse> planeSearch(
				@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
				@Valid @ModelAttribute SearchCriteria criteria) {
			WaterConnectionResponse response = waterService.planeSearch(criteria, requestInfoWrapper.getRequestInfo());
			response.setResponseInfo(
					responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true));
	    return new ResponseEntity<>(response, HttpStatus.OK);
		}
}
