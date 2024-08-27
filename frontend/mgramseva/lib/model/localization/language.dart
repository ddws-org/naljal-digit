import 'package:mgramseva/model/mdms/business_service.dart';
import 'package:mgramseva/model/mdms/category_type.dart';
import 'package:mgramseva/model/mdms/connection_type.dart';
import 'package:mgramseva/model/mdms/expense_type.dart';
import 'package:mgramseva/model/mdms/property_type.dart';
import 'package:mgramseva/model/mdms/sub_category_type.dart';
import 'package:mgramseva/model/mdms/tax_period.dart';

import '../../repository/water_services_calculation.dart';

class LanguageList {
  dynamic? responseInfo;
  MdmsRes? mdmsRes;

  LanguageList({this.responseInfo, this.mdmsRes});

  LanguageList.fromJson(Map<String, dynamic> json) {
    responseInfo = json['ResponseInfo'];
    mdmsRes =
        json['MdmsRes'] != null ? new MdmsRes.fromJson(json['MdmsRes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ResponseInfo'] = this.responseInfo;
    if (this.mdmsRes != null) {
      data['MdmsRes'] = this.mdmsRes?.toJson();
    }
    return data;
  }
}

class PSPCLIntegration {
  List<AccountNumberGpMapping>? accountNumberGpMapping;

  PSPCLIntegration({this.accountNumberGpMapping});

  PSPCLIntegration.fromJson(Map<String, dynamic> json) {
    if (json['accountNumberGpMapping'] != null) {
      accountNumberGpMapping = <AccountNumberGpMapping>[];
      json['accountNumberGpMapping'].forEach((v) {
        accountNumberGpMapping!.add(new AccountNumberGpMapping.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.accountNumberGpMapping != null) {
      data['accountNumberGpMapping'] =
          this.accountNumberGpMapping!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AccountNumberGpMapping {
  String? accountNumber;
  String? departmentEntityName;
  String? departmentEntityCode;

  AccountNumberGpMapping(
      {this.accountNumber,
      this.departmentEntityName,
      this.departmentEntityCode});

  AccountNumberGpMapping.fromJson(Map<String, dynamic> json) {
    accountNumber = json['accountNumber'];
    departmentEntityName = json['departmentEntityName'];
    departmentEntityCode = json['departmentEntityCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accountNumber'] = this.accountNumber;
    data['departmentEntityName'] = this.departmentEntityName;
    data['departmentEntityCode'] = this.departmentEntityCode;
    return data;
  }
}

class MdmsRes {
  CommonMasters? commonMasters;
  BillingService? billingService;
  Expense? expense;
  PropertyTax? propertyTax;
  Connection? connection;
  Category? category;
  SubCategory? subCategory;
  TaxPeriodListModel? taxPeriodList;
  WCBillingSlabs? wcBillingSlabList;
  PSPCLIntegration? pspclIntegration;

  MdmsRes({this.commonMasters});

  MdmsRes.fromJson(Map<String, dynamic> json) {
    commonMasters = json['common-masters'] != null
        ? new CommonMasters.fromJson(json['common-masters'])
        : null;
    billingService = json['BillingService'] != null
        ? new BillingService.fromJson(json['BillingService'])
        : null;
    expense =
        json['Expense'] != null ? new Expense.fromJson(json['Expense']) : null;
    propertyTax = json['PropertyTax'] != null
        ? new PropertyTax.fromJson(json['PropertyTax'])
        : null;
    connection = json['ws-services-masters'] != null
        ? new Connection.fromJson(json['ws-services-masters'])
        : null;
    category = json['ws-services-masters'] != null
        ? new Category.fromJson(json['ws-services-masters'])
        : null;

    subCategory = json['ws-services-masters'] != null
        ? new SubCategory.fromJson(json['ws-services-masters'])
        : null;
    taxPeriodList = json['BillingService'] != null
        ? new TaxPeriodListModel.fromJson(json['BillingService'])
        : null;
    wcBillingSlabList = json['ws-services-calculation'] != null
        ? new WCBillingSlabs.fromJson(json['ws-services-calculation'])
        : null;
    pspclIntegration = json['pspcl-integration'] != null
        ? new PSPCLIntegration.fromJson(json['pspcl-integration'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.commonMasters != null) {
      data['common-masters'] = this.commonMasters?.toJson();
    }
    return data;
  }
}

class CommonMasters {
  List<StateInfo>? stateInfo;
  List<AppVersion>? appVersion;
  CommonMasters({this.stateInfo, this.appVersion});

  CommonMasters.fromJson(Map<String, dynamic> json) {
    if (json['StateInfo'] != null) {
      stateInfo = <StateInfo>[];
      json['StateInfo'].forEach((v) {
        stateInfo?.add(new StateInfo.fromJson(v));
      });
    }
    if (json['AppVersion'] != null) {
      appVersion = <AppVersion>[];
      json['AppVersion'].forEach((v) {
        appVersion?.add(new AppVersion.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stateInfo != null) {
      data['StateInfo'] = this.stateInfo?.map((v) => v.toJson()).toList();
    }
    if (this.appVersion != null) {
      data['AppVersion'] = this.appVersion?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AppVersion {
  String? latestAppVersion;
  String? latestAppVersionIos;
  // List<LocalizationModules>? localizationModules;

  AppVersion({
    this.latestAppVersion,
    this.latestAppVersionIos
  });

  AppVersion.fromJson(Map<String, dynamic> json) {
    latestAppVersion = json['latestAppVersion'];
    latestAppVersionIos = json['latestAppVersionIos'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latestAppVersion'] = this.latestAppVersion;
    data['latestAppVersionIos'] = this.latestAppVersionIos;

    return data;
  }
}

class StateInfo {
  String? name;
  String? code;
  String? qrCodeURL;
  String? bannerUrl;
  String? logoUrl;
  String? logoUrlWhite;
  bool? hasLocalisation;
  bool? enableWhatsApp;
  String? selectedCode;
  String? stateLogoURL;
  DefaultUrl? defaultUrl;
  List<Languages>? languages;
  // List<LocalizationModules>? localizationModules;

  StateInfo({
    this.name,
    this.code,
    this.qrCodeURL,
    this.bannerUrl,
    this.logoUrl,
    this.selectedCode,
    this.stateLogoURL,
    this.logoUrlWhite,
    this.hasLocalisation,
    this.enableWhatsApp,
    this.defaultUrl,
    this.languages,
    // this.localizationModules
  });

  StateInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    qrCodeURL = json['qrCodeURL'];
    bannerUrl = json['bannerUrl'];
    stateLogoURL = json['stateLogoURL'];
    logoUrl = json['logoUrl'];
    selectedCode = json['selectedCode'];
    logoUrlWhite = json['logoUrlWhite'];
    hasLocalisation = json['hasLocalisation'];
    enableWhatsApp = json['enableWhatsApp'];
    defaultUrl = json['defaultUrl'] != null
        ? new DefaultUrl.fromJson(json['defaultUrl'])
        : null;
    if (json['languages'] != null) {
      languages = <Languages>[];
      json['languages'].forEach((v) {
        languages?.add(new Languages.fromJson(v));
      });
    }
    // if (json['localizationModules'] != null) {
    //   localizationModules = <LocalizationModules>[];
    //   json['localizationModules'].forEach((v) {
    //     localizationModules?.add(LocalizationModules?.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['code'] = this.code;
    data['qrCodeURL'] = this.qrCodeURL;
    data['bannerUrl'] = this.bannerUrl;
    data['logoUrl'] = this.logoUrl;
    data['stateLogoURL'] = this.stateLogoURL;
    data['selectedCode'] = this.selectedCode;
    data['logoUrlWhite'] = this.logoUrlWhite;
    data['hasLocalisation'] = this.hasLocalisation;
    data['enableWhatsApp'] = this.enableWhatsApp;
    if (this.defaultUrl != null) {
      data['defaultUrl'] = this.defaultUrl?.toJson();
    }
    if (this.languages != null) {
      data['languages'] = this.languages?.map((v) => v.toJson()).toList();
    }
    // if (this.localizationModules != null) {
    //   data['localizationModules'] =
    //       this.localizationModules?.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class DefaultUrl {
  String? citizen;
  String? employee;

  DefaultUrl({this.citizen, this.employee});

  DefaultUrl.fromJson(Map<String, dynamic> json) {
    citizen = json['citizen'];
    employee = json['employee'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['citizen'] = this.citizen;
    data['employee'] = this.employee;
    return data;
  }
}

class Languages {
  String? label;
  String? value;
  bool isSelected = false;

  Languages({this.label, this.value, this.isSelected = false});

  Languages.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
    isSelected = json['isSelected'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['value'] = this.value;
    data['isSelected'] = this.isSelected;
    return data;
  }
}

class LocalizationModules {
  String? label;
  String? value;

  LocalizationModules({this.label, this.value});

  LocalizationModules.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['value'] = this.value;
    return data;
  }
}
