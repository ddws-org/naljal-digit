package org.egov.naljalcustomisation.web.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LastMonthSummary {

    @JsonProperty("cumulativePendingCollection")
    private String cumulativePendingCollection = "0";

    @JsonProperty("newDemand")
    private String newDemand = "0";

    @JsonProperty("actualCollection")
    private String actualCollection = "0";

    @JsonProperty("previousMonthYear")
    private String previousMonthYear ="";
}