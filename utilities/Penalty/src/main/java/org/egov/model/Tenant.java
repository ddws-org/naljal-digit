package org.egov.model;

import lombok.*;

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
