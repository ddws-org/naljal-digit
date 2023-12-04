package org.egov.waterconnection.web.controller;


import java.io.IOException;
import java.util.HashMap;

import org.egov.common.contract.request.RequestInfo;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.repository.WaterDaoImpl;
import org.egov.waterconnection.service.OnBoardService;
import org.egov.waterconnection.service.WaterService;
import org.egov.waterconnection.util.ResponseInfoFactory;
import org.egov.waterconnection.web.models.OnBoardResponse;
import org.egov.waterconnection.web.models.RequestInfoWrapper;
import org.egov.waterconnection.web.models.WaterConnectionResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
@RestController
@RequestMapping("/wc")
public class OnboardingController {

	

	@Autowired
	private final ResponseInfoFactory responseInfoFactory;
	
	@Autowired
	private final OnBoardService onBoardService;

	@Autowired
	private ObjectMapper objectMapper;
	
	@PostMapping("/_bulkonboard")
	public ResponseEntity<OnBoardResponse> handleFileUpload(@RequestParam("file") MultipartFile file,
			@RequestParam(value = "requestInfo", required = false) String requestInfo) {
		RequestInfoWrapper requestInfoWrapper = new RequestInfoWrapper();
		try {
			//String decoded = new String(Base64.getDecoder().decode(requestInfoBase64));
			if(requestInfo != null)
				requestInfoWrapper.setRequestInfo(objectMapper.readValue(requestInfo, RequestInfo.class));
			
		} catch (IOException e) {

			
			throw new CustomException("INVALID_REQ_INFO","Failed to deserialization the requestinfo object");
		}
		HashMap<String,String> messages= onBoardService.process(file,requestInfoWrapper);
		OnBoardResponse response = OnBoardResponse.builder().messages(messages)
				.responseInfo(responseInfoFactory
						.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
				.build();
		
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	


}
