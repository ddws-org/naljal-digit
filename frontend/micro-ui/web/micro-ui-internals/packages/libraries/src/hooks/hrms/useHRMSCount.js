import { useQuery, useQueryClient } from "react-query";
import HrmsService from "../../services/elements/HRMS";

export const useHRMSCount = (tenantId, roles, config = {}) => {
  return useQuery(["HRMS_COUNT", tenantId], () => HrmsService.count(tenantId, roles), config);
};

export default useHRMSCount;