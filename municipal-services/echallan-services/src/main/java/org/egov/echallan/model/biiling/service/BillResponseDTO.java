package org.egov.echallan.model.biiling.service;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.egov.common.contract.response.ResponseInfo;

import java.util.ArrayList;
import java.util.List;

/**
 * BillResponse
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillResponseDTO {

    @JsonProperty("ResposneInfo")
    private ResponseInfo resposneInfo = null;

    @JsonProperty("Bill")
    private List<BillDTO> bill = new ArrayList<>();

}
