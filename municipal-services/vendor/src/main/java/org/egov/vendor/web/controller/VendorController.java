package org.egov.vendor.web.controller;


import java.util.ArrayList;
import java.util.List;

import javax.validation.Valid;

import org.egov.vendor.service.VendorService;
import org.egov.vendor.util.ResponseInfoFactory;
import org.egov.vendor.util.VendorUtil;
import org.egov.vendor.web.model.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/v1")
public class VendorController {

	@Autowired
	private VendorService vendorService;
	
	@Autowired
	private VendorUtil vendorUtil;
	
	@Autowired
	private ResponseInfoFactory responseInfoFactory;

	
	@PostMapping(value = "/_create")
	public ResponseEntity<VendorResponse> create(@Valid @RequestBody VendorRequest vendorRequest){
		vendorUtil.defaultJsonPathConfig();		
		Vendor vendor =  vendorService.create(vendorRequest);
		List<Vendor> vendorList = new ArrayList<Vendor>();
		vendorList.add(vendor);
		VendorResponse response = VendorResponse.builder().vendor(vendorList)
				.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(vendorRequest.getRequestInfo(), true))
				.build();
		
		return new ResponseEntity<>(response,HttpStatus.OK);
		
	}
	
	
	
	@PostMapping(value = "/_search")
	public ResponseEntity<VendorResponse> search(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute VendorSearchCriteria criteria){
		List<Vendor> vendorList = vendorService.Vendorsearch(criteria, requestInfoWrapper.getRequestInfo());
		VendorResponse response = VendorResponse.builder().vendor(vendorList).responseInfo(
				responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
		
	}
	
	@RequestMapping(value = "/_plainsearch", method = RequestMethod.POST)
	public ResponseEntity<VendorResponse> plainsearch(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute VendorSearchCriteria criteria) {
		List<Vendor> vendorList = vendorService.vendorPlainSearch(criteria,requestInfoWrapper.getRequestInfo());
		VendorResponse response = VendorResponse.builder().vendor(vendorList).responseInfo(
				responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@RequestMapping(value="/_vendorReport" ,method = RequestMethod.POST)
	public ResponseEntity<VendorReportResponse> vendorReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
															 @RequestParam(value="monthStartDate" , required = true) String monthStartDate,
															 @RequestParam ("tenantId") String tenantId,
															 @RequestParam ("offset") Integer offset,
															 @RequestParam ("limit") Integer limit)
	{

        List<VendorReportData> vendorReportData=vendorService.vendorReport(monthStartDate,tenantId,offset,limit,requestInfoWrapper.getRequestInfo());
		VendorReportResponse vendorReportResponse= VendorReportResponse.builder().VendorReportData(vendorReportData).responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),true)).build();

		return new ResponseEntity<>(vendorReportResponse,HttpStatus.OK);
    }

}
