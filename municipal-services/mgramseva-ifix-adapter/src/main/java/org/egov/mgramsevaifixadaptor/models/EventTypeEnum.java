package org.egov.mgramsevaifixadaptor.models;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

/**
   * Capture event type
   */
  public enum EventTypeEnum {
    DEMAND("DEMAND"),
    
    BILL("BILL"),
    
    RECEIPT("RECEIPT"),
    
    PAYMENT("PAYMENT");

    private String value;

    EventTypeEnum(String value) {
      this.value = value;
    }

    @Override
    @JsonValue
    public String toString() {
      return String.valueOf(value);
    }

    @JsonCreator
    public static EventTypeEnum fromValue(String text) {
      for (EventTypeEnum b : EventTypeEnum.values()) {
        if (String.valueOf(b.value).equals(text)) {
          return b;
        }
      }
      return null;
    }
  }