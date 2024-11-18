package org.egov.naljalcustomisation.web.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.egov.common.contract.request.Role;
import org.egov.naljalcustomisation.web.model.users.User;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UserInfo extends User {

    @JsonProperty("tenantId")

    private String tenantId;

    @JsonProperty("uuid")

    private String uuid;

    @JsonProperty("userName")

    private String userName;

    @JsonProperty("password")

    private String password;

    @JsonProperty("idToken")

    private String idToken;

    @JsonProperty("email")

    private String email;

    @JsonProperty("primaryrole")
    private List<Role> primaryrole = new ArrayList<Role>();

    @JsonProperty("additionalroles")

    private List<TenantRole> additionalroles;

    @JsonProperty("mobileNumber")
    private String mobileNumber;

    public UserInfo tenantId(String tenantId) {
        this.tenantId = tenantId;
        return this;
    }

}

