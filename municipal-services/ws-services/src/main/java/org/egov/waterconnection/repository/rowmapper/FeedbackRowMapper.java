package org.egov.waterconnection.repository.rowmapper;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.web.models.AuditDetails;
import org.egov.waterconnection.web.models.Feedback;
import org.postgresql.util.PGobject;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class FeedbackRowMapper  implements ResultSetExtractor<List<Feedback>>{

	@Override
	public List<Feedback> extractData(ResultSet rs) throws SQLException, DataAccessException {
		// TODO Auto-generated method stub
		List<Feedback> feedbackList=new ArrayList<Feedback>();
		
		while(rs.next()) {
			Feedback feedback=new Feedback();
			feedback.setId(rs.getString("id"));
			feedback.setTenantId(rs.getString("tenantid"));
			feedback.setPaymentId(rs.getString("paymentid"));
			feedback.setBillingCycle(rs.getString("billingcycle"));
			feedback.setConnectionNo(rs.getString("connectionno"));
			AuditDetails auditDetails=new AuditDetails();
			auditDetails.setCreatedBy(rs.getString("createdby"));
			auditDetails.setCreatedTime(rs.getLong("createdtime"));
			auditDetails.setLastModifiedTime(rs.getLong("lastmodifiedtime"));
			auditDetails.setLastModifiedBy(rs.getString("lastmodifiedby"));	
			feedback.setAuditDetails(auditDetails);
			feedback.setAdditionalDetails(getAdditionalDetail("additionaldetails", rs));
			feedbackList.add(feedback);		
		}
		
		return feedbackList;
	}
    private JsonNode getAdditionalDetail(String columnName, ResultSet rs){

        JsonNode additionalDetail = null;
        ObjectMapper mapper=new ObjectMapper();
        try {
            PGobject pgObj = (PGobject) rs.getObject(columnName);
            if(pgObj!=null){
                 additionalDetail = mapper.readTree(pgObj.getValue());
            }
        }
        catch (IOException | SQLException e){
            e.printStackTrace();
            throw new CustomException("FEEDBACK_PARSE_ERROR","Failed to parse additionalDetail object");
        }
        return additionalDetail;
    }
	
	

}
