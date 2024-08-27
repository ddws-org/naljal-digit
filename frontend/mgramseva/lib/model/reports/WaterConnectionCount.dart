class WaterConnectionCount {
  int? count;
  int? taxperiodto;

  WaterConnectionCount({this.count, this.taxperiodto});

  WaterConnectionCount.fromJson(Map<String, dynamic> json) {
    count = json['count']??0;
    taxperiodto = json['taxperiodto']??0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['taxperiodto'] = this.taxperiodto;
    return data;
  }
}
class WaterConnectionCountResponse {
  List<WaterConnectionCount>? waterConnectionsDemandGenerated;
  List<WaterConnectionCount>? waterConnectionsDemandNotGenerated;

  WaterConnectionCountResponse(
      {this.waterConnectionsDemandGenerated,
        this.waterConnectionsDemandNotGenerated});

  WaterConnectionCountResponse.fromJson(Map<String, dynamic> json) {
    if (json['WaterConnectionsDemandGenerated'] != null) {
      waterConnectionsDemandGenerated = <WaterConnectionCount>[];
      json['WaterConnectionsDemandGenerated'].forEach((v) {
        waterConnectionsDemandGenerated!
            .add(new WaterConnectionCount.fromJson(v));
      });
    }
    if (json['WaterConnectionsDemandNotGenerated'] != null) {
      waterConnectionsDemandNotGenerated =
      <WaterConnectionCount>[];
      json['WaterConnectionsDemandNotGenerated'].forEach((v) {
        waterConnectionsDemandNotGenerated!
            .add(new WaterConnectionCount.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.waterConnectionsDemandGenerated != null) {
      data['WaterConnectionsDemandGenerated'] =
          this.waterConnectionsDemandGenerated!.map((v) => v.toJson()).toList();
    }
    if (this.waterConnectionsDemandNotGenerated != null) {
      data['WaterConnectionsDemandNotGenerated'] = this
          .waterConnectionsDemandNotGenerated!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }
}