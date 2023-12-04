package org.egov.mgramsevaifixadaptor;

import org.egov.tracer.config.TracerConfiguration;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.PropertySource;
import org.springframework.web.client.RestTemplate;


@SpringBootApplication
@Import({ TracerConfiguration.class })
public class MgramsevaAdapterWrapper
{
	public static void main(String[] args) {
	
		SpringApplication.run(MgramsevaAdapterWrapper.class, args);
	}
	
	
}
