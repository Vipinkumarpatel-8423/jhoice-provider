import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'parents/model.dart';

class KeyValue extends Model {
  String key;
  String value;
  KeyValue({this.key, this.value});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}
