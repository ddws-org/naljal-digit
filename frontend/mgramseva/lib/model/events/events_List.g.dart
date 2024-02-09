// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_List.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventsList _$EventsListFromJson(Map<String, dynamic> json) {
  return EventsList()
    ..events = (json['events'] as List<dynamic>?)
        ?.map((e) => Events.fromJson(e as Map<String, dynamic>))
        .toList()
    ..totalCount = json['totalCount'] as int?;
}

Map<String, dynamic> _$EventsListToJson(EventsList instance) =>
    <String, dynamic>{
      'events': instance.events,
      'totalCount': instance.totalCount,
    };

Events _$EventsFromJson(Map<String, dynamic> json) {
  return Events()
    ..tenantId = json['tenantId'] as String?
    ..id = json['id'] as String?
    ..referenceId = json['referenceId'] as String?
    ..eventType = json['eventType'] as String?
    ..eventCategory = json['eventCategory'] as String?
    ..name = json['name'] as String?
    ..description = json['description'] as String?
    ..status = json['status'] as String?
    ..source = json['source'] as String?
    ..postedBy = json['postedBy'] as String?
    ..recepient = json['recepient'] == null
        ? null
        : Recepient.fromJson(json['recepient'] as Map<String, dynamic>)
    ..actions = json['actions'] == null
        ? null
        : Actions.fromJson(json['actions'] as Map<String, dynamic>)
    ..eventDetails = json['eventDetails'] as dynamic?
    ..auditDetails = json['auditDetails'] == null
        ? null
        : AuditDetails.fromJson(json['auditDetails'] as Map<String, dynamic>)
    ..recepientEventMap = json['recepientEventMap'] as String?
    ..generateCounterEvent = json['generateCounterEvent'] as String?
    ..internallyUpdted = json['internallyUpdted'] as bool?
    ..additionalDetails = json['additionalDetails'] == null
        ? null
        : AdditionalDetails.fromJson(
            json['additionalDetails'] as Map<String, dynamic>);
}

Map<String, dynamic> _$EventsToJson(Events instance) => <String, dynamic>{
      'tenantId': instance.tenantId,
      'id': instance.id,
      'referenceId': instance.referenceId,
      'eventType': instance.eventType,
      'eventCategory': instance.eventCategory,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'source': instance.source,
      'postedBy': instance.postedBy,
      'recepient': instance.recepient,
      'actions': instance.actions,
      'eventDetails': instance.eventDetails,
      'auditDetails': instance.auditDetails,
      'recepientEventMap': instance.recepientEventMap,
      'generateCounterEvent': instance.generateCounterEvent,
      'internallyUpdted': instance.internallyUpdted,
      'additionalDetails': instance.additionalDetails,
    };

AuditDetails _$AuditDetailsFromJson(Map<String, dynamic> json) {
  return AuditDetails()
    ..createdBy = json['createdBy'] as String?
    ..createdTime = json['createdTime'] as int?
    ..lastModifiedBy = json['lastModifiedBy'] as String?
    ..lastModifiedTime = json['lastModifiedTime'] as int?;
}

Map<String, dynamic> _$AuditDetailsToJson(AuditDetails instance) =>
    <String, dynamic>{
      'createdBy': instance.createdBy,
      'createdTime': instance.createdTime,
      'lastModifiedBy': instance.lastModifiedBy,
      'lastModifiedTime': instance.lastModifiedTime,
    };

Actions _$ActionsFromJson(Map<String, dynamic> json) {
  return Actions()
    ..tenantId = json['tenantId'] as String?
    ..id = json['id'] as String?
    ..eventId = json['eventId'] as String?
    ..actionUrls = (json['actionUrls'] as List<dynamic>?)
        ?.map((e) => ActionUrls.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ActionsToJson(Actions instance) => <String, dynamic>{
      'tenantId': instance.tenantId,
      'id': instance.id,
      'eventId': instance.eventId,
      'actionUrls': instance.actionUrls,
    };

ActionUrls _$ActionUrlsFromJson(Map<String, dynamic> json) {
  return ActionUrls()
    ..actionUrl = json['actionUrl'] as String?
    ..code = json['code'] as String?;
}

Map<String, dynamic> _$ActionUrlsToJson(ActionUrls instance) =>
    <String, dynamic>{
      'actionUrl': instance.actionUrl,
      'code': instance.code,
    };

Recepient _$RecepientFromJson(Map<String, dynamic> json) {
  return Recepient(
    toRoles:
        (json['toRoles'] as List<dynamic>?)?.map((e) => e as String).toList(),
    toUsers:
        (json['toUsers'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$RecepientToJson(Recepient instance) => <String, dynamic>{
      'toRoles': instance.toRoles,
      'toUsers': instance.toUsers,
    };

AdditionalDetails _$AdditionalDetailsFromJson(Map<String, dynamic> json) {
  return AdditionalDetails(
    attributes: json['attributes'],
    localizationCode: json['localizationCode'] as String?,
  );
}

Map<String, dynamic> _$AdditionalDetailsToJson(AdditionalDetails instance) =>
    <String, dynamic>{
      'attributes': instance.attributes,
      'localizationCode': instance.localizationCode,
    };
