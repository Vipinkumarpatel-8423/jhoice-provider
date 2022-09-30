import 'package:flutter/material.dart';

import 'e_service_model.dart';
import 'media_model.dart';
import 'parents/model.dart';

class Campaign extends Model {
  String id;
  String name;
  String type;
  String condition;
  Media image;
  String redirectUrl;

  Campaign({this.id, this.name, this.type, this.redirectUrl, this.image});

  Campaign.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    name = transStringFromJson(json, 'name');
    type = transStringFromJson(json, 'type');
    condition = transStringFromJson(json, 'condition');
    image = mediaFromJson(json, 'image');
    redirectUrl = transStringFromJson(json, 'redirectUrl');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['redirectUrl'] = this.redirectUrl;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Campaign &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode =>
      super.hashCode ^
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      redirectUrl.hashCode ^
      image.hashCode;
}
