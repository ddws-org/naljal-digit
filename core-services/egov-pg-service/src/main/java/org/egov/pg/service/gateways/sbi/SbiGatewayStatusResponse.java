package org.egov.pg.service.gateways.sbi;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class SbiGatewayStatusResponse {

	public SbiGatewayStatusResponse(String txnStatus) {
		this.txnStatus = txnStatus;
	}
	
	private String merchantId;
    private String sbiePayRefId;
    private String txnStatus;
    private String country;
    private String cuurency;
    private String otherDetails;
    private String merchantOrderNo;
    private String amount;
    private String txnStatusDesc;
    private String bankCode;
    private String bankReferenceNo;
    @JsonProperty("timeStamp")
    private String transactionDate;
    private String payMode;
    private String cin;
    private String totalFeeGST;
    private String ref1;
    private String ref2;
    private String ref3; 
    private String ref4;
    private String ref5;
    private String ref6;
    private String ref7;
    private String ref8;
    private String ref9;
    private String ref10;
    private String errorCode;
    private String errorMessage;
}
