package org.egov.waterconnection.repository.rowmapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.egov.waterconnection.web.models.BillingCycle;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

@Component
public class BillingCycleRowMapper implements ResultSetExtractor<List<BillingCycle>> {

	@Override
	public List<BillingCycle> extractData(ResultSet rs) throws SQLException, DataAccessException {
		// TODO Auto-generated method stub
		List<BillingCycle> billingCycleList = new ArrayList<>();
		while (rs.next()) {
			BillingCycle billingCycle = new BillingCycle();
			billingCycle.setFromperiod(rs.getLong("fromperiod"));
			billingCycle.setToperiod(rs.getLong("toperiod"));
			billingCycleList.add(billingCycle);
		}

		return billingCycleList;

	}

}
