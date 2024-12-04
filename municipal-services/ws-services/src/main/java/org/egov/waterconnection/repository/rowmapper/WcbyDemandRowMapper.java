package org.egov.waterconnection.repository.rowmapper;

import lombok.extern.slf4j.Slf4j;
import org.egov.waterconnection.web.models.WaterConnectionByDemandGenerationDate;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
@Component
@Slf4j
public class WcbyDemandRowMapper implements ResultSetExtractor<List<WaterConnectionByDemandGenerationDate>> {

    @Override
    public List<WaterConnectionByDemandGenerationDate> extractData(ResultSet rs) throws SQLException, DataAccessException {
        List<WaterConnectionByDemandGenerationDate> waterDemandGenerationDateResponseList = new ArrayList<WaterConnectionByDemandGenerationDate>();
        while (rs.next()) {
            String taxperiodto = String.valueOf(rs.getLong("taxperiodto"));
            if (!taxperiodto.isEmpty() && !taxperiodto.equalsIgnoreCase("0")) {
                WaterConnectionByDemandGenerationDate waterDemandGenerationDateResponse = new WaterConnectionByDemandGenerationDate();
                waterDemandGenerationDateResponse.setDate(Long.valueOf(taxperiodto));
                waterDemandGenerationDateResponse.setCount(Integer.valueOf(rs.getInt("count")));
                waterDemandGenerationDateResponseList.add(waterDemandGenerationDateResponse);
            }

        }
        return waterDemandGenerationDateResponseList;
    }
}
