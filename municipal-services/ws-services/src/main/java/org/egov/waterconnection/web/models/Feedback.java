package org.egov.waterconnection.web.models;

import jakarta.validation.constraints.NotNull;

import io.micrometer.core.lang.NonNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter

public class Feedback {
	
	
	private String id;
	
	@NotNull
	private String connectionNo;
	
	@NotNull
	private String paymentId;
	
	private String billingCycle;
	
	private Object additionalDetails;
	
	private AuditDetails auditDetails;
	
	@NotNull
	private String tenantId;
	
	
	
	
	
	

}
