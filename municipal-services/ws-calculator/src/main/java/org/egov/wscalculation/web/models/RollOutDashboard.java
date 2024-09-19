package org.egov.wscalculation.web.models;

import lombok.*;

import java.time.LocalDateTime;
import java.util.Date;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RollOutDashboard {
    private String id;
    private String tenantid;
    private String projectcode;
    private String zone;
    private String circle;
    private String division;
    private String subdivision;
    private String section;
    private int activeUsersCount;
    private double totalAdvance;
    private double totalPenalty;
    private int totalConnections;
    private int activeConnections;
    private String lastDemandGenDate;
    private int demandGeneratedConsumerCount;
    private double totalDemandAmount;
    private double collectionTillDate;
    private String lastCollectionDate;
    private int expenseCount;
    private int countOfElectricityExpenseBills;
    private int noOfPaidExpenseBills;
    private String lastExpenseTxnDate;
    private double totalAmountOfExpenseBills;
    private double totalAmountOfElectricityBills;
    private double totalAmountOfPaidExpenseBills;
    private String dateRange;
    private Date createdTime;
    private String tenantName;
}