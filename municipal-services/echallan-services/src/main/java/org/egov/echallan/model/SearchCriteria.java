package org.egov.echallan.model;

import java.util.List;

import javax.validation.constraints.NotNull;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.validator.constraints.SafeHtml;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SearchCriteria {

	@JsonProperty("tenantId")
	private String tenantId;

	@JsonProperty("ids")
	private List<String> ids;

	@JsonProperty("challanNo")
	private String challanNo;
	
	@JsonProperty("accountId")
	private String accountId;

	@JsonProperty("referenceId")
	private String referenceId ;

	@JsonProperty("mobileNumber")
	private String mobileNumber;
	
	@JsonProperty("businessService")
	private String businessService;
	
	@JsonProperty("userIds")
	private List<String> userIds;
	
	@JsonProperty("offset")
	private Integer offset;

	@JsonProperty("limit")
	private Integer limit;
	
	@JsonProperty("status")
    private List<String> status;
	
	@JsonProperty("vendorIds")
	private List<String> vendorIds;
	
	@JsonProperty("expenseType")
	private String expenseType;
	
	@JsonProperty("vendorName")
	private String vendorName;
	
	@JsonProperty("isBillPaid")
	private Boolean isBillPaid;

	@JsonProperty("fromDate")
	private Long fromDate = null;

	@JsonProperty("toDate")
	private Long toDate = null;
	
	@JsonProperty("sortBy")
    private SortBy sortBy;
	
	@JsonProperty("sortOrder")
	private SortOrder sortOrder;
	
	@JsonProperty("freeSearch")
	private Boolean freeSearch = false;
	
	@JsonProperty("currentDate")
	private Long currentDate;
	
	@JsonProperty("isBillCount")
	private Boolean isBillCount = false;
	    
	public enum SortOrder {
	    ASC,
	    DESC
	}
	public enum SortBy {
		totalAmount,
		billDate,
		paidDate,
		typeOfExpense,
		challanno
	}
	
	public boolean isEmpty() {
        return (this.tenantId == null && this.ids == null  && this.mobileNumber == null 
        );
    }

}
