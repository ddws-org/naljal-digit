package org.egov;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class PenaltySchedularApplication {
    public static void main(String[] args) {
        SpringApplication.run(PenaltySchedularApplication.class, args);
    }
}