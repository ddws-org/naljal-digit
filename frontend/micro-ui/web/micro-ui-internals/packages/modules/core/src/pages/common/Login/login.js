import { BackButton, Dropdown, FormComposer, FormComposerV2, Loader, Toast } from "@egovernments/digit-ui-react-components";
import PropTypes from "prop-types";
import React, { useEffect, useState } from "react";
import { useHistory, useRouteMatch } from "react-router-dom";
import Background from "../../../components/Background";
import Header from "../../../components/Header";

/* set employee details to enable backward compatiable */
const setEmployeeDetail = (userObject, token) => {
  let locale = JSON.parse(sessionStorage.getItem("Digit.locale"))?.value || "en_IN";
  localStorage.setItem("Employee.tenant-id", userObject?.tenantId);
  localStorage.setItem("tenant-id", userObject?.tenantId);
  localStorage.setItem("citizen.userRequestObject", JSON.stringify(userObject));
  localStorage.setItem("locale", locale);
  localStorage.setItem("Employee.locale", locale);
  localStorage.setItem("token", token);
  localStorage.setItem("Employee.token", token);
  localStorage.setItem("user-info", JSON.stringify(userObject));
  localStorage.setItem("Employee.user-info", JSON.stringify(userObject));
};

const Login = ({ config: propsConfig, t, isDisabled }) => {
  const { data: cities, isLoading } = Digit.Hooks.useTenants();
  const { data: storeData, isLoading: isStoreLoading } = Digit.Hooks.useStore.getInitData();
  const { stateInfo } = storeData || {};
  const [user, setUser] = useState(null);
  const [showToast, setShowToast] = useState(null);
  const [disable, setDisable] = useState(false);
  const { path } = useRouteMatch();
  const history = useHistory();
  // const getUserType = () => "EMPLOYEE" || Digit.UserService.getType();


  console.log(`${window?.location?.origin}/${path}`, "path1");
  console.log(`${window?.location?.origin}`, "path1.5");
  console.log(`${path}`, "path2");

  useEffect(() => {
    if (!user) {
      return;
    }
    Digit.SessionStorage.set("citizen.userRequestObject", user);
    const filteredRoles = user?.info?.roles?.filter((role) => role.tenantId === Digit.SessionStorage.get("Employee.tenantId"));
    if (user?.info?.roles?.length > 0) user.info.roles = filteredRoles;
    Digit.UserService.setUser(user);
    setEmployeeDetail(user?.info, user?.access_token);
    let redirectPath = `/${window?.contextPath}/employee`;

    /* logic to redirect back to same screen where we left off  */
    if (window?.location?.href?.includes("from=")) {
      redirectPath = decodeURIComponent(window?.location?.href?.split("from=")?.[1]) || `/${window?.contextPath}/employee`;
    }

    /*  RAIN-6489 Logic to navigate to National DSS home incase user has only one role [NATADMIN]*/
    // if (user?.info?.roles && user?.info?.roles?.every((e) => e.code === "NATADMIN")) {
    //   redirectPath = `/${window?.contextPath}/employee/dss/landing/NURT_DASHBOARD`;
    // }
    /*  RAIN-6489 Logic to navigate to National DSS home incase user has only one role [NATADMIN]*/
    // if (user?.info?.roles && user?.info?.roles?.every((e) => e.code === "STADMIN")) {
    //   redirectPath = `/${window?.contextPath}/employee/dss/landing/home`;
    // }
    history.replace(redirectPath);
  }, [user]);

  const onLogin = async (data) => {
    // if (!data.city) {
    //   alert("Please Select City!");
    //   return;
    // }
    setDisable(true);

    const requestData = {
      ...data,
      userType: "EMPLOYEE",
    };
    requestData.tenantId = data?.city?.code || Digit.ULBService.getStateId();
    delete requestData.city;
    try {
      const { UserRequest: info, ...tokens } = await Digit.UserService.authenticate(requestData);
      Digit.SessionStorage.set("Employee.tenantId", info?.tenantId);
      setUser({ info, ...tokens });
    } catch (err) {
      setShowToast(
        err?.response?.data?.error_description ||
        (err?.message == "ES_ERROR_USER_NOT_PERMITTED" && t("ES_ERROR_USER_NOT_PERMITTED")) ||
        t("INVALID_LOGIN_CREDENTIALS")
      );
      setTimeout(closeToast, 5000);
    }
    setDisable(false);
  };

  const closeToast = () => {
    setShowToast(null);
  };


  const links = [
    {
      href: `${window?.location?.origin}/mgramseva-web/employee/user/login`,
      text: `${t("LINK_State_Division")}`,
      icon: (
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
          <path d="M12 4l-1.41 1.41L10 6l6 6 6-6-1.41-1.41L13 11H6v2h7l3 3 3-3H20v-2z" />
        </svg>

      ),
    },
    {
      href: `${window?.location?.origin}/mgramseva/`,
      text: `${t("LINK_Village_Login")}`,


      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          height="24"
          viewBox="0 0 24 24"
          width="24"
        >
          <path d="M0 0h24v24H0z" fill="none"></path>
          <path d="M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 9h-2V5h2v6zm0 4h-2v-2h2v2z" fill="currentColor"
          />
        </svg>

      ),
    },
    {
      href: `${window?.location?.origin}/mgramseva-web/citizen/payment/open-search?businessService=WS`,
      text:


        `${t("LINK_Online_Payment")}`,

      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          height="24"
          viewBox="0 0 24 24"
          width="24"
        >
          <path d="M0 0h24v24H0z" fill="none"></path>
          <path d="M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 9h-2V5h2v6zm0 4h-2v-2h2v2z" fill="currentColor"
          />
        </svg>

      ),
    },

  ];


  const defaultValue = {
    code: Digit.ULBService.getStateId(),
    name: Digit.Utils.locale.getTransformedLocale(`TENANT_TENANTS_${Digit.ULBService.getStateId()}`),
  };

  let config = [{ body: propsConfig?.inputs }];


  const { mode } = Digit.Hooks.useQueryParams();
  if (mode === "admin" && config?.[0]?.body?.[2]?.disable == false && config?.[0]?.body?.[2]?.populators?.defaultValue == undefined) {
    config[0].body[2].disable = true;
    config[0].body[2].isMandatory = false;
    config[0].body[2].populators.defaultValue = defaultValue;
  }
  if (config && config[0].body && config[0].body[1].label === "CORE_LOGIN_PASSWORD") {
    config[0].body[1].populators.validation = {
      maxlength: 10,
    };
  }
  return isLoading || isStoreLoading ? (
    <Loader />
  ) : (
    <Background>
      <div className="employeeBackbuttonAlign">
        <BackButton variant="white" style={{ borderBottom: "none" }} />
      </div>

      {/* <FormComposerV2
        onSubmit={onLogin}
        isDisabled={isDisabled || disable}
        noBoxShadow
        inline
        submitInForm
        config={config}
        label={propsConfig.texts.submitButtonLabel}
        secondaryActionLabel={propsConfig.texts.secondaryButtonLabel}
        onSecondayActionClick={onForgotPassword}
        heading={propsConfig.texts.header}
        className="loginFormStyleEmployee"
        cardSubHeaderClassName="loginCardSubHeaderClassName"
        cardClassName="loginCardClassName"
        buttonClassName="buttonClassName"
      >
        <Header />
      </FormComposerV2> */}
      <div className="loginFormStyleEmployee">
        <div className="employeeCard loginCardClassName">
          <Header />
          <div>
            <ul className="link-list" style={{ display: "list-item" }}>
              {links.map((link, index) => (
                <li key={index} className="link-item">
                  <div className="link" style={{ 
                    color: "#f47738 !important",
                    marginRight: "8px" }}>
                    {<svg width="25px" height="25px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M12.7917 15.7991L14.2223 14.3676C16.5926 11.9959 16.5926 8.15054 14.2223 5.7788C11.8521 3.40707 8.0091 3.40707 5.63885 5.7788L2.77769 8.64174C0.407436 11.0135 0.407436 14.8588 2.77769 17.2306C3.87688 18.3304 5.29279 18.9202 6.73165 19" stroke="#1C274C" stroke-width="1.5" stroke-linecap="round" />
                      <path d="M21.2223 15.3583C23.5926 12.9865 23.5926 9.14118 21.2223 6.76945C20.1231 5.66957 18.7072 5.07976 17.2683 5M18.3612 18.2212C15.9909 20.5929 12.1479 20.5929 9.77769 18.2212C7.40744 15.8495 7.40744 12.0041 9.77769 9.63239L11.2083 8.20092" stroke="#1C274C" stroke-width="1.5" stroke-linecap="round" />
                    </svg>}
                  </div>
                  <a href={link.href} target="_blank" rel="noopener noreferrer" className="link" style={{ textDecoration: "none",
                  color: "#f47738",
                  cursor: 'pointer'

                   }}>
                    {link.text}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
      {showToast && <Toast error={true} label={t(showToast)} onClose={closeToast} />}
      <div className="employee-login-home-footer" style={{ backgroundColor: "unset" }}>
        <img
          alt="Powered by DIGIT"
          src={window?.globalConfigs?.getConfig?.("DIGIT_FOOTER_BW")}
          style={{ cursor: "pointer" }}
          onClick={() => {
            window.open(window?.globalConfigs?.getConfig?.("DIGIT_HOME_URL"), "_blank").focus();
          }}
        />{" "}
      </div>
    </Background>
  );
};

Login.propTypes = {
  loginParams: PropTypes.any,
};

Login.defaultProps = {
  loginParams: null,
};

export default Login;
