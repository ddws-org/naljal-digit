package org.egov.echallan.service;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Month;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.*;

import jakarta.validation.Valid;

import org.egov.common.contract.request.RequestInfo;
import org.egov.echallan.config.ChallanConfiguration;
import org.egov.echallan.expense.service.PaymentService;
import org.egov.echallan.expense.validator.ExpenseValidator;
import org.egov.echallan.model.Challan;
import org.egov.echallan.model.Challan.StatusEnum;
import org.egov.echallan.model.ChallanRequest;
import org.egov.echallan.model.LastMonthSummary;
import org.egov.echallan.model.SearchCriteria;
import org.egov.echallan.model.biiling.service.BillResponseDTO;
import org.egov.echallan.repository.BillingServiceRepository;
import org.egov.echallan.repository.ChallanRepository;
import org.egov.echallan.util.CommonUtils;
import org.egov.echallan.validator.ChallanValidator;
import org.egov.echallan.web.models.ChallanCollectionData;
import org.egov.echallan.web.models.ExpenseDashboard;
import org.egov.echallan.web.models.user.UserDetailResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;


@Service
public class ChallanService {

    @Autowired
    private EnrichmentService enrichmentService;

    @Autowired
	private BillingServiceRepository billingServiceRepository;

    private UserService userService;
    
    private ChallanRepository repository;
    
    private CalculationService calculationService;
    
    private ChallanValidator validator;
    
    private ExpenseValidator expenseValidator;

    private CommonUtils utils;
    
    private PaymentService paymentService;
    
    private ChallanConfiguration config;

    
	@Autowired
	public ChallanService(EnrichmentService enrichmentService, UserService userService, ChallanRepository repository,
			CalculationService calculationService, ChallanValidator validator, CommonUtils utils,
			ExpenseValidator expenseValidator, PaymentService paymentService, ChallanConfiguration config) {
		this.enrichmentService = enrichmentService;
		this.userService = userService;
		this.repository = repository;
		this.calculationService = calculationService;
		this.validator = validator;
		this.utils = utils;
		this.expenseValidator = expenseValidator;
		this.paymentService = paymentService;
		this.config= config;
	}
    
	/**
	 * Enriches the Request and pushes to the Queue
	 *
	 * @param request ChallanRequest containing list of challans to be created
	 * @return Challan successfully created
	 */
	public Challan create(ChallanRequest request) {
		Object mdmsData = utils.mDMSCall(request);
		expenseValidator.validateFields(request, mdmsData);
		validator.validateFields(request, mdmsData);
		enrichmentService.enrichCreateRequest(request);
	//	userService.createUser(request);
		userService.setAccountUser(request);
		calculationService.addCalculation(request);
		paymentService.createPayment(request);  // If the Expense bill  is paid then post payment. 
		repository.save(request);
		return request.getChallan();
	}
	
	
	 public List<Challan> search(SearchCriteria criteria, RequestInfo requestInfo, Map<String, String> finalData){
	        List<Challan> challans;
	        //enrichmentService.enrichSearchCriteriaWithAccountId(requestInfo,criteria);
	         if(criteria.getMobileNumber()!=null){
	        	 challans = getChallansFromMobileNumber(criteria,requestInfo, finalData);
	         }
	         else {
	        	 challans = getChallansWithOwnerInfo(criteria,requestInfo, finalData);
	         }
	       return challans;
	    }
	 
	 public List<Challan> getChallansFromMobileNumber(SearchCriteria criteria, RequestInfo requestInfo, Map<String, String> finalData){
		 List<Challan> challans = new LinkedList<>();
	        UserDetailResponse userDetailResponse = userService.getUser(criteria,requestInfo);
	        if(CollectionUtils.isEmpty(userDetailResponse.getUser())){
	            return Collections.emptyList();
	        }
	        enrichmentService.enrichSearchCriteriaWithOwnerids(criteria,userDetailResponse);
	        challans = repository.getChallans(criteria, finalData, requestInfo);
	        if(CollectionUtils.isEmpty(challans)){
	            return Collections.emptyList();
	        }

	        criteria=enrichmentService.getChallanCriteriaFromIds(challans);
	        challans = getChallansWithOwnerInfo(criteria,requestInfo, finalData);
	        return challans;
	    }
	 
	 public List<Challan> getChallansWithOwnerInfo(SearchCriteria criteria,RequestInfo requestInfo, Map<String, String> finalData){
		 List<Challan> challans = repository.getChallans(criteria, finalData, requestInfo);
	        if(challans.isEmpty())
	            return Collections.emptyList();
	        challans = enrichmentService.enrichChallanSearch(challans,criteria,requestInfo);
	        return challans;
	    }
	 
	 public List<Challan> searchChallans(ChallanRequest request, Map<String, String> finalData){
	        SearchCriteria criteria = new SearchCriteria();
	        List<String> ids = new LinkedList<>();
	        ids.add(request.getChallan().getId());

	        criteria.setTenantId(request.getChallan().getTenantId());
	        criteria.setIds(ids);
	        // When the business service it self is changed 
//	        criteria.setBusinessService(request.getChallan().getBusinessService());

	        List<Challan> challans = repository.getChallans(criteria, finalData, request.getRequestInfo());
	        if(challans.isEmpty())
	            return Collections.emptyList();
	        challans = enrichmentService.enrichChallanSearch(challans,criteria,request.getRequestInfo());
	        return challans;
	    }
	 
	 public Challan update(ChallanRequest request, Map<String, String> finalData) {
			Object mdmsData = utils.mDMSCall(request);
			expenseValidator.validateFields(request, mdmsData);
			validator.validateFields(request, mdmsData);
			List<Challan> searchResult = searchChallans(request, finalData);
			validator.validateUpdateRequest(request, searchResult);
			expenseValidator.validateUpdateRequest(request, searchResult);
			userService.setAccountUser(request);
			enrichmentService.enrichUpdateRequest(request, searchResult.get(0));
			calculationService.addCalculation(request);
			if (request.getChallan().getApplicationStatus() == StatusEnum.PAID && searchResult.get(0).getApplicationStatus() == StatusEnum.ACTIVE)
				paymentService.createPayment(request);
			if (searchResult.get(0).getApplicationStatus() == StatusEnum.PAID)
				paymentService.updatePayment(request);
			repository.update(request);
			return request.getChallan();
		}

	public Challan updateCreateNoPayment(ChallanRequest request, Map<String, String> finalData) {
		Object mdmsData = utils.mDMSCall(request);
		expenseValidator.validateFields(request, mdmsData);
		validator.validateFields(request, mdmsData);
		List<Challan> searchResult = searchChallans(request, finalData);
		validator.validateUpdateRequest(request, searchResult);
		expenseValidator.validateUpdateRequest(request, searchResult);
		userService.setAccountUser(request);
		enrichmentService.enrichUpdateRequest(request, searchResult.get(0));
		calculationService.addCalculation(request);
		repository.update(request);
		return request.getChallan();
	}

	public LastMonthSummary getLastMonthSummary(SearchCriteria criteria, RequestInfo requestInfo) {

		LastMonthSummary lastMonthSummary = new LastMonthSummary();
		String tenantId = criteria.getTenantId();
		LocalDate currentMonthDate = LocalDate.now();
		if(criteria.getCurrentDate() !=null) {
			Calendar currentDate =Calendar.getInstance();
			currentDate.setTimeInMillis(criteria.getCurrentDate());
			currentMonthDate = LocalDate.of(currentDate.get(Calendar.YEAR),currentDate.get(Calendar.MONTH)+1, currentDate.get(Calendar.DAY_OF_MONTH));
		}
		LocalDate prviousMonthStart = currentMonthDate.minusMonths(1).with(TemporalAdjusters.firstDayOfMonth());
		LocalDate prviousMonthEnd = currentMonthDate.minusMonths(1).with(TemporalAdjusters.lastDayOfMonth());

		LocalDateTime previousMonthStartDateTime = LocalDateTime.of(prviousMonthStart.getYear(),
				prviousMonthStart.getMonth(), prviousMonthStart.getDayOfMonth(), 0, 0, 0);
		LocalDateTime previousMonthEndDateTime = LocalDateTime.of(prviousMonthEnd.getYear(), prviousMonthEnd.getMonth(),
				prviousMonthEnd.getDayOfMonth(), 23, 59, 59, 999000000);

		// actual payments
		Integer previousMonthExpensePayments = repository.getLastsMonthExpensePayments(tenantId,
				((Long) previousMonthStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()),
				((Long) previousMonthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()));
		if (previousMonthExpensePayments!=null)
			lastMonthSummary.setPreviousMonthCollection(previousMonthExpensePayments.toString());

		// new expenditure
		Integer previousMonthNewExpense = repository.getPreviousMonthNewExpense(tenantId,
				((Long) previousMonthStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()),
				((Long) previousMonthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()));
		if (null != previousMonthNewExpense )
			lastMonthSummary.setPreviousMonthNewExpense(previousMonthNewExpense.toString());

		// pending expenes to be paid
		Integer cumulativePendingExpense = repository.getCumulativePendingExpense(tenantId,
				((Long) previousMonthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()));
		if (null != cumulativePendingExpense )
			lastMonthSummary.setCumulativePendingExpense(cumulativePendingExpense.toString());

		lastMonthSummary.setPreviousMonthYear(getMonthYear());
		
		return lastMonthSummary;

	}
	public String getMonthYear() {
		LocalDateTime localDateTime = LocalDateTime.now();
		int currentMonth = localDateTime.getMonthValue();
		String monthYear ;
		if (currentMonth >= Month.APRIL.getValue()) {
			monthYear = YearMonth.now().getYear() + "-";
			monthYear = monthYear
					+ (Integer.toString(YearMonth.now().getYear() + 1).substring(2, monthYear.length() - 1));
		} else {
			monthYear = YearMonth.now().getYear() - 1 + "-";
			monthYear = monthYear
					+ (Integer.toString(YearMonth.now().getYear()).substring(2, monthYear.length() - 1));

		}
		StringBuilder monthYearBuilder = new StringBuilder(localDateTime.minusMonths(1).getMonth().toString()).append(" ").append(monthYear);

		return monthYearBuilder.toString() ;
	}

	public ExpenseDashboard getExpenseDashboardData(@Valid SearchCriteria criteria, RequestInfo requestInfo) {
		ExpenseDashboard dashboardData = new ExpenseDashboard();
		String tenantId = criteria.getTenantId();
		Long totalExpenses = repository.getTotalExpense(criteria);
		if (null != totalExpenses) {
			dashboardData.setTotalExpenditure(totalExpenses.toString());
		}
		Long paidAmount = repository.getPaidAmountDetails(criteria);
		if (null != paidAmount) {
			dashboardData.setAmountPaid(paidAmount.toString());
		}
		Long amountUnpaid = repository.getPendingAmount(criteria);
		if (null != amountUnpaid) {
			dashboardData.setAmountUnpaid(amountUnpaid.toString());
		}
		Long totalBills = repository.getTotalBill(criteria);
		if (null != totalBills) {
			dashboardData.setTotalBills(totalBills.toString());
		}
		Long billsPaid = repository.getBillsPaid(criteria);
		if (null != billsPaid) {
			dashboardData.setBillsPaid(billsPaid.toString());
		}
		Long pendingBills = repository.getPendingBills(criteria);
		if (null != pendingBills) {
			dashboardData.setPendingBills(pendingBills.toString());
		}
		Long electricityBill = repository.getElectricityBill(criteria);
		if (null != electricityBill) {
			dashboardData.setElectricityBill(electricityBill.toString());
		}
		Long omMisc = repository.getOmMiscBills(criteria);
		if (null != omMisc) {
			dashboardData.setOMMisc(omMisc.toString());
		}
		Long salary = repository.getSalary(criteria);
		if (null != salary) {
			dashboardData.setSalary(salary.toString());
		}
		
		return dashboardData;
	}

	public List<ChallanCollectionData> getChallanCollectionData(@Valid SearchCriteria criteria,
			RequestInfo requestInfo) {

		long endDate = criteria.getToDate();
		DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");

		LocalDate currentMonthDate = LocalDate.now();

		Calendar currentDate = Calendar.getInstance();
		int currentYear = currentDate.get(Calendar.YEAR);
		int actualMonthnum = currentDate.get(Calendar.MONTH);

		currentDate.setTimeInMillis(criteria.getFromDate());
		int actualYear = currentDate.get(Calendar.YEAR);

		int currentMonthNumber = currentDate.get(Calendar.MONTH);

		int totalMonthsTillDate;
		LocalDate finYearStarting;
		if (currentYear != actualYear && actualYear < currentYear) {
			totalMonthsTillDate = 11;
			currentMonthDate = LocalDate.of(currentDate.get(Calendar.YEAR), currentDate.get(Calendar.MONTH) + 1,
					currentDate.get(Calendar.DAY_OF_MONTH));
			finYearStarting = currentMonthDate;
		}else {
			totalMonthsTillDate = actualMonthnum - currentMonthNumber;
			currentMonthDate = LocalDate.of(currentDate.get(Calendar.YEAR), currentDate.get(Calendar.MONTH) + 1,
					currentDate.get(Calendar.DAY_OF_MONTH));
			finYearStarting = currentMonthDate;
		}
		ArrayList<ChallanCollectionData> data = new ArrayList<ChallanCollectionData>();

		for (int i = 0; i <= totalMonthsTillDate; i++) {
			LocalDate monthStart = currentMonthDate.minusMonths(0).with(TemporalAdjusters.firstDayOfMonth());
			LocalDate monthEnd = currentMonthDate.minusMonths(0).with(TemporalAdjusters.lastDayOfMonth());

			LocalDateTime monthStartDateTime = LocalDateTime.of(monthStart.getYear(), monthStart.getMonth(),
					monthStart.getDayOfMonth(), 0, 0, 0);
			LocalDateTime monthEndDateTime = LocalDateTime.of(monthEnd.getYear(), monthEnd.getMonth(),
					monthEnd.getDayOfMonth(), 23, 59, 59, 999000000);
			criteria.setFromDate((Long) monthStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());
			criteria.setToDate((Long) monthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());

			String tenantId = criteria.getTenantId();
			ChallanCollectionData challanData = new ChallanCollectionData();

			Long totalExpenses = repository.getTotalExpense(criteria);
			if (null != totalExpenses) {
				challanData.setTotalExpenditure(totalExpenses.toString());
			}
			Long paidAmount = repository.getPaidAmountDetails(criteria);
			if (null != paidAmount) {
				challanData.setAmountPaid(paidAmount.toString());
			}
			Long amountUnpaid = repository.getPendingAmount(criteria);
			if (null != amountUnpaid) {
				challanData.setAmountUnpaid(amountUnpaid.toString());
			}
			challanData.setMonth(criteria.getFromDate());
			data.add(i, challanData);
			System.out.println("collectionData:: " + challanData.toString());

			currentMonthDate = currentMonthDate.plusMonths(1);
		}
		return data;
	}
	
	public List<Challan> planeSearch(SearchCriteria criteria, RequestInfo requestInfo, Map<String, String> finalData){
        List<Challan> challans;
        
        List<Challan> challanList = getchallanPlainSearch(criteria, requestInfo, finalData);

//        challans = getChallansWithOwnerInfoForPlaneSearch(criteria,requestInfo, finalData);
       return challanList;
    }
	
	 private List<Challan> getchallanPlainSearch(SearchCriteria criteria, RequestInfo requestInfo,  Map<String, String> finalData) {
		 if (criteria.getLimit() != null && criteria.getLimit() > config.getMaxSearchLimit())
				criteria.setLimit(config.getMaxSearchLimit());
			List<Challan> listFSM = repository.getChallansForPlaneSearch(criteria, finalData);
			return listFSM;
	}

	public List<Challan> getChallansWithOwnerInfoForPlaneSearch(SearchCriteria criteria,RequestInfo requestInfo, Map<String, String> finalData){
		 List<Challan> challans = repository.getChallansForPlaneSearch(criteria, finalData);
	        if(challans.isEmpty())
	            return Collections.emptyList();
	        challans = enrichmentService.enrichChallanSearch(challans,criteria,requestInfo);
	        return challans;
	    }
	
}
