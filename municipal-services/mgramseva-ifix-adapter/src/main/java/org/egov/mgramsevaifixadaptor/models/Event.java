package org.egov.mgramsevaifixadaptor.models;

import java.util.List;

import jakarta.validation.Valid;


import org.springframework.validation.annotation.Validated;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

/**
 * Captures the finacial event attributes
 */
@Validated

@Setter
@Getter
@ToString
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Event   {
  @JsonProperty("id")
  private String id;

  @JsonProperty("tenantId")
  private String tenantId;

  @JsonProperty("eventType")
  private EventTypeEnum eventType;

  @JsonProperty("entity")
  @Valid
  private List<Object> entity;

  @JsonProperty("auditDetails")
  private AuditDetails auditDetails;
  
  @JsonProperty("projectId")
  private String projectId;

  
}
