import 'common.dart';

/// A priced cart line as returned by the server (server computes lineTotal).
class CartLineDto {
  final String id;
  final String productId;
  final String? name;
  final String? imageUrl;
  final int qty;
  final num basePrice;
  final List<AddonOptionDto> selectedAddons;
  final String notes;
  final num lineTotal;

  /// Whether this line item has been cancelled (item-level cancellation).
  final bool cancelled;

  const CartLineDto({
    required this.id,
    required this.productId,
    this.name,
    this.imageUrl,
    required this.qty,
    required this.basePrice,
    this.selectedAddons = const [],
    this.notes = '',
    required this.lineTotal,
    this.cancelled = false,
  });

  factory CartLineDto.fromJson(Map<String, dynamic> j) => CartLineDto(
        id: j['id'] as String,
        productId: j['productId'] as String,
        name: j['name'] as String?,
        imageUrl: j['imageUrl'] as String?,
        qty: (j['qty'] as num?)?.toInt() ?? 0,
        basePrice: (j['basePrice'] as num?) ?? 0,
        selectedAddons: (j['selectedAddons'] as List? ?? [])
            .map((e) => AddonOptionDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: j['notes'] as String? ?? '',
        lineTotal: (j['lineTotal'] as num?) ?? 0,
        cancelled: j['cancelled'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'name': name,
        'imageUrl': imageUrl,
        'qty': qty,
        'basePrice': basePrice,
        'selectedAddons': selectedAddons.map((e) => e.toJson()).toList(),
        'notes': notes,
        'lineTotal': lineTotal,
        'cancelled': cancelled,
      };
}

/// The full priced cart view.
class CartDto {
  final List<CartLineDto> items;
  final String? couponCode;
  final num discount;
  final num subtotal;
  final num deliveryCharge;
  final num total;

  const CartDto({
    this.items = const [],
    this.couponCode,
    this.discount = 0,
    this.subtotal = 0,
    this.deliveryCharge = 0,
    this.total = 0,
  });

  factory CartDto.fromJson(Map<String, dynamic> j) => CartDto(
        items: (j['items'] as List? ?? [])
            .map((e) => CartLineDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        couponCode: j['couponCode'] as String?,
        discount: (j['discount'] as num?) ?? 0,
        subtotal: (j['subtotal'] as num?) ?? 0,
        deliveryCharge: (j['deliveryCharge'] as num?) ?? 0,
        total: (j['total'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'couponCode': couponCode,
        'discount': discount,
        'subtotal': subtotal,
        'deliveryCharge': deliveryCharge,
        'total': total,
      };
}

/// Request body for POST /cart/items.
class AddCartItemRequest {
  final String productId;
  final int qty;
  final List<String> selectedAddons; // option ids
  final String notes;

  const AddCartItemRequest({
    required this.productId,
    this.qty = 1,
    this.selectedAddons = const [],
    this.notes = '',
  });

  factory AddCartItemRequest.fromJson(Map<String, dynamic> j) => AddCartItemRequest(
        productId: j['productId'] as String,
        qty: (j['qty'] as num?)?.toInt() ?? 1,
        selectedAddons:
            (j['selectedAddons'] as List? ?? []).map((e) => e as String).toList(),
        notes: j['notes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'qty': qty,
        'selectedAddons': selectedAddons,
        'notes': notes,
      };
}
