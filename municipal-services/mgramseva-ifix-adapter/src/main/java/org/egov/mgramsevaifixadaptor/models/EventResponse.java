package org.egov.mgramsevaifixadaptor.models;

import java.util.List;

import javax.validation.Valid;

import org.egov.common.contract.response.ResponseHeader;
import org.springframework.validation.annotation.Validated;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

/**
 * Contains the ResponseHeader and the enriched Project information
 */
@Validated
@javax.annotation.Generated(value = "io.swagger.codegen.v3.generators.java.SpringCodegen", date = "2021-08-06T14:55:47.021Z[GMT]")

@Setter
@Getter
@ToString
@Builder
public class EventResponse   {
  @JsonProperty("responseInfo")
  private ResponseHeader responseInfo;

  @JsonProperty("event")
  @Valid
  private List<Event> event;

}
