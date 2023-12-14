import { useQuery, useQueryClient } from "react-query";
import HrmsService from "../../services/elements/HRMS";

export const useHRMSSearch = (searchparams, tenantId, filters, isupdated, roles, config = {}) => {
  return useQuery(
    ["HRMS_SEARCH", searchparams, tenantId, filters, isupdated],
    () => HrmsService.search(tenantId, filters, searchparams, roles),
    config
  );
};

export default useHRMSSearch;

export const useHRMSEmployeeSearch = (criteria, isupdated, config = {}) => {
  return useQuery(["HRMS_SEARCH", criteria, isupdated], () => HrmsService.searchEmployee(criteria), config);
};
