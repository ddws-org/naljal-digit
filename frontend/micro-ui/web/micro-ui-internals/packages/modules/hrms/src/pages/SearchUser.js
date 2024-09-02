import React, { useState, useEffect } from 'react'
import SearchUserForm from '../components/SearchUserForm'
import SearchUserResults from '../components/SearchUserResults';
import { Header } from '@egovernments/digit-ui-react-components'
import { useTranslation } from "react-i18next";


const SearchUser = () => {
  const { t } = useTranslation()
  const [uniqueTenants, setUniqueTenants] = useState(null)
  const [roles, setUniqueRoles] = useState(null)

  const requestCriteriaForEmployeeSearch = {
    url: "/egov-hrms/employees/_searchListOfEmployee",
    params: {},
    body: {
      criteria: {
        tenantIds: uniqueTenants,
        roles: roles,
        type: "EMPLOYEE"
      }
    },
    config: {
      enabled: !!uniqueTenants && !!roles,
      select: (data) => {
        return data?.Employees
      },

    },
    changeQueryName: { uniqueTenants, roles }
  };

  const { isLoading, data, revalidate, isFetching, error } = Digit.Hooks.useCustomAPIHook(requestCriteriaForEmployeeSearch);



  return (
    <div className="inbox-search-component-wrapper">
      <div className={`sections-parent search`}>
        <Header >{t("HR_SU")}</Header>
        <SearchUserForm uniqueTenants={uniqueTenants} setUniqueTenants={setUniqueTenants} roles={roles} setUniqueRoles={setUniqueRoles} />
      </div>
      <div style={{ marginTop: "1.5rem" }}>
        <SearchUserResults isLoading={isLoading} data={data} />
      </div>
    </div>
  )
}

export default SearchUser