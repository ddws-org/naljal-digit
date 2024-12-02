package org.egov.model;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tenant {
    private String code;
    private String blockCode;
    private String blockName;
}
