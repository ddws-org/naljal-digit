package org.egov.naljalcustomisation.util;

import org.egov.naljalcustomisation.config.CustomisationConfiguration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class MdmsUtil {

    @Autowired
    private CustomisationConfiguration config;

    public StringBuilder getMdmsSearchUrl() {
        return new StringBuilder().append(config.getMdmsHost()).append(config.getMdmsEndPoint());
    }
}
