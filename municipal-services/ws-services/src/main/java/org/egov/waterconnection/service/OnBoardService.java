package org.egov.waterconnection.service;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.egov.common.contract.request.RequestInfo;
import org.egov.common.contract.request.Role;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.config.WSConfiguration;
import org.egov.waterconnection.constants.WCConstants;
import org.egov.waterconnection.repository.ServiceRequestRepository;
import org.egov.waterconnection.util.NotificationUtil;
import org.egov.waterconnection.util.WaterServicesUtil;
import org.egov.waterconnection.web.models.Action;
import org.egov.waterconnection.web.models.Category;
import org.egov.waterconnection.web.models.Event;
import org.egov.waterconnection.web.models.EventRequest;
import org.egov.waterconnection.web.models.OnBoardResponse;
import org.egov.waterconnection.web.models.OwnerInfo;
import org.egov.waterconnection.web.models.Property;
import org.egov.waterconnection.web.models.Recepient;
import org.egov.waterconnection.web.models.RequestInfoWrapper;
import org.egov.waterconnection.web.models.SMSRequest;
import org.egov.waterconnection.web.models.Source;
import org.egov.waterconnection.web.models.WaterConnectionRequest;
import org.egov.waterconnection.web.models.collection.PaymentDetail;
import org.egov.waterconnection.web.models.users.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class OnBoardService {

	@Autowired
	private UserService userService;

	static char[] SYMBOLS = "@#&%".toCharArray();
    static char[] LOWERCASE = "abcdefghijklmnopqrstuvwxyz".toCharArray();
    static char[] UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();
    static char[] NUMBERS = "0123456789".toCharArray();
    static char[] ALL_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#&%".toCharArray();
    static Random rand = new SecureRandom();



	public enum Gender {
	    //This order should not be interrupted
	    FEMALE, MALE, TRANSGENDER;
	}
	
	public HashMap<String,String> process(MultipartFile file, RequestInfoWrapper requestInfoWraper) {
		HashMap<String,String> errorMap = new HashMap<String,String>();
		try {
			if (file.isEmpty()) {
				throw new CustomException("ONBOARD_FILE_ERROR", "Failed to read empty file.");
			}

			try (InputStream inputStream = file.getInputStream()) {
//				FileInputStream file1 = new FileInputStream(file.getResource().getFile());
				Workbook workbook = new XSSFWorkbook(inputStream);
				Sheet sheet = workbook.getSheetAt(0);

				Iterator<Row> iterator = workbook.getSheetAt(0).iterator();

				List<OwnerInfo> userslist = new ArrayList<OwnerInfo>();
				while (iterator.hasNext()) {

					OwnerInfo user = new OwnerInfo();

					Row currentRow = iterator.next();

					// don't read the header
					if (currentRow.getRowNum() <= 1) {
						continue;
					}

					Iterator<Cell> cellIterator = currentRow.iterator();

					while (cellIterator.hasNext()) {

						Cell currentCell = cellIterator.next();
						CellAddress address = currentCell.getAddress();
						String tenantId = null,roleTenantId=null;
						if (1 == address.getColumn()) {
							// 1st col is "tenantId"
							tenantId = currentCell.getStringCellValue();
							roleTenantId = tenantId.toLowerCase();
							if (!StringUtils.isEmpty(tenantId)) {
								tenantId = tenantId.split("\\.")[0];
							} else {
								throw new CustomException("ONBOARD_NOT_FOUND", "Invalid tenantid");
							}
							user.setTenantId(tenantId);
						} else if (2 == address.getColumn()) {
							// 2nd col is "User Name"
							String name  = currentCell.getStringCellValue();
							user.setName(name);
						} else if (3 == address.getColumn()) {
							// 3rd col is "mobileNumber"
							String mobileNumber  = currentCell.getStringCellValue();
							user.setMobileNumber(mobileNumber);
						} else if (4 == address.getColumn()) {
							// 4th col is "fatherOrHusbandName"
							String fatherOrHusbandName  = currentCell.getStringCellValue();
							user.setFatherOrHusbandName(fatherOrHusbandName);
						} else if (5 == address.getColumn()) {
							// 5th col is "Gender"
							String gender  = currentCell.getStringCellValue();
							if(StringUtils.isEmpty(gender) || !gender.equalsIgnoreCase(Gender.FEMALE.name()) || 
									!gender.equalsIgnoreCase(Gender.MALE.name()) || 
									!gender.equalsIgnoreCase(Gender.TRANSGENDER.name())  ) {
								gender = Gender.MALE.toString();
							}
							user.setGender( gender);
						} else if (6 == address.getColumn()) {
							// 6th col is "emalid"
							String emailId  = currentCell.getStringCellValue();
							user.setEmailId( emailId);
						} else if (7 == address.getColumn()) {
							// 7th col is "dob"
							Long datetime = currentCell.getDateCellValue() == null ? 0l : currentCell.getDateCellValue().getTime();
							user.setDob(datetime);
//							user.setDob(currentCell.getStringCellValue());
						} else if (8 == address.getColumn()) {
							// 8th col is "Type"
//							user.put("type", currentCell.getStringCellValue());
						} else if (9 == address.getColumn()) {
							// 9th col is "Role1"
							user.setRoles( new ArrayList<Role>());
							Role role = new Role();
							role.setCode( currentCell.getStringCellValue());
							role.setTenantId( roleTenantId);
							user.getRoles().add(role);
						} else if (11 == address.getColumn()) {
							// 11th col is "Role2"
							if (user.getRoles() == null) {
								user.setRoles( new ArrayList<Role>());
							}

							Role role = new Role();
							role.setCode( currentCell.getStringCellValue());
							role.setTenantId( roleTenantId);
							user.getRoles().add(role);
						}

					}
					user.setPassword(getPassword(8));
					userslist.add(user);

				}

				if (userslist.size() > 0) {
					errorMap = userService.OnBoardEmployee(requestInfoWraper, userslist);
				}else {
					throw new CustomException("ONBOARD_NOT_FOUND", "No Employee data to onboard");
				}
				
				
			}

		} catch (IOException e) {
			throw new CustomException("ONBOARD_FILE_ERROR", "Failed to store file.");
		}

		return errorMap;
	}

	/**
	 * generate the Radom password for the length specific
	 * @param len - length of the password to generated
	 * @return
	 */
	public static String getPassword(int length) {
        assert length >= 4;
        char[] password = new char[length];

        //get the requirements out of the way
        password[0] = LOWERCASE[rand.nextInt(LOWERCASE.length)];
        password[1] = UPPERCASE[rand.nextInt(UPPERCASE.length)];
        password[2] = NUMBERS[rand.nextInt(NUMBERS.length)];
        password[3] = SYMBOLS[rand.nextInt(SYMBOLS.length)];

        //populate rest of the password with random chars
        for (int i = 4; i < length; i++) {
            password[i] = ALL_CHARS[rand.nextInt(ALL_CHARS.length)];
        }

        //shuffle it up
        for (int i = 0; i < password.length; i++) {
            int randomPosition = rand.nextInt(password.length);
            char temp = password[i];
            password[i] = password[randomPosition];
            password[randomPosition] = temp;
        }

        return new String(password);
    }
	

}
