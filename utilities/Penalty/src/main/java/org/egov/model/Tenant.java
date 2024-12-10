package org.egov.model;

import lombok.*;
import com.fasterxml.jackson.annotation.JsonProperty;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tenant {
    private String code;

    @JsonProperty("blockcode")
    private String blockCode;

    @JsonProperty("blockname")
    private String blockName;
    
}
