import { roundToNearestMinutes } from "date-fns/esm";
import Urls from "../atoms/urls";
import { Request } from "../atoms/Utils/Request";

const HrmsService = {
  search: (tenantId, filters, searchParams, roles) =>
    Request({
      url: Urls.hrms.search,
      useCache: false,
      method: "POST",
      auth: true,
      userService: true,
      params: { tenantId, ...filters, ...searchParams, ...roles },
    }),
  searchEmployee: (data) =>
    Request({
      url: Urls.hrms.searchListOfEmployee,
      useCache: false,
      method: "POST",
      auth: true,
      userService: true,
      data: data,
    }),
  create: (data, tenantId) =>
    Request({
      data: data,
      url: Urls.hrms.create,
      useCache: false,
      method: "POST",
      auth: true,
      userService: true,
      params: { tenantId },
    }),
  update: (data, tenantId) =>
    Request({
      data: data,
      url: Urls.hrms.update,
      useCache: false,
      method: "POST",
      auth: true,
      userService: true,
      params: { tenantId },
    }),
  count: (tenantId, roles) =>
    Request({
      url: Urls.hrms.count,
      useCache: false,
      method: "POST",
      auth: true,
      userService: true,
      params: { tenantId, ...roles },
    }),
};

export default HrmsService;