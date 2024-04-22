/**
 * 
 */
package org.egov.pg.service.gateways.sbi;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URI;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.crypto.spec.SecretKeySpec;

import org.egov.common.contract.request.RequestInfo;
import org.egov.common.contract.request.User;
import org.egov.pg.constants.PgConstants;
import org.egov.pg.models.Transaction;
import org.egov.pg.service.Gateway;
import org.egov.pg.utils.Utils;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

/**
 * @author @Vinoth
 *
 */
@Component
@Slf4j
public class SbiGateway implements Gateway {

	private static final String UNABLE_TO_FETCH_STATUS_FROM_SBI_GATEWAY = "Unable to fetch status from SBIEPAY gateway";
	private static final String UNABLE_TO_FETCH_STATUS = "UNABLE_TO_FETCH_STATUS";
	private static final String GATEWAY_NAME = "SBIEPAY";
	private final boolean ACTIVE;

	private final String MERCHANT_ID_KEY = "MerchantId";
	private final String AGRREGATOR_ID_KEY = "AggregatorId";
	private final String SUCCESS_URL = "SuccessURL";
	private final String FAIL_URL = "FailURL";
	private final String OPERATION_MODE_KEY = "OperatingMode";
	private final String MERCHANT_COUNTRY_KEY = "MerchantCountry";
	private final String MERCHANT_CURRENCY_KEY = "MerchantCurrency";
	private final String TOTAL_DUE_AMOUNT_KEY = "TotalDueAmount";
	private final String MERCHANT_ORDER_NO_KEY = "MerchantOrderNo";
	private final String MERCHANT_CUSTOMER_ID_KEY = "MerchantCustomerID";
	private final String PAYMENT_MODE_KEY = "Paymode";
	private final String ACCESS_MEDIUM_KEY = "Accesmedium";
	private final String TXN_SOURCE_KEY = "TransactionSource";
	private String SECRET_KEY = "key_Array";
	private final String OTHER_DETAILS = "Otherdetail";
	private final String MERCHANT_ID;
	private final String AGRREGATOR_ID;
	private final String OPERATION_MODE;
	private final String MERCHANT_COUNTRY;
	private final String MERCHANT_CURRENCY;
	private final String PAYMENT_MODE;
	private final String ACCESS_MEDIUM;
	private final String TXN_SOURCE;
	private static final String SEPERATOR = "|";
	private final String REDIRECT_URL;
	private final String ORIGINAL_RETURN_URL_KEY;
	private final String GATEWAY_TRANSACTION_STATUS_URL;
	private final String ecom;
	private final String CITIZEN_URL;

	private final RequestInfo requestInfo;


	/**
	 * Initialize by populating all required config parameters
	 *
	 * @param restTemplate rest template instance to be used to make REST calls
	 * @param environment  containing all required config parameters
	 */
	@Autowired
	public SbiGateway(Environment environment, ObjectMapper objectMapper) {
		ACTIVE = Boolean.valueOf(environment.getRequiredProperty("sbi.active"));
		MERCHANT_ID = environment.getRequiredProperty("sbi.merchant.id");
		AGRREGATOR_ID = environment.getRequiredProperty("sbi.aggregator.id");
		OPERATION_MODE = environment.getRequiredProperty("sbi.operation.mode");
		MERCHANT_CURRENCY = environment.getRequiredProperty("sbi.merchant.currency");
		MERCHANT_COUNTRY = environment.getRequiredProperty("sbi.merchant.country");
		PAYMENT_MODE = environment.getRequiredProperty("sbi.default.payment.mode");
		ACCESS_MEDIUM = environment.getRequiredProperty("sbi.access.medium");
		TXN_SOURCE = environment.getRequiredProperty("sbi.transaction.source");
		SECRET_KEY = environment.getRequiredProperty("sbi.secret.key");
		REDIRECT_URL = environment.getRequiredProperty("sbi.redirect.url");
		ORIGINAL_RETURN_URL_KEY = environment.getRequiredProperty("sbi.original.return.url.key");
		GATEWAY_TRANSACTION_STATUS_URL = environment.getRequiredProperty("sbi.gateway.status.url");
		CITIZEN_URL = environment.getRequiredProperty("egov.default.citizen.url");
		ecom = environment.getRequiredProperty("sbi.gateway.url");

		User userInfo = User.builder().uuid("PG_DETAIL_GET").type("SYSTEM").roles(Collections.emptyList()).id(0L)
				.build();

		requestInfo = new RequestInfo("", "", 0L, "", "", "", "", "", "", userInfo);
	}

	@Override
	public URI generateRedirectURI(Transaction transaction) {

		String returnUrl = transaction.getCallbackUrl().replace(CITIZEN_URL, "");
		String domainName = returnUrl.replaceAll("http(s)?://|www\\.|/.*", "");
		String citizenReturnURL = returnUrl.split(domainName)[1];
		log.info("returnUrl::::" + getReturnUrl(citizenReturnURL, REDIRECT_URL));

		HashMap<String, String> queryMap = new HashMap<>();
		queryMap.put(MERCHANT_ID_KEY, MERCHANT_ID);
		queryMap.put(OPERATION_MODE_KEY, OPERATION_MODE);
		queryMap.put(MERCHANT_COUNTRY_KEY, MERCHANT_COUNTRY);
		queryMap.put(MERCHANT_CURRENCY_KEY, MERCHANT_CURRENCY);
		queryMap.put(TOTAL_DUE_AMOUNT_KEY, String.valueOf(transaction.getTxnAmount()));
		queryMap.put(OTHER_DETAILS, "NA");
		queryMap.put(SUCCESS_URL, getReturnUrl(citizenReturnURL, REDIRECT_URL));
		queryMap.put(FAIL_URL, getReturnUrl(citizenReturnURL, REDIRECT_URL));
		queryMap.put(AGRREGATOR_ID_KEY, AGRREGATOR_ID);
		queryMap.put(MERCHANT_ORDER_NO_KEY, transaction.getTxnId());
		queryMap.put(MERCHANT_CUSTOMER_ID_KEY, transaction.getUser().getUuid());
		queryMap.put(PAYMENT_MODE_KEY, PAYMENT_MODE);
		queryMap.put(ACCESS_MEDIUM_KEY, ACCESS_MEDIUM);
		queryMap.put(TXN_SOURCE_KEY, TXN_SOURCE);

		// To Encrypt the request
		ArrayList<String> fields = new ArrayList<String>();
		fields.add(queryMap.get(MERCHANT_ID_KEY));
		fields.add(queryMap.get(OPERATION_MODE_KEY));
		fields.add(queryMap.get(MERCHANT_COUNTRY_KEY));
		fields.add(queryMap.get(MERCHANT_CURRENCY_KEY));
		fields.add(queryMap.get(TOTAL_DUE_AMOUNT_KEY));
		fields.add(queryMap.get(OTHER_DETAILS));
		fields.add(queryMap.get(SUCCESS_URL));
		fields.add(queryMap.get(FAIL_URL));
		fields.add(queryMap.get(AGRREGATOR_ID_KEY));
		fields.add(queryMap.get(MERCHANT_ORDER_NO_KEY));
		fields.add(queryMap.get(MERCHANT_CUSTOMER_ID_KEY));
		fields.add(queryMap.get(PAYMENT_MODE_KEY));
		fields.add(queryMap.get(ACCESS_MEDIUM_KEY));
		fields.add(queryMap.get(TXN_SOURCE_KEY));

		String message = String.join("|", fields);

		SecretKeySpec key = AES256Bit.readKeyBytes(SECRET_KEY);

		String singleParamResponse = AES256Bit.encrypt(message, key);

		MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
		queryMap.forEach(params::add);
		params.add("EncryptTrans", singleParamResponse);
		params.add("merchIdVal", queryMap.get(MERCHANT_ID_KEY));
		//Sample format of MultiAccountInstructionDtls: Amount|Currency|Unique Identifier
		//TODO: For PROD, the unique identifier should be change to village code
		String accountInfo = queryMap.get(TOTAL_DUE_AMOUNT_KEY) + SEPERATOR + queryMap.get(MERCHANT_CURRENCY_KEY) + SEPERATOR + "GRPT";
		String accountInfoEncrypt = AES256Bit.encrypt(accountInfo, key);
		queryMap.put("MultiAccountInstructionDtls", accountInfoEncrypt);
		queryMap.forEach(params::add);
		UriComponents uriComponents = UriComponentsBuilder.fromHttpUrl(ecom).queryParams(params).build();

		return uriComponents.toUri();
	}

	@Override
	public String generateRedirectFormData(Transaction transaction) {
		String urlData = null;
		String returnUrl = transaction.getCallbackUrl().replace(CITIZEN_URL, "");
		String domainName = returnUrl.replaceAll("http(s)?://|www\\.|/.*", "");
		String citizenReturnURL = returnUrl.split(domainName)[1];
		log.info("returnUrl::::" + getReturnUrl(citizenReturnURL, REDIRECT_URL));

		HashMap<String, String> queryMap = new HashMap<>();
		queryMap.put(MERCHANT_ID_KEY, MERCHANT_ID);
		queryMap.put(OPERATION_MODE_KEY, OPERATION_MODE);
		queryMap.put(MERCHANT_COUNTRY_KEY, MERCHANT_COUNTRY);
		queryMap.put(MERCHANT_CURRENCY_KEY, MERCHANT_CURRENCY);
		queryMap.put(TOTAL_DUE_AMOUNT_KEY, String.valueOf(transaction.getTxnAmount()));
		queryMap.put(OTHER_DETAILS, "^"+transaction.getTenantId().split("\\.")[1]+"^");
		queryMap.put(SUCCESS_URL, getReturnUrl(citizenReturnURL, REDIRECT_URL));
		queryMap.put(FAIL_URL, getReturnUrl(citizenReturnURL, REDIRECT_URL));
		queryMap.put(AGRREGATOR_ID_KEY, AGRREGATOR_ID);
		queryMap.put(MERCHANT_ORDER_NO_KEY, transaction.getTxnId());
		queryMap.put(MERCHANT_CUSTOMER_ID_KEY, transaction.getUser().getUuid());
		queryMap.put(PAYMENT_MODE_KEY, PAYMENT_MODE);
		queryMap.put(ACCESS_MEDIUM_KEY, ACCESS_MEDIUM);
		queryMap.put(TXN_SOURCE_KEY, TXN_SOURCE);

		// To Encrypt the request
		ArrayList<String> fields = new ArrayList<String>();
		fields.add(queryMap.get(MERCHANT_ID_KEY));
		fields.add(queryMap.get(OPERATION_MODE_KEY));
		fields.add(queryMap.get(MERCHANT_COUNTRY_KEY));
		fields.add(queryMap.get(MERCHANT_CURRENCY_KEY));
		fields.add(queryMap.get(TOTAL_DUE_AMOUNT_KEY));
		fields.add(queryMap.get(OTHER_DETAILS));
		fields.add(queryMap.get(SUCCESS_URL));
		fields.add(queryMap.get(FAIL_URL));
		fields.add(queryMap.get(AGRREGATOR_ID_KEY));
		fields.add(queryMap.get(MERCHANT_ORDER_NO_KEY));
		fields.add(queryMap.get(MERCHANT_CUSTOMER_ID_KEY));
		fields.add(queryMap.get(PAYMENT_MODE_KEY));
		fields.add(queryMap.get(ACCESS_MEDIUM_KEY));
		fields.add(queryMap.get(TXN_SOURCE_KEY));

		String message = String.join("|", fields);

		SecretKeySpec key = AES256Bit.readKeyBytes(SECRET_KEY);

		String singleParamResponse = AES256Bit.encrypt(message, key);

		queryMap.put("EncryptTrans", singleParamResponse);
		queryMap.put("merchIdVal", queryMap.get(MERCHANT_ID_KEY));
		//Sample format of MultiAccountInstructionDtls: Amount|Currency|Unique Identifier
		//TODO: For PROD, the unique identifier should be change to village code
		String accountInfo = queryMap.get(TOTAL_DUE_AMOUNT_KEY) + SEPERATOR + queryMap.get(MERCHANT_CURRENCY_KEY) + SEPERATOR + "GRPT";
		String accountInfoEncrypt = AES256Bit.encrypt(accountInfo, key);
		queryMap.put("MultiAccountInstructionDtls", accountInfoEncrypt);
		ObjectMapper mapper = new ObjectMapper();
		try {
			urlData = mapper.writeValueAsString(queryMap);
		} catch (Exception e) {
			log.error("SBI URL generation failed", e);
			throw new CustomException("URL_GEN_FAILED",
					"SBI URL generation failed, gateway redirect URI cannot be generated");
		}
		return urlData;
	}

	private String getReturnUrl(String callbackUrl, String baseurl) {
		return UriComponentsBuilder.fromHttpUrl(baseurl).queryParam(ORIGINAL_RETURN_URL_KEY, callbackUrl).build()
				.toUriString();
	}

	class RequestMsg {
		private String requestMsg;

		public RequestMsg() {

		}

		public RequestMsg(String msg) {
			this.requestMsg = msg;
		}

		public String getRequestMsg() {
			return requestMsg;
		}

		public void setRequestMsg(String requestMsg) {
			this.requestMsg = requestMsg;
		}

		@Override
		public String toString() {
			return "RequestMsg [requestMsg=" + requestMsg + "]";
		}

	}

	class QueryApiRequest {
		List<RequestMsg> queryApiRequest = new ArrayList<RequestMsg>();

		public List<RequestMsg> getQueryApiRequest() {
			return queryApiRequest;
		}

		public void setQueryApiRequest(List<RequestMsg> queryApiRequest) {
			this.queryApiRequest = queryApiRequest;
		}

		@Override
		public String toString() {
			return "QueryApiRequest [queryApiRequest=" + queryApiRequest + "]";
		}

	}

	@Override
	public Transaction fetchStatus(Transaction currentStatus, Map<String, String> param) {
		log.info("tx input " + currentStatus);
		try {
			return fetchTransaction(currentStatus);
		} catch (HttpStatusCodeException ex) {
			log.error("tx input " + currentStatus);
			log.error("Error code " + ex.getStatusCode());
			log.error("Error getResponseBodyAsString code " + ex.getResponseBodyAsString());
			log.error("Unable to fetch status from SBI gateway ", ex);
			throw new CustomException(UNABLE_TO_FETCH_STATUS, UNABLE_TO_FETCH_STATUS_FROM_SBI_GATEWAY);
		} catch (RestClientException e) {
			log.error("Unable to fetch status from SBI gateway ", e);
			throw new CustomException(UNABLE_TO_FETCH_STATUS, UNABLE_TO_FETCH_STATUS_FROM_SBI_GATEWAY);
		} catch (Exception e) {
			log.error("SBI Checksum validation failed ", e);
			throw new CustomException("GATEWAY_CONN_FAILED",
					"Error while connecting to SBI gateway");
		}
	}

	public Transaction fetchTransaction(Transaction currentStatus) {

		String responseCode = "";
		InputStream stream = null;
		InputStreamReader isr = null;
		BufferedReader reader = null;
		Transaction transaction = new Transaction();
		try {

			HashMap<String, String> params = new HashMap<String, String>();

			String merchantCode = MERCHANT_ID;
			String messageData;
			if(currentStatus.getGatewayTxnId() != null)
				messageData = currentStatus.getGatewayTxnId() + SEPERATOR + merchantCode + SEPERATOR + currentStatus.getTxnId() + SEPERATOR
					+ currentStatus.getTxnAmount();
			else
				messageData = SEPERATOR + merchantCode + SEPERATOR + currentStatus.getTxnId() + SEPERATOR + currentStatus.getTxnAmount();
			params.put("queryRequest", messageData);
			params.put("aggregatorId", "SBIEPAY");
			params.put("merchantId", merchantCode);
			log.info("messageData:::"+ messageData);
			URL url = new URL(GATEWAY_TRANSACTION_STATUS_URL);
			HttpURLConnection httpConn = (HttpURLConnection) url.openConnection();
			httpConn.setDoInput(true); // true indicates the server returns response

			StringBuffer requestParams = new StringBuffer();
			if (params != null && params.size() > 0) {
				httpConn.setDoOutput(true); // true indicates POST request
				// creates the params string, encode them using URLEncoder
				Iterator<String> paramIterator = params.keySet().iterator();
				while (paramIterator.hasNext()) {
					String key = paramIterator.next();
					String value = params.get(key);
					requestParams.append(URLEncoder.encode(key, "UTF-8"));
					requestParams.append("=").append(URLEncoder.encode(value, "UTF-8"));
					requestParams.append("&");
				}

				// sends POST data
				OutputStreamWriter writer = new OutputStreamWriter(httpConn.getOutputStream());
				writer.write(requestParams.toString());
				writer.flush();

				// Response Code
				log.info("Response Code:::" + httpConn.getResponseCode());

				// Reading Response
				stream = httpConn.getInputStream();
				isr = new InputStreamReader(stream);
				reader = new BufferedReader(isr);
				StringBuilder sb = new StringBuilder();
				String line = null;
				while ((line = reader.readLine()) != null)
					sb.append(line).append("\n");
				stream.close();
				responseCode = sb.toString();
				responseCode = responseCode.trim();
				log.info("response message::::" + responseCode);
				transaction = transformRawResponse(responseCode, currentStatus);
			}

		} catch (MalformedURLException e) {
			log.error("Invalid Query API URL", e);
			throw new CustomException("INVALID_URL",
					"Exception Occured in :: urlConnection() for " + GATEWAY_TRANSACTION_STATUS_URL);
		} catch (ProtocolException e) {
			log.error("Invalid protocol method", e);
			throw new CustomException("INVALID_PROTOCOL",
					"Exception Occured in :: urlConnection() for " + GATEWAY_TRANSACTION_STATUS_URL);
		} catch (IOException e) {
			log.error("Error occurred while the fetching the transaction status!!!!!", e);
			throw new CustomException("INVALID_INPUT",
					"Exception Occured in :: urlConnection() for " + GATEWAY_TRANSACTION_STATUS_URL);
		} finally {
			try {
				if (reader != null) {
					reader.close();
					reader = null;
				}

				if (isr != null) {
					isr.close();
					isr = null;
				}

				if (stream != null) {
					stream.close();
					stream = null;
				}
			} catch (Exception e) {
				log.error("Error occurred while the fetching the transaction status!!!!!", e);
				throw new CustomException("INVALID_INPUT",
						"Exception Occured in :: urlConnection() for " + GATEWAY_TRANSACTION_STATUS_URL);
			}
		}
		return transaction;
	}

	@Override
	public boolean isActive() {
		return ACTIVE;
	}

	@Override
	public String gatewayName() {
		return GATEWAY_NAME;
	}

	@Override
	public String transactionIdKeyInResponse() {
		return "vpc_MerchTxnRef";
	}

	/**
	 * Transform the Response string into PayGovGatewayStatusResponse object and
	 * return the transaction detail
	 * 
	 * @param resp
	 * @param currentStatus
	 * @param secretKey
	 * @return
	 * @throws JsonParseException
	 * @throws JsonMappingException
	 * @throws IOException
	 */
	private Transaction transformRawResponse(String resp, Transaction currentStatus)
			throws JsonParseException, JsonMappingException, IOException {
		log.debug("Response Data " + resp);
		if (resp != null) {

			String[] splitArray = resp.split("[|]");
			Transaction txStatus = null;
			SbiGatewayStatusResponse statusResponse = new SbiGatewayStatusResponse(splitArray[2]);
			int index = 0;
			statusResponse.setMerchantId(splitArray[++index]);
			statusResponse.setSbiePayRefId(splitArray[++index]);
			statusResponse.setTxnStatus(splitArray[++index]);
			statusResponse.setCountry(splitArray[++index]);
			statusResponse.setCuurency(splitArray[++index]);
			statusResponse.setOtherDetails(splitArray[++index]);
			statusResponse.setMerchantOrderNo(splitArray[++index]);
			statusResponse.setAmount(splitArray[++index]);
			statusResponse.setTxnStatusDesc(splitArray[++index]);
			statusResponse.setBankCode(splitArray[++index]);
			statusResponse.setBankReferenceNo(splitArray[++index]);
			statusResponse.setTransactionDate(splitArray[++index]);
			statusResponse.setPayMode(splitArray[++index]);
			statusResponse.setCin(splitArray[++index]);
			statusResponse.setMerchantId(splitArray[++index]);
			statusResponse.setTotalFeeGST(splitArray[++index]);
			statusResponse.setRef1(splitArray[++index]);
			statusResponse.setRef2(splitArray[++index]);
			statusResponse.setRef3(splitArray[++index]);
			statusResponse.setRef4(splitArray[++index]);
			statusResponse.setRef5(splitArray[++index]);
			statusResponse.setRef6(splitArray[++index]);
			statusResponse.setRef7(splitArray[++index]);
			statusResponse.setRef8(splitArray[++index]);
			statusResponse.setRef9(splitArray[++index]);
			statusResponse.setRef10(splitArray[++index]);
			switch (statusResponse.getTxnStatus()) {
			case "SUCCESS":
				/*
				 * For Success : Merchant ID|SBIePayRefID/ATRN|Transaction
				 * Status|Country|Currency|Other Details|MerchantOrderNumber|Amount|Status
				 * Description|BankCode|Bank Reference Number |Transaction Date|Pay
				 * Mode|CIN|Merchant ID|Total Fee
				 * GST|Ref1|Ref2|Ref3|Ref4|Ref5|Ref6|Ref7|Ref8|Ref9| Ref10
				 */
				/*
				 * Sample Response : 1000020|2011578958428|SUCCESS|IN|INR|Jay
				 * |2021033732021061519|5000|Payment Success|sbiepay|202116676766687 |2021-06-15
				 * 19:44:00|NB|10003202071961500074|1000020|45.00^8.10||||||||||
				 */

				// Build tx Response object
				txStatus = Transaction.builder().txnId(currentStatus.getTxnId())
						.txnAmount(Utils.formatAmtAsRupee(statusResponse.getAmount()))
						.txnStatus(Transaction.TxnStatusEnum.SUCCESS).txnStatusMsg(PgConstants.TXN_SUCCESS)
						.gatewayTxnId(statusResponse.getSbiePayRefId())
						.bankTransactionNo(statusResponse.getBankReferenceNo())
						.gatewayPaymentMode(statusResponse.getPayMode())
						.gatewayStatusCode(statusResponse.getTxnStatus())
						.gatewayStatusMsg(statusResponse.getTxnStatusDesc()).responseJson(resp).build();

				break;
			case "FAIL":
				/*
				 * For Failure : Merchant ID|SBIePayRefID/ATRN|Transaction
				 * Status|Country|Currency|Other Details|MerchantOrderNumber|Amount|Status
				 * Description|BankCode|Bank Reference Number |Transaction Date|Pay
				 * Mode|CIN|Merchant ID|Total Fee
				 * GST|Ref1|Ref2|Ref3|Ref4|Ref5|Ref6|Ref7|Ref8|Ref9| Ref10
				 */
				/*
				 * Sample Response : 1000020|2011578958428|FAIL|IN|INR|Jay
				 * |2021033732021061519|5000|Payment Failed|sbiepay|202116676766687 |2021-06-15
				 * 19:44:00|NB|10003202071961500074|1000020|45.00^8.10||||||||||
				 */

				// Build tx Response object
				txStatus = Transaction.builder().txnId(currentStatus.getTxnId())
						.txnAmount(Utils.formatAmtAsRupee(statusResponse.getAmount()))
						.txnStatus(Transaction.TxnStatusEnum.FAILURE).txnStatusMsg(statusResponse.getTxnStatusDesc())
						.gatewayTxnId(statusResponse.getSbiePayRefId())
						.bankTransactionNo(statusResponse.getBankReferenceNo())
						.gatewayPaymentMode(statusResponse.getPayMode())
						.gatewayStatusCode(statusResponse.getTxnStatus())
						.gatewayStatusMsg(statusResponse.getTxnStatusDesc()).responseJson(resp).build();
				break;
			case "PENDING":
				/*
				 * For pending :
				 * 1000720|4430840943731|PENDING|IN|INR|ABC^DEF^ERD|CH8809800|100|Pending for
				 * authorization|SBIN |G1312423|2018-06-24
				 * 16:30:24|NB|10002122018050922434|1000003|10.00^1.80|||||||||||
				 */

				// Build tx Response object
				txStatus = Transaction.builder().txnId(currentStatus.getTxnId())
						.txnStatus(Transaction.TxnStatusEnum.PENDING).txnStatusMsg(statusResponse.getTxnStatusDesc())
						.gatewayTxnId(statusResponse.getSbiePayRefId()).gatewayPaymentMode(statusResponse.getPayMode())
						.bankTransactionNo(statusResponse.getBankReferenceNo())
						.gatewayStatusCode(statusResponse.getTxnStatus())
						.gatewayStatusMsg(statusResponse.getTxnStatusDesc()).responseJson(resp).build();
				break;
			case "IN PROGRESS’":
				/*
				 * For in progress :
				 * 1000720|4430840943731|PENDING|IN|INR|ABC^DEF^ERD|CH8809800|100|Pending for
				 * authorization|SBIN |G1312423|2018-06-24
				 * 16:30:24|NB|10002122018050922434|1000003|10.00^1.80|||||||||||
				 */

				// Build tx Response object
				txStatus = Transaction.builder().txnId(currentStatus.getTxnId())
						.txnStatus(Transaction.TxnStatusEnum.PENDING).txnStatusMsg(statusResponse.getTxnStatusDesc())
						.gatewayTxnId(statusResponse.getSbiePayRefId()).gatewayPaymentMode(statusResponse.getPayMode())
						.bankTransactionNo(statusResponse.getBankReferenceNo())
						.gatewayStatusCode(statusResponse.getTxnStatus())
						.gatewayStatusMsg(statusResponse.getTxnStatusDesc()).responseJson(resp).build();
				break;
			case "ABORT":
				/*
				 * For Initiated :
				 * 1000720|4430840943731|ABORT|IN|INR|ABC^DEF^ERD|CH8809800|100|Your session has
				 * expired. Please re-attempt the transaction |SBIN|G1312423|2018-06-24
				 * 16:30:24|CC|10002122018050922434|1000003|10.00^1.80|||||||||||
				 */
				// Build tx Response object
				txStatus = Transaction.builder().txnId(currentStatus.getTxnId())
						.txnAmount(Utils.formatAmtAsRupee(statusResponse.getAmount()))
						.txnStatus(Transaction.TxnStatusEnum.FAILURE).txnStatusMsg(statusResponse.getTxnStatusDesc())
						.gatewayTxnId(statusResponse.getSbiePayRefId())
						.bankTransactionNo(statusResponse.getBankReferenceNo())
						.gatewayPaymentMode(statusResponse.getPayMode())
						.gatewayStatusCode(statusResponse.getTxnStatus())
						.gatewayStatusMsg(statusResponse.getTxnStatusDesc()).responseJson(resp).build();
				break;
			case "NO RECORDS FOUND":
				/*
				 * 1000720|4430840943731|NO RECORDS FOUND|IN|INR|ABC^DEF^ERD|CH8809800|100|No
				 * records found |SBIN|G1312423|2018-06-24
				 * 16:30:24|NB|10002122018050922434|1000003|10.00^1.80|||||||||||
				 */

				// Build tx Response object
				txStatus = Transaction.builder().txnId(currentStatus.getTxnId())
						.txnAmount(Utils.formatAmtAsRupee(statusResponse.getAmount()))
						.txnStatus(Transaction.TxnStatusEnum.FAILURE).txnStatusMsg(statusResponse.getTxnStatusDesc())
						.gatewayTxnId(statusResponse.getSbiePayRefId())
						.bankTransactionNo(statusResponse.getBankReferenceNo())
						.gatewayPaymentMode(statusResponse.getPayMode())
						.gatewayStatusCode(statusResponse.getTxnStatus())
						.gatewayStatusMsg(statusResponse.getTxnStatusDesc()).responseJson(resp).build();
				break;
			case "EXPIRED":
				/*
				 * 1000720|4430840943731|EXPIRED|IN|INR|ABC^DEF^ERD|CH8809800|100|Transaction
				 * expired |SBIN|G1312423|2018-06-24
				 * 16:30:24|NB|10002122018050922434|1000003|10.00^1.80|||||||||||
				 */

				// Build tx Response object
				txStatus = Transaction.builder().txnId(currentStatus.getTxnId())
						.txnAmount(Utils.formatAmtAsRupee(statusResponse.getAmount()))
						.txnStatus(Transaction.TxnStatusEnum.FAILURE).txnStatusMsg(statusResponse.getTxnStatusDesc())
						.gatewayTxnId(statusResponse.getSbiePayRefId())
						.bankTransactionNo(statusResponse.getBankReferenceNo())
						.gatewayPaymentMode(statusResponse.getPayMode())
						.gatewayStatusCode(statusResponse.getTxnStatus())
						.gatewayStatusMsg(statusResponse.getTxnStatusDesc()).responseJson(resp).build();
				break;
			case "CANCELLED":
				/*
				 * 1000720|4430840943731|CANCELLED|IN|INR|ABC^DEF^ERD|CH8809800|100|Transaction
				 * Cancelled |SBIN|G1312423|2018-06-24
				 * 16:30:24|NB|10002122018050922434|1000003|10.00^1.80|||||||||||
				 */

				// Build tx Response object
				txStatus = Transaction.builder().txnId(currentStatus.getTxnId())
						.txnAmount(Utils.formatAmtAsRupee(statusResponse.getAmount()))
						.txnStatus(Transaction.TxnStatusEnum.FAILURE).txnStatusMsg(statusResponse.getTxnStatusDesc())
						.gatewayTxnId(statusResponse.getSbiePayRefId())
						.bankTransactionNo(statusResponse.getBankReferenceNo())
						.gatewayPaymentMode(statusResponse.getPayMode())
						.gatewayStatusCode(statusResponse.getTxnStatus())
						.gatewayStatusMsg(statusResponse.getTxnStatusDesc()).responseJson(resp).build();
				break;

			default:
				throw new CustomException(UNABLE_TO_FETCH_STATUS, "Unable to fetch Status of transaction");
			}
			log.info("Encoded value " + resp);
			log.info("PayGovGatewayStatusResponse --> " + statusResponse);
			log.info("Transaction --> " + txStatus);
			return txStatus;
		} else {
			log.error("Received error response from status call : " + resp);
			throw new CustomException(UNABLE_TO_FETCH_STATUS, UNABLE_TO_FETCH_STATUS_FROM_SBI_GATEWAY);
		}
	}
}
