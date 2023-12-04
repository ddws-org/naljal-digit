package org.egov.mgramsevaifixadaptor.repository;

import java.util.Map;

import org.egov.mgramsevaifixadaptor.models.EventRequest;
import org.egov.mgramsevaifixadaptor.models.EventResponse;
import org.egov.tracer.model.ServiceCallException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Repository
@Slf4j
public class ServiceRequestRepository {

	

	@Autowired
	private RestTemplate restTemplate;

	@Autowired
	private ObjectMapper mapper;

	public Object fetchResult(String uri, Object request) {
		Object eventResponse=null;
	  	try {
	  		eventResponse = restTemplate.postForObject(uri, request, Map.class);
		  log.info("response from adapter is",eventResponse);
	  	}catch(HttpClientErrorException e) {
          log.error("External Service threw an Exception: ",e);
          throw new ServiceCallException(e.getResponseBodyAsString());
      	}catch(Exception e) {
          log.error("Exception while fetching from searcher: ",e);
      	}

      	return eventResponse;
	}

	

	
	  
	
}
