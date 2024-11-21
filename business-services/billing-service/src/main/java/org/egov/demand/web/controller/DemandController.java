/*
 * eGov suite of products aim to improve the internal efficiency,transparency,
 *    accountability and the service delivery of the government  organizations.
 *
 *     Copyright (C) <2015>  eGovernments Foundation
 *
 *     The updated version of eGov suite of products as by eGovernments Foundation
 *     is available at http://www.egovernments.org
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program. If not, see http://www.gnu.org/licenses/ or
 *     http://www.gnu.org/licenses/gpl.html .
 *
 *     In addition to the terms of the GPL license to be adhered to in using this
 *     program, the following additional terms are to be complied with:
 *
 *         1) All versions of this program, verbatim or modified must carry this
 *            Legal Notice.
 *
 *         2) Any misrepresentation of the origin of the material is prohibited. It
 *            is required that all modified versions of this material be marked in
 *            reasonable ways as different from the original version.
 *
 *         3) This license does not grant any rights to any user of the program
 *            with regards to rights under trademark law for use of the trade names
 *            or trademarks of eGovernments Foundation.
 *
 *   In case of any queries, you can reach eGovernments Foundation at contact@egovernments.org.
 */
package org.egov.demand.web.controller;

import java.util.List;
import java.util.Map;

import javax.validation.Valid;

import org.egov.common.contract.request.RequestInfo;
import org.egov.demand.config.ApplicationProperties;
import org.egov.demand.model.AggregatedDemandDetailResponse;
import org.egov.demand.model.Demand;
import org.egov.demand.model.DemandCriteria;
import org.egov.demand.model.DemandHistory;
import org.egov.demand.producer.Producer;
import org.egov.demand.service.DemandService;
import org.egov.demand.util.migration.DemandMigration;
import org.egov.demand.web.contract.DemandHistoryResponse;
import org.egov.demand.web.contract.DemandRequest;
import org.egov.demand.web.contract.DemandResponse;
import org.egov.demand.web.contract.RequestInfoWrapper;
import org.egov.demand.web.contract.factory.ResponseFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/demand")
@Slf4j
public class DemandController {

	@Autowired
	private DemandService demandService;

	@Autowired
	private ResponseFactory responseFactory;
	
	@Autowired
	private DemandMigration migrationService;
	
	@Autowired
	private ApplicationProperties properties;
	
	@Autowired
	Producer producer;
	
	

	/**
	 * API to create demands
	 *
	 * @param demandRequest
	 * @return ResponseEntity<?>
	 */

	@PostMapping("_create")
	@ResponseBody
	public ResponseEntity<?> create(@RequestHeader HttpHeaders headers, @RequestBody @Valid DemandRequest demandRequest) {

		log.info("the demand request object : " + demandRequest);

		DemandResponse demandResponse = demandService.create(demandRequest);
		
		demandRequest.setDemands(demandResponse.getDemands());
		
		producer.push(properties.getCreateDemand(), demandRequest);
		
		return new ResponseEntity<>(demandResponse, HttpStatus.CREATED);
	}

	@PostMapping("_update")
	public ResponseEntity<?> update(@RequestHeader HttpHeaders headers, @RequestBody @Valid DemandRequest demandRequest) {

		DemandResponse demandResponse=demandService.updateAsync(demandRequest, null);
		demandRequest.setDemands(demandResponse.getDemands());
		producer.push(properties.getUpdateDemand(), demandRequest);
		return new ResponseEntity<>(demandResponse, HttpStatus.CREATED);
	}

	@PostMapping("_search")
	public ResponseEntity<?> search(@RequestBody RequestInfoWrapper requestInfoWrapper,
			@ModelAttribute @Valid DemandCriteria demandCriteria) {

		RequestInfo requestInfo = requestInfoWrapper.getRequestInfo();

		List<Demand> demands = demandService.getDemands(demandCriteria, requestInfo);
		DemandResponse response = DemandResponse.builder().demands(demands)
				.responseInfo(responseFactory.getResponseInfo(requestInfo, HttpStatus.OK)).build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
	
	/*
	 * migration api
	 */
	
    @PostMapping(value = "/_migratetov1")
    @ResponseBody
	public ResponseEntity<?> migrate(@RequestBody @Valid RequestInfoWrapper wrapper,
			@RequestParam(required=false) Integer batchStart, @RequestParam(required=true) Integer batchSizeInput) {

		Map<String, String> resultMap = migrationService.migrateToV1(batchStart, batchSizeInput, wrapper.getRequestInfo().getUserInfo().getTenantId().substring(0,2));
		return new ResponseEntity<>(resultMap, HttpStatus.OK);
	}
    
    @PostMapping("_history")
	public ResponseEntity<?> history(@RequestBody RequestInfoWrapper requestInfoWrapper,
			@ModelAttribute @Valid DemandCriteria demandCriteria) {

		RequestInfo requestInfo = requestInfoWrapper.getRequestInfo();

		DemandHistory demands = demandService.getDemandHistory(demandCriteria, requestInfo);
		DemandHistoryResponse response = DemandHistoryResponse.builder().demands(demands.getDemandList())
				.advanceAdjustedAmount(demands.getAdvanceAdjustedAmount()).waterCharge(demands.getWaterCharge()).
				responseInfo(responseFactory.getResponseInfo(requestInfo, HttpStatus.OK)).build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
	@PostMapping("_getAggregateDemandDetails")
	public ResponseEntity<?> getAggregatedDemandDetails(@RequestBody RequestInfoWrapper requestInfoWrapper,
														@ModelAttribute @Valid DemandCriteria demandCriteria) {

		RequestInfo requestInfo = requestInfoWrapper.getRequestInfo();

		AggregatedDemandDetailResponse demands  = demandService.getAllDemands(demandCriteria, requestInfo);
		return new ResponseEntity<>(demands, HttpStatus.OK);
	}

	@PostMapping("/_plainsearch")
	public ResponseEntity<?> plainsearch(@RequestBody RequestInfoWrapper requestInfoWrapper,
														@ModelAttribute @Valid DemandCriteria demandCriteria) {

		RequestInfo requestInfo = requestInfoWrapper.getRequestInfo();
		List<Demand> demands = demandService.demandPlainSearch(demandCriteria, requestInfo);
		DemandResponse response = DemandResponse.builder().demands(demands)
				.responseInfo(responseFactory.getResponseInfo(requestInfo, HttpStatus.OK)).build();
		return new ResponseEntity<>(response, HttpStatus.OK);

	}

}