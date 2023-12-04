package org.egov.wscalculation.service;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.egov.wscalculation.constants.WSCalculationConstant;
import org.egov.wscalculation.web.models.TaxHeadEstimate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import net.minidev.json.JSONArray;

@Service
public class PayService {

	@Autowired
	private MasterDataService mDService;
	
	@Autowired
	private EstimationService estimationService;

	/**
	 * Decimal is ceiled for all the tax heads
	 * 
	 * if the decimal is greater than 0.5 upper bound will be applied
	 * 
	 * else if decimal is lesser than 0.5 lower bound is applied
	 * 
	 */
	public TaxHeadEstimate roundOfDecimals(BigDecimal creditAmount, BigDecimal debitAmount, boolean isConnectionFee) {
		BigDecimal roundOffPos = BigDecimal.ZERO;
		BigDecimal roundOffNeg = BigDecimal.ZERO;
        String taxHead = isConnectionFee ? WSCalculationConstant.WS_Round_Off : WSCalculationConstant.WS_ONE_TIME_FEE_ROUND_OFF;
		BigDecimal result = creditAmount.add(debitAmount);
		BigDecimal roundOffAmount = result.setScale(2, 2);
		BigDecimal reminder = roundOffAmount.remainder(BigDecimal.ONE);

		if (reminder.doubleValue() >= 0.5)
			roundOffPos = roundOffPos.add(BigDecimal.ONE.subtract(reminder));
		else if (reminder.doubleValue() < 0.5)
			roundOffNeg = roundOffNeg.add(reminder).negate();

		if (roundOffPos.doubleValue() > 0)
			return TaxHeadEstimate.builder().estimateAmount(roundOffPos).taxHeadCode(taxHead)
					.build();
		else if (roundOffNeg.doubleValue() < 0)
			return TaxHeadEstimate.builder().estimateAmount(roundOffNeg).taxHeadCode(taxHead)
					.build();
		else
			return null;
	}
	
	/**
	 * 
	 * @param waterCharge - Water Charge Amount
	 * @param assessmentYear - Assessment Year
	 * @param timeBasedExemptionMasterMap - Time Based Exemption Master Data
	 * @param billingExpiryDate - Billing Expiry Date
	 * @return estimation of time based exemption
	 */
	public Map<String, BigDecimal> applyPenaltyRebateAndInterest(BigDecimal waterCharge,
			String assessmentYear,Map<String, Object> penaltyMaster, Long billingExpiryDate, 
			boolean isGetPenaltyEstimate, int demandListSize) {

		if (BigDecimal.ZERO.compareTo(waterCharge) >= 0)
			return Collections.emptyMap();
		Map<String, BigDecimal> estimates = new HashMap<>();
		long currentUTC = System.currentTimeMillis();
		long numberOfDaysInMillis = billingExpiryDate - currentUTC;
		BigDecimal noOfDays = BigDecimal.valueOf((TimeUnit.MILLISECONDS.toDays(Math.abs(numberOfDaysInMillis))));
		if(BigDecimal.ONE.compareTo(noOfDays) <= 0) noOfDays = noOfDays.add(BigDecimal.ONE);
		BigDecimal penaltyType = getApplicablePenalty(waterCharge, noOfDays,penaltyMaster,isGetPenaltyEstimate,demandListSize);
		BigDecimal interest = getApplicableInterest(waterCharge, noOfDays, penaltyMaster);
		estimates.put(WSCalculationConstant.WS_TIME_PENALTY, penaltyType.setScale(2, 2));
		estimates.put(WSCalculationConstant.WS_TIME_INTEREST, interest.setScale(2, 2));
		return estimates;
	}

	/**
	 * Returns the Amount of penalty that has to be applied on the given tax amount for the given period
	 * 
	 * @param taxAmt - Tax Amount
	 * @param assessmentYear - Assessment Year
	 * @return applicable penalty for given time
	 */
	public BigDecimal getPenalty(BigDecimal taxAmt, String assessmentYear, JSONArray penaltyMasterList, BigDecimal noOfDays) {

		BigDecimal penaltyAmt = BigDecimal.ZERO;
		Map<String, Object> penalty = mDService.getApplicableMaster(assessmentYear, penaltyMasterList);
		if (null == penalty) return penaltyAmt;
			penaltyAmt = mDService.calculateApplicable(taxAmt, penalty);
		return penaltyAmt;
	}
	
	/**
	 * 
	 * @param waterCharge - Water Charge amount
	 * @param noOfDays - No.Of.Days
	 * @param config
	 *            master configuration
	 * @return applicable penalty
	 */
	public BigDecimal getApplicablePenalty(BigDecimal waterCharge, BigDecimal noOfDays, Map<String, Object> penaltyMaster
			, boolean isGetPenaltyEstimate, int demandListSize) {

		BigDecimal applicablePenalty = BigDecimal.ZERO;

		String type = (String) penaltyMaster.get(WSCalculationConstant.TYPE_FIELD_NAME);
		String subType = (String) penaltyMaster.get(WSCalculationConstant.SUBTYPE_FIELD_NAME);
		
		if (null == penaltyMaster) {
			return applicablePenalty;
		}
		BigDecimal daysApplicable = null != penaltyMaster.get(WSCalculationConstant.DAYS_APPLICABLE_NAME)
				? BigDecimal.valueOf(((Number) penaltyMaster.get(WSCalculationConstant.DAYS_APPLICABLE_NAME)).intValue())
				: null;
		if (daysApplicable == null) {
			return applicablePenalty;	
		}
			
		if(!isGetPenaltyEstimate) {
			BigDecimal daysDiff = noOfDays.subtract(daysApplicable);
			if (daysDiff.compareTo(BigDecimal.ONE) < 0) {
				return applicablePenalty;
			}
		}
		
		
		BigDecimal rate = null != penaltyMaster.get(WSCalculationConstant.RATE_FIELD_NAME)
				? BigDecimal.valueOf(((Number) penaltyMaster.get(WSCalculationConstant.RATE_FIELD_NAME)).doubleValue())
				: null;

		BigDecimal flatAmt = null != penaltyMaster.get(WSCalculationConstant.FLAT_AMOUNT_FIELD_NAME)
				? BigDecimal
						.valueOf(((Number) penaltyMaster.get(WSCalculationConstant.FLAT_AMOUNT_FIELD_NAME)).doubleValue())
				: BigDecimal.ZERO;
		
		BigDecimal amount = null != penaltyMaster.get(WSCalculationConstant.AMOUNT_FIELD_NAME)
				? BigDecimal
						.valueOf(((Number) penaltyMaster.get(WSCalculationConstant.AMOUNT_FIELD_NAME)).doubleValue())
				: null;
		
		applicablePenalty = calculateApplicablePenaltyAmount(waterCharge, type, subType, rate, flatAmt, amount,demandListSize);
		
		
		
		return applicablePenalty;
	}

	private BigDecimal calculateApplicablePenaltyAmount(BigDecimal waterCharge, String type, String subType, BigDecimal rate,
			BigDecimal flatAmt, BigDecimal amount, int demandListSize) {
		BigDecimal applicablePenalty = BigDecimal.ZERO;
		if(WSCalculationConstant.FIXED.equalsIgnoreCase(type) && rate != null) {
			if(WSCalculationConstant.PENALTY_CURRENT_MONTH.equalsIgnoreCase(subType)
					|| WSCalculationConstant.PENALTY_OUTSTANDING.equalsIgnoreCase(subType)
					|| WSCalculationConstant.OUTSTANDING.equalsIgnoreCase(subType)) {
				applicablePenalty = waterCharge.multiply(rate.divide(WSCalculationConstant.HUNDRED));

			}

		}
		if(WSCalculationConstant.FLAT.equalsIgnoreCase(type) && amount != null) {
			if(WSCalculationConstant.PENALTY_CURRENT_MONTH.equalsIgnoreCase(subType)) {
				applicablePenalty = amount;
			}
			if(WSCalculationConstant.PENALTY_OUTSTANDING.equalsIgnoreCase(subType)) {
				applicablePenalty = amount.multiply(new BigDecimal(demandListSize));

			}
		}
//		else {
//			applicablePenalty = flatAmt.compareTo(waterCharge) > 0 ? BigDecimal.ZERO : flatAmt;
//		}
		return applicablePenalty;
	}
	
	/**
	 * 
	 * @param waterCharge - Water Charge
	 * @param noOfDays - No.Of Days value
	 * @param config
	 *            master configuration
	 * @return applicable Interest
	 */
	public BigDecimal getApplicableInterest(BigDecimal waterCharge, BigDecimal noOfDays, Map<String, Object> interestMaster) {
		BigDecimal applicableInterest = BigDecimal.ZERO;
		if (null == interestMaster) return applicableInterest;
		BigDecimal daysApplicable = null != interestMaster.get(WSCalculationConstant.DAYS_APPLICABLE_NAME)
				? BigDecimal.valueOf(((Number) interestMaster.get(WSCalculationConstant.DAYS_APPLICABLE_NAME)).intValue())
				: null;
		if (daysApplicable == null)
			return applicableInterest;
		BigDecimal daysDiff = noOfDays.subtract(daysApplicable);
		if (daysDiff.compareTo(BigDecimal.ONE) < 0) {
			return applicableInterest;
		}
		BigDecimal rate = null != interestMaster.get(WSCalculationConstant.RATE_FIELD_NAME)
				? BigDecimal.valueOf(((Number) interestMaster.get(WSCalculationConstant.RATE_FIELD_NAME)).doubleValue())
				: null;

		BigDecimal flatAmt = null != interestMaster.get(WSCalculationConstant.FLAT_AMOUNT_FIELD_NAME)
				? BigDecimal
						.valueOf(((Number) interestMaster.get(WSCalculationConstant.FLAT_AMOUNT_FIELD_NAME)).doubleValue())
				: BigDecimal.ZERO;

		if (rate == null)
			applicableInterest = flatAmt.compareTo(waterCharge) > 0 ? BigDecimal.ZERO : flatAmt;
		else{
			// rate of interest
			applicableInterest = waterCharge.multiply(rate.divide(WSCalculationConstant.HUNDRED));
		}
		//applicableInterest.multiply(noOfDays.divide(BigDecimal.valueOf(365), 6, 5));
		return applicableInterest;
	}
}
