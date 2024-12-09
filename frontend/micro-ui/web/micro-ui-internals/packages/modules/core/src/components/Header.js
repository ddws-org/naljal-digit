import React from "react";
import { useTranslation } from "react-i18next";
import { Loader, BackButton } from "@egovernments/digit-ui-react-components"

const Header = () => {
  const { data: storeData, isLoading } = Digit.Hooks.useStore.getInitData();
  const { stateInfo } = storeData || {};
  const { t } = useTranslation()

  if (isLoading) return <Loader/>;

  return (
    <div className="bannerHeader">
      {window.location.href.includes("employee/user/forgot-password")?<BackButton variant="arrowblack" style={{ borderBottom: "none", position: "relative", right: "27%" }} />:""}

      <img className="bannerLogo" src={stateInfo?.logoUrl} />
      <p>{t(`TENANT_TENANTS_${stateInfo?.code.toUpperCase()}`)}</p>
    </div>
  );
}

export default Header;