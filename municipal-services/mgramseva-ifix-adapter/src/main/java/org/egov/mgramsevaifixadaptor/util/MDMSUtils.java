package org.egov.mgramsevaifixadaptor.util;

import org.egov.common.contract.request.RequestInfo;
import org.egov.mdms.model.MasterDetail;
import org.egov.mdms.model.MdmsCriteria;
import org.egov.mdms.model.MdmsCriteriaReq;
import org.egov.mdms.model.ModuleDetail;
import org.egov.mgramsevaifixadaptor.config.PropertyConfiguration;
import org.egov.mgramsevaifixadaptor.repository.ServiceRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;


@Component
public class MDMSUtils {

    @Autowired
    PropertyConfiguration propertyConfiguration;

    @Autowired
    ServiceRequestRepository serviceRequestRepository;


    /**
     * Calls MDMS service to fetch pgr master data
     * @param requestInfo
     * @param tenantId
     * @return
     */
    public Object mDMSCall(RequestInfo requestInfo, String tenantId){
        MdmsCriteriaReq mdmsCriteriaReq = getMDMSRequest(requestInfo,tenantId);
        Object result = serviceRequestRepository.fetchResult(getMdmsSearchUrl().toString(), mdmsCriteriaReq);
        return result;
    }


    /**
     * Returns mdms search criteria based on the tenantId
     * @param requestInfo
     * @param tenantId
     * @return
     */
    public MdmsCriteriaReq getMDMSRequest(RequestInfo requestInfo,String tenantId){
        List<ModuleDetail> pgrModuleRequest = getAdapterModuleRequest(tenantId);

        List<ModuleDetail> moduleDetails = new LinkedList<>();
        moduleDetails.addAll(pgrModuleRequest);

        MdmsCriteria mdmsCriteria = MdmsCriteria.builder().moduleDetails(moduleDetails).tenantId(tenantId)
                .build();

        MdmsCriteriaReq mdmsCriteriaReq = MdmsCriteriaReq.builder().mdmsCriteria(mdmsCriteria)
                .requestInfo(requestInfo).build();
        return mdmsCriteriaReq;
    }


    /**
     * Creates request to search projectid from MDMS
     * @return request to search projectid from MDMS
     */
    private List<ModuleDetail> getAdapterModuleRequest(String tenantId) {

        // master details for adaptor module
        List<MasterDetail> adapterMasterDetails = new ArrayList<>();

        // filter to only get code field from master data
        final String filterCode = "$.[?(@.code=='"+tenantId+"')]";

        adapterMasterDetails.add(MasterDetail.builder().name(Constants.TENANTS).filter(filterCode).build());

        ModuleDetail adaptorModuleDtls = ModuleDetail.builder().masterDetails(adapterMasterDetails)
                .moduleName(Constants.TENANT).build();


        return Collections.singletonList(adaptorModuleDtls);

    }


    /**
     * Returns the url for mdms search endpoint
     *
     * @return url for mdms search endpoint
     */
    public StringBuilder getMdmsSearchUrl() {
        return new StringBuilder().append(propertyConfiguration.getMdmsHost()).append(propertyConfiguration.getMdmsSearchEndpoint());
    }

}
