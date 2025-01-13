package org.egov.naljalcustomisation.repository.rowmapper;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.egov.naljalcustomisation.repository.ServiceRequestRepository;
import org.egov.naljalcustomisation.repository.builder.CustomisationQueryBuilder;
import org.egov.naljalcustomisation.util.CustomServiceUtil;
import org.egov.naljalcustomisation.web.model.*;
import org.egov.naljalcustomisation.web.model.collection.Payment;
import org.egov.naljalcustomisation.web.model.collection.PaymentResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.time.temporal.ChronoUnit;

@Slf4j
@Component
@Setter
public class LedgerReportRowMapper implements ResultSetExtractor<List<Map<String, Object>>> {

    @Autowired
    private CustomServiceUtil customServiceUtil;

    @Autowired
    private ObjectMapper mapper;

    @Autowired
    private ServiceRequestRepository serviceRequestRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private CustomisationQueryBuilder customisationQueryBuilder;

    String tenantId;
    RequestInfoWrapper requestInfoWrapper;
    Integer startYear;
    Integer endYear;
    String consumerCode;

    public void setRequestInfo(RequestInfoWrapper requestInfoWrapper) {
        this.requestInfoWrapper = requestInfoWrapper;
    }

    @Override
    public List<Map<String, Object>> extractData(ResultSet resultSet) throws SQLException, DataAccessException {
        List<Map<String, Object>> monthlyRecordsList = new ArrayList<>();
        Map<String, LedgerReport> ledgerReports = new HashMap<>();
        YearMonth startMonth = YearMonth.of(startYear, 4);
        YearMonth endMonth;
        YearMonth now = YearMonth.now();

        if (startYear == now.getYear() || (startYear == now.getYear() - 1 && now.getMonthValue() <= 3)) {
            endMonth = now;
        } else {
            endMonth = YearMonth.of(startYear + 1, 3);
        }

        YearMonth currentMonth = startMonth;

        while (!currentMonth.isAfter(endMonth)) {
            String monthAndYear = currentMonth.format(DateTimeFormatter.ofPattern("MMMM yyyy"));
            LocalDate startOfMonth = currentMonth.atDay(1);
            Long epochTime = startOfMonth.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli();
            log.info("epoch time is "+epochTime);
            LedgerReport ledgerReport = new LedgerReport();
            ledgerReport.setDemand(new DemandLedgerReport());
            ledgerReport.getDemand().setMonthAndYear(monthAndYear);
            ledgerReport.getDemand().setConnectionNo(consumerCode);
            BigDecimal taxAmountResult = getMonthlyTaxAmount(epochTime, consumerCode);
            BigDecimal totalAmountPaidResult = getMonthlyTotalAmountPaid(epochTime, consumerCode);
            ledgerReport.getDemand().setArrears(taxAmountResult.subtract(totalAmountPaidResult));
            log.info("Arrers are "+ledgerReport.getDemand().getArrears()+" and monthandYear"+ ledgerReport.getDemand().getMonthAndYear());
            ledgerReports.put(monthAndYear, ledgerReport);
            currentMonth = currentMonth.plusMonths(1);
        }
        while (resultSet.next()) {
            Long dateLong = resultSet.getLong("enddate");
            LocalDate date = Instant.ofEpochMilli(dateLong).atZone(ZoneId.systemDefault()).toLocalDate();
            String monthAndYear = date.format(DateTimeFormatter.ofPattern("MMMM yyyy"));

            String code = resultSet.getString("code");

            BigDecimal taxamount = resultSet.getBigDecimal("taxamount");

            Long demandGenerationDateLong = resultSet.getLong("demandgenerationdate");
            LocalDate demandGenerationDateLocal = Instant.ofEpochMilli(demandGenerationDateLong).atZone(ZoneId.systemDefault()).toLocalDate();

            LedgerReport ledgerReport = ledgerReports.get(monthAndYear);

            if (ledgerReport.getPayment() == null) {
                ledgerReport.setPayment(new ArrayList<>());
            }

//            if (code.equals("10102")) {
//                ledgerReport.getDemand().setArrears(taxamount != null ? taxamount : BigDecimal.ZERO);
//                ledgerReport.getDemand().setMonthAndYear(monthAndYear);
//            } else
            BigDecimal arrers_Penalty=BigDecimal.ZERO;
            if(code.equalsIgnoreCase("10201"))
            {
                arrers_Penalty=taxamount;
            }
            if(code.equalsIgnoreCase("WS_Round_Off"))
            {
                ledgerReport.getDemand().setTaxamount(ledgerReport.getDemand().getTaxamount().add(taxamount));
            }
            if (code.equalsIgnoreCase("WS_TIME_PENALTY")) {
                ledgerReport.getDemand().setPenalty(taxamount != null ? taxamount : BigDecimal.ZERO);
                BigDecimal amount = ledgerReport.getDemand().getTaxamount() != null ? ledgerReport.getDemand().getTaxamount() : BigDecimal.ZERO;
                ledgerReport.getDemand().setTotalForCurrentMonth((taxamount != null ? taxamount : BigDecimal.ZERO).add(amount));
            } else if (code.equalsIgnoreCase("10101")) {
                ledgerReport.getDemand().setMonthAndYear(monthAndYear);
                ledgerReport.getDemand().setDemandGenerationDate(demandGenerationDateLong);
                ledgerReport.getDemand().setTaxamount(ledgerReport.getDemand().getTaxamount().add(taxamount));
                ledgerReport.getDemand().setTotalForCurrentMonth(ledgerReport.getDemand().getTaxamount().add(ledgerReport.getDemand().getPenalty() != null ? ledgerReport.getDemand().getPenalty() : BigDecimal.ZERO));
                long dueDateMillis = demandGenerationDateLocal.plus(10, ChronoUnit.DAYS).atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli();
                long penaltyAppliedDateMillis = demandGenerationDateLocal.plus(11, ChronoUnit.DAYS).atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli();
                ledgerReport.getDemand().setDueDate(dueDateMillis);
                ledgerReport.getDemand().setPenaltyAppliedDate(penaltyAppliedDateMillis);
//                ledgerReport.getDemand().setTotal_due_amount(ledgerReport.getDemand().getTotalForCurrentMonth().add(ledgerReport.getDemand().getArrears()));
            }
            ledgerReport.getDemand().setTotal_due_amount(ledgerReport.getDemand().getTotalForCurrentMonth().add(ledgerReport.getDemand().getArrears() != null ? ledgerReport.getDemand().getArrears() : BigDecimal.ZERO));
            ledgerReport.getDemand().setConnectionNo(resultSet.getString("connectionno"));
            ledgerReport.getDemand().setOldConnectionNo(resultSet.getString("oldconnectionno"));
            ledgerReport.getDemand().setUserId(resultSet.getString("uuid"));
            log.info("Data inserted into map " + ledgerReport.toString());
            ledgerReports.put(monthAndYear, ledgerReport);
        }
        for (Map.Entry<String, LedgerReport> entry : ledgerReports.entrySet()) {
            Map<String, Object> record = new HashMap<>();
            record.put(entry.getKey(), entry.getValue());
            monthlyRecordsList.add(record);
        }
        log.info("ledger report list" + monthlyRecordsList);
        if (!monthlyRecordsList.isEmpty()) {
            addPaymentToLedger(monthlyRecordsList);
        }
        monthlyRecordsList.sort(new Comparator<Map<String, Object>>() {
            @Override
            public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                String monthAndYear1 = (String) o1.keySet().iterator().next();
                String monthAndYear2 = (String) o2.keySet().iterator().next();

                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH);
                YearMonth yearMonth1 = YearMonth.parse(monthAndYear1, formatter);
                YearMonth yearMonth2 = YearMonth.parse(monthAndYear2, formatter);

                return yearMonth1.compareTo(yearMonth2);
            }
        });
        return monthlyRecordsList;
    }

    public List<Payment> addPaymentDetails(String consumerCode) {
        if(consumerCode==null)
            return null;
        String service = "WS";
        StringBuilder URL = customServiceUtil.getcollectionURL();
        URL.append(service).append("/_search").append("?").append("consumerCodes=").append(consumerCode)
                .append("&").append("tenantId=").append(tenantId);
        Object response = serviceRequestRepository.fetchResult(URL, requestInfoWrapper);
        log.info("line 226 response " + response.toString());
        PaymentResponse paymentResponse = mapper.convertValue(response, PaymentResponse.class);
        return paymentResponse.getPayments();
    }

    private void addPaymentToLedger(List<Map<String, Object>> monthlyRecordList) {
        for (Map<String, Object> record : monthlyRecordList) {
            LedgerReport ledgerReport = (LedgerReport) record.values().iterator().next();
            if (ledgerReport.getDemand() == null) {
                log.info("DemandLedgerReport is null for LedgerReport: {}", ledgerReport);
            }
            String consumerCode = ledgerReport.getDemand().getConnectionNo();
            log.info("consumer code is " + consumerCode);
            List<Payment> payments = addPaymentDetails(consumerCode);
            boolean paymentMatched = false;
            if(payments!=null)
            {
                BigDecimal totalPaymentInMonth=BigDecimal.ZERO;
                BigDecimal totalBalanceLeftInMonth=BigDecimal.ZERO;
                for (Payment payment : payments) {
                    Long transactionDateLong = payment.getTransactionDate();
                    LocalDate transactionDate = Instant.ofEpochMilli(transactionDateLong).atZone(ZoneId.systemDefault()).toLocalDate();
                    String transactionMonthAndYear = transactionDate.format(DateTimeFormatter.ofPattern("MMMM yyyy"));
                    if (ledgerReport.getDemand().getMonthAndYear().equals(transactionMonthAndYear)) {
                        PaymentLedgerReport paymentLedgerReport = new PaymentLedgerReport();
                        paymentLedgerReport.setCollectionDate(transactionDateLong);
                        paymentLedgerReport.setReceiptNo(payment.getPaymentDetails().get(0).getReceiptNumber());
                        paymentLedgerReport.setPaid(payment.getTotalAmountPaid());
                        paymentLedgerReport.setBalanceLeft(payment.getTotalDue().subtract(paymentLedgerReport.getPaid()));
                        totalPaymentInMonth=totalPaymentInMonth.add(payment.getTotalAmountPaid());
                        totalBalanceLeftInMonth=totalBalanceLeftInMonth.add(payment.getTotalDue());
                        if (ledgerReport.getPayment() == null) {
                            ledgerReport.setPayment(new ArrayList<>());
                        }
                        ledgerReport.getPayment().add(paymentLedgerReport);
                        paymentMatched = true;
                    }
                }
                ledgerReport.setTotalBalanceLeftInMonth(totalBalanceLeftInMonth);
                ledgerReport.setTotalPaymentInMonth(totalPaymentInMonth);
            }
            if (!paymentMatched) {
                PaymentLedgerReport defaultPaymentLedgerReport = new PaymentLedgerReport();
                defaultPaymentLedgerReport.setCollectionDate(null);
                defaultPaymentLedgerReport.setReceiptNo("N/A");
                defaultPaymentLedgerReport.setPaid(BigDecimal.ZERO);
                defaultPaymentLedgerReport.setBalanceLeft(ledgerReport.getDemand().getTotal_due_amount());

                if (ledgerReport.getPayment() == null) {
                    ledgerReport.setPayment(new ArrayList<>());
                }
                ledgerReport.getPayment().add(defaultPaymentLedgerReport);
                ledgerReport.setTotalBalanceLeftInMonth(BigDecimal.ZERO);
                ledgerReport.setTotalPaymentInMonth(BigDecimal.ZERO);
            }
        }
    }

    private BigDecimal getMonthlyTaxAmount(Long startDate, String consumerCode) {
        StringBuilder taxAmountQuery = new StringBuilder(customisationQueryBuilder.TAX_AMOUNT_QUERY);
        List<Object> taxAmountParams = new ArrayList<>();
        taxAmountParams.add(consumerCode);
        taxAmountParams.add(startDate);
        BigDecimal ans = jdbcTemplate.queryForObject(taxAmountQuery.toString(), taxAmountParams.toArray(), BigDecimal.class);
        if (ans != null)
            return ans;
        return BigDecimal.ZERO;
    }

    private BigDecimal getMonthlyTotalAmountPaid(Long startDate, String consumerCode) {
        StringBuilder totalAmountPaidQuery = new StringBuilder(customisationQueryBuilder.TOTAL_AMOUNT_PAID_QUERY);
        List<Object> totalAmountPaidParams = new ArrayList<>();
        totalAmountPaidParams.add(consumerCode);
        totalAmountPaidParams.add(startDate);
        BigDecimal ans = jdbcTemplate.queryForObject(totalAmountPaidQuery.toString(), totalAmountPaidParams.toArray(), BigDecimal.class);
        if (ans != null)
            return ans;
        return BigDecimal.ZERO;
    }
}

