package org.egov.naljalcustomisation.repository.rowmapper;

import org.egov.naljalcustomisation.web.model.PaymentMonthReport;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;

@Component
public class PaymentRowMapper implements RowMapper<PaymentMonthReport> {
    @Override
    public PaymentMonthReport mapRow(ResultSet rs, int rowNum) throws SQLException {
        PaymentMonthReport paymentMonthReport = new PaymentMonthReport();
        paymentMonthReport.setTotalAmountPaid(rs.getBigDecimal("totalAmountPaid"));
        paymentMonthReport.setFirstTransactionDate(rs.getLong("min"));
        return paymentMonthReport;
    }
}