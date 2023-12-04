import 'package:mgramseva/model/mdms/project.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:provider/provider.dart';

import '../model/mdms/department.dart';
import '../providers/common_provider.dart';
import '../services/base_service.dart';
import '../services/request_info.dart';
import '../utils/global_variables.dart';
import '../utils/models.dart';

class IfixHierarchyRepo extends BaseService {
  Future<Department?> fetchDepartments(String code, bool getAncestry,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    Department? departments;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());
    var body = {
      "criteria": {
        "code": code,
        "tenantId":
            commonProvider.userDetails!.selectedtenant?.code?.substring(0, 2),
        "getAncestry": getAncestry
      },
      'requestHeader': {"msgId": "Unknown", "signature": "NON"}
    };
    var res = await makeRequest(
        url: Url.IFIX_DEPARTMENT_ENTITY,
        body: body,
        requestInfo: requestInfo,
        method: RequestType.POST);
    if (res != null && res['departmentEntity'] != null) {
      try {
        departments = Department.fromJson(res['departmentEntity'][0]);
      } catch (e) {
        departments = null;
      }
    }
    return departments;
  }
/*
  * @author Saloni
  * saloni.bajaj@egovernments.org
  *
  * */
  Future<Project?> fetchProject(String departmentEntityId) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    Project? project;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());
    var body = {
      "criteria": {
        "departmentEntityId": departmentEntityId,
        "tenantId":
            commonProvider.userDetails!.userRequest!.tenantId.toString(),
      },
      'requestHeader': {"msgId": "Unknown", "signature": "NON"}
    };
    var res = await makeRequest(
        url: Url.ADAPTER_MASTER_DATA_PROJECT_SEARCH,
        body: body,
        requestInfo: requestInfo,
        method: RequestType.POST);
    if (res != null && res['project'] != null) {
      try {
        project = Project.fromJson(res['project'][0]);
      } catch (e) {
        project = null;
      }
    }
    return project;
  }
}
