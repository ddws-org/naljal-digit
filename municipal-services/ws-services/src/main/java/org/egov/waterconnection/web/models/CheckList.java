package org.egov.waterconnection.web.models;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class CheckList {
	
	private String code;
	
	private String type;
	
	private int  value;

}
