package org.egov.naljalcustomisation.validator;

import lombok.extern.slf4j.Slf4j;
import org.egov.naljalcustomisation.web.model.WaterConnection;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import java.util.List;

@Component
@Slf4j
public class CustomisationServiceValidator
{
    public void validatePropertyForConnection(List<WaterConnection> waterConnectionList) {
        waterConnectionList.forEach(waterConnection -> {
            if (StringUtils.isEmpty(waterConnection.getId())) {
                StringBuilder builder = new StringBuilder();
                builder.append("PROPERTY UUID NOT FOUND FOR ")
                        .append(waterConnection.getConnectionNo() == null ? waterConnection.getApplicationNo()
                                : waterConnection.getConnectionNo());
                log.error(builder.toString());
            }
        });
    }
}
