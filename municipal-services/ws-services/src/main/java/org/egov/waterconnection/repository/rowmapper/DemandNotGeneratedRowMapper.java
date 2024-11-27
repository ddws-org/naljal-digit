package org.egov.waterconnection.repository.rowmapper;

import org.egov.waterconnection.web.models.ConsumersDemandNotGenerated;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Component
public class DemandNotGeneratedRowMapper implements ResultSetExtractor<List<ConsumersDemandNotGenerated>> {
    @Override
    public List<ConsumersDemandNotGenerated> extractData(ResultSet resultSet) throws SQLException, DataAccessException {
        List<ConsumersDemandNotGenerated> consumersDemandNotGeneratedList=new ArrayList<>();
        while(resultSet.next())
        {
            ConsumersDemandNotGenerated consumersDemandNotGenerated=new ConsumersDemandNotGenerated();
            consumersDemandNotGenerated.setConsumerCode(resultSet.getString("connectionno"));
            consumersDemandNotGeneratedList.add(consumersDemandNotGenerated);
        }
        return consumersDemandNotGeneratedList;
    }
}
