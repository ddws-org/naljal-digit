package org.egov.wscalculation.validator;

import lombok.extern.slf4j.Slf4j;
import org.egov.tracer.model.CustomException;
import org.egov.wscalculation.constants.WSCalculationConstant;
import org.egov.wscalculation.repository.WSCalculationDao;
import org.egov.wscalculation.service.MasterDataService;
import org.egov.wscalculation.util.CalculatorUtil;
import org.egov.wscalculation.web.models.MeterConnectionRequest;
import org.egov.wscalculation.web.models.MeterReading;
import org.egov.wscalculation.web.models.MeterReadingSearchCriteria;
import org.egov.wscalculation.web.models.WaterConnection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.Month;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.time.temporal.TemporalAccessor;
import java.util.*;

@Component
@Slf4j
public class WSCalculationValidator {

	@Autowired
	private WSCalculationDao wSCalculationDao;
	
	@Autowired
	private CalculatorUtil calculationUtil;
	
	@Autowired
	private MasterDataService masterDataService;
	


	/**
	 * 
	 * @param meterConnectionRequest
	 *            meterReadingConnectionRequest is request for create or update
	 *            meter reading connection
	 * @param isUpdate
	 *            True for create
	 */
	public void validateMeterReading(MeterConnectionRequest meterConnectionRequest, boolean isUpdate) {
		MeterReading meterReading = meterConnectionRequest.getMeterReading();
		Map<String, String> errorMap = new HashMap<>();

		// Future Billing Period Check
		validateBillingPeriod(meterReading.getBillingPeriod());
  
		List<WaterConnection> waterConnectionList = calculationUtil.getWaterConnection(meterConnectionRequest.getRequestInfo(),
				meterReading.getConnectionNo(), meterConnectionRequest.getMeterReading().getTenantId());
		WaterConnection connection = null;
		if(waterConnectionList != null){
			int size = waterConnectionList.size();
			connection = waterConnectionList.get(size-1);
		}

		if (meterConnectionRequest.getMeterReading().getGenerateDemand() && connection == null) {
			errorMap.put("INVALID_METER_READING_CONNECTION_NUMBER", "Invalid water connection number");
		}
		if (connection != null
				&& !WSCalculationConstant.meteredConnectionType.equalsIgnoreCase(connection.getConnectionType())) {
			errorMap.put("INVALID_WATER_CONNECTION_TYPE",
					"Meter reading can not be create for : " + connection.getConnectionType() + " connection");
		}
		Set<String> connectionNos = new HashSet<>();
		connectionNos.add(meterReading.getConnectionNo());
		MeterReadingSearchCriteria criteria = MeterReadingSearchCriteria.builder().
				connectionNos(connectionNos).tenantId(meterReading.getTenantId()).build();
		List<MeterReading> previousMeterReading = wSCalculationDao.searchCurrentMeterReadings(criteria);
		if (!CollectionUtils.isEmpty(previousMeterReading)) {
			Double currentMeterReading = previousMeterReading.get(0).getCurrentReading();
			if (meterReading.getCurrentReading() < currentMeterReading) {
				errorMap.put("INVALID_METER_READING_CONNECTION_NUMBER",
						"Current meter reading has to be greater than the past last readings in the meter reading!");
			}
		}

		if (meterReading.getCurrentReading() < meterReading.getLastReading()) {
			errorMap.put("INVALID_METER_READING_LAST_READING",
					"Current Meter Reading cannot be less than last meter reading");
		}
		
		if (meterReading.getCurrentReadingDate().equals(meterReading.getLastReadingDate())) {
			errorMap.put("INVALID_METER_READING_DATE",
					"Current Meter Reading Date cannot be same as last meter reading date");
		}

		if (StringUtils.isEmpty(meterReading.getMeterStatus())) {
			errorMap.put("INVALID_METER_READING_STATUS", "Meter status can not be null");
		}

		if (isUpdate && (meterReading.getCurrentReading() == null)) {
			errorMap.put("INVALID_CURRENT_METER_READING",
					"Current Meter Reading cannot be update without current meter reading");
		}

		if (isUpdate && !StringUtils.isEmpty(meterReading.getId())) {
			int n = wSCalculationDao.isMeterReadingConnectionExist(Arrays.asList(meterReading.getId()));
			if (n > 0) {
				errorMap.put("INVALID_METER_READING_CONNECTION", "Meter reading Id already present");
			}
		}
		
		if (StringUtils.isEmpty(meterReading.getBillingPeriod())) {
			errorMap.put("INVALID_BILLING_PERIOD", "Meter Reading cannot be updated without billing period");
		}

		SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
		Date billingStrartDate = null;
		Date billingEndDate = null;
		Calendar startCal = Calendar.getInstance();

		Calendar endCal = Calendar.getInstance();
		try {
			billingStrartDate = sdf.parse(meterReading.getBillingPeriod().split("-")[0].trim());
			billingEndDate = sdf.parse(meterReading.getBillingPeriod().split("-")[1].trim());
			startCal.setTime(billingStrartDate);
			endCal.setTime(billingEndDate);
		} catch (ParseException e) {
			e.printStackTrace();
			errorMap.put("INVALID_BILLING_PERIOD", "Meter Reading cannot be updated without billing period");
		}
		if (startCal.getTimeInMillis() > endCal.getTimeInMillis()) {
			errorMap.put("INVALID_BILLING_PERIOD", "Billing period Start can not be greater than End date");
		} else {
			meterReading.setLastReadingDate(startCal.getTimeInMillis());
			meterReading.setCurrentReadingDate(endCal.getTimeInMillis());
		}
		
		int billingPeriodNumber = wSCalculationDao.isBillingPeriodExists(meterReading.getConnectionNo(),
				meterReading.getBillingPeriod());
		if (billingPeriodNumber > 0)
			errorMap.put("INVALID_METER_READING_BILLING_PERIOD", "Billing Period Already Exists");

		if (!errorMap.isEmpty()) {
			throw new CustomException(errorMap);
		}
	}
	
	/**
	 * Billing Period Validation
	 */
	public void validateBillingPeriod(String billingPeriod) {
		if (StringUtils.isEmpty(billingPeriod))
			 throw new CustomException("BILLING_PERIOD_PARSING_ISSUE", "Billing can not empty!!");
		try {
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
			ZoneId defaultZoneId = ZoneId.systemDefault();
			Date billingDate = sdf.parse(billingPeriod.split("-")[1].trim());
			Instant instant = billingDate.toInstant();
			LocalDate billingLocalDate = instant.atZone(defaultZoneId).toLocalDate();
			LocalDate localDateTime = LocalDate.now();
			if ((billingLocalDate.getYear() == localDateTime.getYear())
					&& (billingLocalDate.getMonthValue() > localDateTime.getMonthValue())) {
				throw new CustomException("BILLING_PERIOD_ISSUE", "Billing period can not be in future!!");
			}
			if ((billingLocalDate.getYear() > localDateTime.getYear())) {
				throw new CustomException("BILLING_PERIOD_ISSUE", "Billing period can not be in future!!");
			}

		} catch (CustomException | ParseException ex) {
			log.error("", ex);
			if (ex instanceof CustomException)
				throw new CustomException("BILLING_PERIOD_ISSUE", "Billing period can not be in future!!");
			throw new CustomException("BILLING_PERIOD_PARSING_ISSUE", "Billing period can not parsed!!");
		}
	}
	
	public void validateBulkDemandBillingPeriod(Long startTime, Long endTime, Set<String> connectionNos,
			String tenantId, String billingFrequency) {
		DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");

		Calendar startCal = Calendar.getInstance();
		startCal.setTimeInMillis(startTime);
		Calendar endCal = Calendar.getInstance();
		endCal.setTimeInMillis(endTime);
		System.out.println(formatter.format(startCal.getTime()));
		if (billingFrequency.equalsIgnoreCase(WSCalculationConstant.Monthly_Billing_Period)) {
			startCal.add(Calendar.MONTH, -1);

			endCal.add(Calendar.MONTH, -1);
			int max = endCal.getActualMaximum(Calendar.DAY_OF_MONTH);
			endCal.set(Calendar.DAY_OF_MONTH, max);
			setTimeToEndofDay(endCal);
			// to do get the end date also and make the month -1 and time 23 h 59m 59 s and
			// start date time would b 0
//				startCal.set(Calendar.DAY_OF_MONTH, 15);
		} else if (billingFrequency.equalsIgnoreCase(WSCalculationConstant.Quaterly_Billing_Period)) {
			startCal.add(Calendar.MONTH, -3);
			endCal.add(Calendar.MONTH, -3);
			int max = endCal.getActualMaximum(Calendar.DAY_OF_MONTH);
			endCal.set(Calendar.DAY_OF_MONTH, max);
			setTimeToEndofDay(endCal);
//				startCal.set(Calendar.DAY_OF_MONTH, 15);
		}
		startTime = startCal.getTimeInMillis();
		endTime = endCal.getTimeInMillis();
		System.out.println("StartTime to check the billing period::" + startTime);
		System.out.println("endTime to check the billing period::" + endTime);
		
		if (!wSCalculationDao.isDemandExists(tenantId, startTime, endTime, connectionNos)) {
			if (!wSCalculationDao.isConnectionExists(tenantId, startTime, endTime, connectionNos)) {

				Month month = Month.of(startCal.get(Calendar.MONTH) + 1);
				Locale locale = Locale.getDefault();
				throw new CustomException("NO_DEMAND_PREVIOUS_BILLING_CYCLE",
						"No Demand exists for previous billing cycle, please generated demand for previous billing cycle ("
								+ month.getDisplayName(TextStyle.FULL, locale) + ")!!");
			}
			
//			Select * from eg_ws_connection where priviousmeterreadingdate between starttime and endtime and tenantid=tenatID and connectionno IN (connectionnos);
//			if()
			
		}

	}
	

	public static void setTimeToEndofDay(Calendar calendar) {
	    calendar.set(Calendar.HOUR_OF_DAY, 23);
	    calendar.set(Calendar.MINUTE, 59);
	    calendar.set(Calendar.SECOND, 59);
	    calendar.set(Calendar.MILLISECOND, 999);
	}
}
