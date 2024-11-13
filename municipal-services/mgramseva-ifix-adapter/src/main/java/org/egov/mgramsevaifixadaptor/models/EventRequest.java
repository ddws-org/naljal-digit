package org.egov.mgramsevaifixadaptor.models;

import org.egov.common.contract.request.RequestHeader;
import org.springframework.validation.annotation.Validated;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

/**
 * Project request along with request metadata
 */
@Validated

@Setter
@Getter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class EventRequest   {
  @JsonProperty("requestHeader")
  private RequestHeader requestHeader = null;

  @JsonProperty("event")
  private Event event = null;

  
}
