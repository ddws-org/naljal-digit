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
@javax.annotation.Generated(value = "io.swagger.codegen.v3.generators.java.SpringCodegen", date = "2021-08-06T14:55:47.021Z[GMT]")

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
