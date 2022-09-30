import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_services_provider/app/models/category_model.dart';
import 'package:home_services_provider/app/models/e_provider_model.dart';
import 'package:home_services_provider/app/models/e_service_model.dart';

import 'parents/model.dart';

class CustomCoupon extends Model {
  String id;
  String code;
  double discount;
  String discount_type;
  String expires_at;
  String description;
  bool enabled;
  List<EProvider> eProviders;
  List<EService> eServices;
  List<Category> categories;
  

  CustomCoupon({this.id, this.code, this.discount, this.enabled, this.discount_type, this.description, this.expires_at});

  CustomCoupon.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    code = stringFromJson(json, 'code');
    description = stringFromJson(json, 'description');
    expires_at = stringFromJson(json, 'expires_at');
    discount = doubleFromJson(json, 'discount', defaultValue: 0);
    enabled = boolFromJson(json, 'default');
    discount_type = stringFromJson(json, 'discount_type');
    eProviders = listFromJson(json, 'eProviders', (v) => EProvider.fromJson(v));
    eServices = listFromJson(json, 'eServices', (v) => EService.fromJson(v));
    categories = listFromJson(json, 'categories', (v) => Category.fromJson(v));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['description'] = this.description;
    data['discount'] = this.discount;
    data['expires_at'] = this.expires_at;
    data['enabled'] = this.enabled;
    data['eServices'] = this.eServices;
    data['eProviders'] = this.eProviders;
    data['categories'] = this.categories;
    if (this.discount_type != null) {
      data['discount_type'] = this.discount_type;
    }
    return data;
  }

  bool isPercentage(){
    return discount_type.contains('precent');
  }
}
