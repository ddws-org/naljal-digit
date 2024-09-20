package org.egov.naljalcustomisation.web.model;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.springframework.validation.annotation.Validated;

import java.util.Map;

@Validated
@AllArgsConstructor
@EqualsAndHashCode
@Getter
@NoArgsConstructor
@Setter
@ToString
@Builder
public class Event {

    @NotNull
    private String tenantId;

    private String id;

    private String referenceId;

    @NotNull
    private String eventType;

    private String name;

    @NotNull
    private String description;

    private Status status;

    @NotNull
    private Source source;

    private String postedBy;

    @Valid
    @NotNull
    private Recepient recepient;

    private Action actions;

    private EventDetails eventDetails;

    private Map<String, Object> additionalDetails;


}

