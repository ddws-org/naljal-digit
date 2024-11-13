package org.egov.pt.models.oldProperty;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import org.springframework.validation.annotation.Validated;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Address
 */
@Validated
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MigrationCount   {

    @Size(max=64)
    @JsonProperty("id")
    private String id;

    @JsonProperty("offset")
    private Long offset;

    @JsonProperty("limit")
    private Long limit;

    @JsonProperty("createdTime")
    private Long createdTime;

    @JsonProperty("tenantid")
    private String tenantid;

    @JsonProperty("recordCount")
    private Long recordCount;

}

