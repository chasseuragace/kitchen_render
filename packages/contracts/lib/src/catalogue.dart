class CategoryDto {
  final String id;
  final String name;
  final String? image;
  final int order;
  final bool active;

  const CategoryDto({
    required this.id,
    required this.name,
    this.image,
    this.order = 0,
    this.active = true,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> j) => CategoryDto(
        id: j['id'] as String,
        name: j['name'] as String,
        image: j['image'] as String?,
        order: (j['order'] as num?)?.toInt() ?? 0,
        active: j['active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'image': image, 'order': order, 'active': active};
}

class ProductDto {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String? storeId;
  final num price;
  final String imageUrl;
  final bool isVeg;
  final bool isAvailable;
  final int prepTime;
  final List<String> tags;
  final List<String> addonGroupIds;
  // Nutrition per serving, in grams (null when unknown).
  final num? protein;
  final num? carbs;
  final num? fat;
  final num? rating; // average 0..5, null when unrated
  final int ratingCount;

  const ProductDto({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    this.storeId,
    required this.price,
    required this.imageUrl,
    required this.isVeg,
    required this.isAvailable,
    this.prepTime = 0,
    this.tags = const [],
    this.addonGroupIds = const [],
    this.protein,
    this.carbs,
    this.fat,
    this.rating,
    this.ratingCount = 0,
  });

  bool get hasAddons => addonGroupIds.isNotEmpty;
  bool get hasNutrition => protein != null || carbs != null || fat != null;

  factory ProductDto.fromJson(Map<String, dynamic> j) => ProductDto(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String? ?? '',
        categoryId: j['categoryId'] as String,
        storeId: j['storeId'] as String?,
        price: (j['price'] as num?) ?? 0,
        imageUrl: j['imageUrl'] as String? ?? '',
        isVeg: j['isVeg'] as bool? ?? false,
        isAvailable: j['isAvailable'] as bool? ?? true,
        prepTime: (j['prepTime'] as num?)?.toInt() ?? 0,
        tags: (j['tags'] as List? ?? []).map((e) => e as String).toList(),
        addonGroupIds:
            (j['addonGroupIds'] as List? ?? []).map((e) => e as String).toList(),
        protein: j['protein'] as num?,
        carbs: j['carbs'] as num?,
        fat: j['fat'] as num?,
        rating: j['rating'] as num?,
        ratingCount: (j['ratingCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'categoryId': categoryId,
        'storeId': storeId,
        'price': price,
        'imageUrl': imageUrl,
        'isVeg': isVeg,
        'isAvailable': isAvailable,
        'prepTime': prepTime,
        'tags': tags,
        'addonGroupIds': addonGroupIds,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'rating': rating,
        'ratingCount': ratingCount,
      };
}

class StoreDto {
  final String id;
  final String name;
  final String image;

  const StoreDto({required this.id, required this.name, required this.image});

  factory StoreDto.fromJson(Map<String, dynamic> j) =>
      StoreDto(id: j['id'] as String, name: j['name'] as String, image: j['image'] as String? ?? '');

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'image': image};
}

class HomeDto {
  final String banner;
  final String bottomBanner;
  final List<StoreDto> stores;

  const HomeDto({required this.banner, required this.bottomBanner, required this.stores});

  factory HomeDto.fromJson(Map<String, dynamic> j) => HomeDto(
        banner: j['banner'] as String? ?? '',
        bottomBanner: j['bottomBanner'] as String? ?? '',
        stores: (j['stores'] as List? ?? [])
            .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'banner': banner,
        'bottomBanner': bottomBanner,
        'stores': stores.map((e) => e.toJson()).toList(),
      };
}

class CouponDto {
  final String code;
  final String type; // 'flat' | 'pct'
  final num value;
  final num minOrder;
  final String validUntil;

  const CouponDto({
    required this.code,
    required this.type,
    required this.value,
    required this.minOrder,
    required this.validUntil,
  });

  factory CouponDto.fromJson(Map<String, dynamic> j) => CouponDto(
        code: j['code'] as String,
        type: j['type'] as String,
        value: (j['value'] as num?) ?? 0,
        minOrder: (j['minOrder'] as num?) ?? 0,
        validUntil: j['validUntil'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'type': type,
        'value': value,
        'minOrder': minOrder,
        'validUntil': validUntil,
      };
}

class CrispDto {
  final String id;
  final String title;
  final String cover;
  final String? body; // null in list view, present in detail
  final String publishedAt;

  const CrispDto({
    required this.id,
    required this.title,
    required this.cover,
    this.body,
    required this.publishedAt,
  });

  factory CrispDto.fromJson(Map<String, dynamic> j) => CrispDto(
        id: j['id'] as String,
        title: j['title'] as String,
        cover: j['cover'] as String? ?? '',
        body: j['body'] as String?,
        publishedAt: j['publishedAt'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'cover': cover,
        if (body != null) 'body': body,
        'publishedAt': publishedAt,
      };
}
