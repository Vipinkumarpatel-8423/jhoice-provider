import 'dart:convert';

import 'package:get/get.dart';

import '../../common/uuid.dart';
import 'category_model.dart';
import 'e_provider_model.dart';
import 'media_model.dart';
import 'parents/model.dart';

class EService extends Model {
  String id;
  String name;
  String special_points;
  String description;
  List<Media> images;
  double price;
  double discountPrice;
  String priceUnit;
  String fixedUnit;
  String quantityUnit;
  double rate;
  String location;
  String e_provider_id;
  String mode;
  int totalReviews;
  String duration;
  bool featured;
  bool isFavorite;
  List<dynamic> terms;
  List<Category> categories;
  List<Category> subCategories;
  EProvider eProvider;

  EService(
      {this.id,
      this.name,
      this.description,
      this.images,
      this.price,
      this.discountPrice,
      this.priceUnit,
      this.fixedUnit,
      this.quantityUnit,
      this.rate,
      this.totalReviews,
      this.duration,
      this.location,
      this.terms,
      this.mode,
      this.special_points,
      this.featured,
      this.isFavorite,
      this.e_provider_id,
      this.categories,
      this.subCategories,
      this.eProvider});

  EService.fromJson(Map<String, dynamic> json) {
    name = transStringFromJson(json, 'name');
    description = transStringFromJson(json, 'description');
    special_points = transStringFromJson(json, 'special_points');
    images = mediaListFromJson(json, 'images');
    price = doubleFromJson(json, 'price');
    discountPrice = doubleFromJson(json, 'discount_price');
    priceUnit = stringFromJson(json, 'price_unit');
    fixedUnit = stringFromJson(json, 'fixed_unit');
    quantityUnit = transStringFromJson(json, 'quantity_unit');
    rate = doubleFromJson(json, 'rate');
    totalReviews = intFromJson(json, 'total_reviews');
    duration = stringFromJson(json, 'duration');
    location = stringFromJson(json, 'location');
    mode = stringFromJson(json, 'mode');
    featured = boolFromJson(json, 'featured');
    e_provider_id = stringFromJson(json, 'e_provider_id');
    isFavorite = boolFromJson(json, 'is_favorite');
    terms = stringFromJson(json, 'terms').isNotEmpty?jsonDecode(stringFromJson(json, 'terms')):[];
    categories = listFromJson<Category>(json, 'categories', (value) => Category.fromJson(value));
    subCategories = listFromJson<Category>(json, 'sub_categories', (value) => Category.fromJson(value));
    eProvider = objectFromJson(json, 'e_provider', (value) => EProvider.fromJson(value));
    super.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (id != null) data['id'] = this.id;
    if (name != null) data['name'] = this.name;
    if (this.description != null) data['description'] = this.description;
    if (this.special_points != null) data['special_points'] = this.special_points;
    if (this.price != null) data['price'] = this.price;
    if (discountPrice != null) data['discount_price'] = this.discountPrice;
    if (priceUnit != null) data['price_unit'] = this.priceUnit;
    if (fixedUnit != null) data['fixed_unit'] = this.fixedUnit;
    if (quantityUnit != null && quantityUnit != 'null') data['quantity_unit'] = this.quantityUnit;
    if (rate != null) data['rate'] = this.rate;
    if (totalReviews != null) data['total_reviews'] = this.totalReviews;
    if (duration != null) data['duration'] = this.duration;
    if (location != null) data['location'] = this.location;
    if (mode != null) data['mode'] = this.mode;
    if (featured != null) data['featured'] = this.featured;
    if (isFavorite != null) data['is_favorite'] = this.isFavorite;
    if (e_provider_id != null) data['e_provider_id'] = this.e_provider_id;
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v?.id).toList();
    }
    if (this.images != null) {
      data['image'] = this.images.where((element) => Uuid.isUuid(element.id)).map((v) => v.id).toList();
    }
    if (this.subCategories != null) {
      data['sub_categories'] = this.subCategories.map((v) => v.toJson()).toList();
    }
    if (this.eProvider != null && this.eProvider.hasData) {
      data['e_provider_id'] = this.eProvider.id;
    }
    print(data);
    return data;
  }

  String get firstImageUrl => this.images?.first?.url ?? '';

  String get firstImageThumb => this.images?.first?.thumb ?? '';

  String get firstImageIcon => this.images?.first?.icon ?? '';

  @override
  bool get hasData {
    return id != null && name != null && description != null;
  }

  /*
  * Get the real price of the service
  * when the discount not set, then it return the price
  * otherwise it return the discount price instead
  * */
  double get getPrice {
    return (discountPrice ?? 0) > 0 ? discountPrice : price;
  }

  String get getUnit {
    if (priceUnit == 'fixed') {
      if (quantityUnit.isNotEmpty) {
        return "/" + quantityUnit.tr + "pc";
      } else {
        return "";
      }
    } else if (priceUnit == 'hourly') {
      return "/h".tr;
    }else if (priceUnit == 'daily') {
      return "/d".tr;
    }else if (priceUnit == 'montly') {
      return "/m".tr;
    }else if (priceUnit == 'yearly') {
      return "/y".tr;
    }else{
      return "/${priceUnit[0]}";
    }
  }

  String get getFixedUnit {
    if (fixedUnit == 'hourly') {
      return "/h".tr;
    }else if (fixedUnit == 'daily') {
      return "/d".tr;
    }else if (fixedUnit == 'montly') {
      return "/m".tr;
    }else if (fixedUnit == 'yearly') {
      return "/y".tr;
    }else{
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is EService &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          rate == other.rate &&
          isFavorite == other.isFavorite &&
          categories == other.categories &&
          subCategories == other.subCategories &&
          eProvider == other.eProvider;

  @override
  int get hashCode =>
      super.hashCode ^ id.hashCode ^ name.hashCode ^ description.hashCode ^ rate.hashCode ^ eProvider.hashCode ^ categories.hashCode ^ subCategories.hashCode ^ isFavorite.hashCode;
}
