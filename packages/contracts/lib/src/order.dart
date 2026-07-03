import 'account.dart';
import 'cart.dart';

class OrderStatusEntryDto {
  final String status;
  final String at;

  const OrderStatusEntryDto({required this.status, required this.at});

  factory OrderStatusEntryDto.fromJson(Map<String, dynamic> j) =>
      OrderStatusEntryDto(status: j['status'] as String, at: j['at'] as String? ?? '');

  Map<String, dynamic> toJson() => {'status': status, 'at': at};
}

class OrderDto {
  final String id;
  final List<CartLineDto> items;
  final AddressDto? deliveryAddress;
  final String? deliveryTime;
  final String foodRemarks;
  final String deliveryRemarks;
  final bool isGift;
  final String giftMessage;
  final String? couponCode;
  final num subtotal;
  final num discount;
  final num deliveryCharge;
  final num total;
  final String paymentMethod;
  final String status;
  final List<OrderStatusEntryDto> statusHistory;
  final String createdAt;
  final String? cancelReason;
  final int? feedbackRating; // 1..5, null until rated
  final String? feedbackComment;

  const OrderDto({
    required this.id,
    this.items = const [],
    this.deliveryAddress,
    this.deliveryTime,
    this.foodRemarks = '',
    this.deliveryRemarks = '',
    this.isGift = false,
    this.giftMessage = '',
    this.couponCode,
    this.subtotal = 0,
    this.discount = 0,
    this.deliveryCharge = 0,
    this.total = 0,
    this.paymentMethod = 'cod',
    this.status = 'received',
    this.statusHistory = const [],
    required this.createdAt,
    this.cancelReason,
    this.feedbackRating,
    this.feedbackComment,
  });

  OrderDto copyWith({
    String? status,
    List<OrderStatusEntryDto>? statusHistory,
    String? cancelReason,
    int? feedbackRating,
    String? feedbackComment,
  }) =>
      OrderDto(
        id: id,
        items: items,
        deliveryAddress: deliveryAddress,
        deliveryTime: deliveryTime,
        foodRemarks: foodRemarks,
        deliveryRemarks: deliveryRemarks,
        isGift: isGift,
        giftMessage: giftMessage,
        couponCode: couponCode,
        subtotal: subtotal,
        discount: discount,
        deliveryCharge: deliveryCharge,
        total: total,
        paymentMethod: paymentMethod,
        status: status ?? this.status,
        statusHistory: statusHistory ?? this.statusHistory,
        createdAt: createdAt,
        cancelReason: cancelReason ?? this.cancelReason,
        feedbackRating: feedbackRating ?? this.feedbackRating,
        feedbackComment: feedbackComment ?? this.feedbackComment,
      );

  factory OrderDto.fromJson(Map<String, dynamic> j) => OrderDto(
        id: j['id'] as String,
        items: (j['items'] as List? ?? [])
            .map((e) => CartLineDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        deliveryAddress: j['deliveryAddress'] == null
            ? null
            : AddressDto.fromJson(j['deliveryAddress'] as Map<String, dynamic>),
        deliveryTime: j['deliveryTime'] as String?,
        foodRemarks: j['foodRemarks'] as String? ?? '',
        deliveryRemarks: j['deliveryRemarks'] as String? ?? '',
        isGift: j['isGift'] as bool? ?? false,
        giftMessage: j['giftMessage'] as String? ?? '',
        couponCode: j['couponCode'] as String?,
        subtotal: (j['subtotal'] as num?) ?? 0,
        discount: (j['discount'] as num?) ?? 0,
        deliveryCharge: (j['deliveryCharge'] as num?) ?? 0,
        total: (j['total'] as num?) ?? 0,
        paymentMethod: j['paymentMethod'] as String? ?? 'cod',
        status: j['status'] as String? ?? 'received',
        statusHistory: (j['statusHistory'] as List? ?? [])
            .map((e) => OrderStatusEntryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: j['createdAt'] as String? ?? '',
        cancelReason: j['cancelReason'] as String?,
        feedbackRating: (j['feedbackRating'] as num?)?.toInt(),
        feedbackComment: j['feedbackComment'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'deliveryAddress': deliveryAddress?.toJson(),
        'deliveryTime': deliveryTime,
        'foodRemarks': foodRemarks,
        'deliveryRemarks': deliveryRemarks,
        'isGift': isGift,
        'giftMessage': giftMessage,
        'couponCode': couponCode,
        'subtotal': subtotal,
        'discount': discount,
        'deliveryCharge': deliveryCharge,
        'total': total,
        'paymentMethod': paymentMethod,
        'status': status,
        'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
        'createdAt': createdAt,
        'cancelReason': cancelReason,
        'feedbackRating': feedbackRating,
        'feedbackComment': feedbackComment,
      };
}

/// Request body for POST /orders.
class CreateOrderRequest {
  final String? addressId;
  final String? deliveryTime;
  final String paymentMethod;
  final String foodRemarks;
  final String deliveryRemarks;
  final bool isGift;
  final String giftMessage;

  const CreateOrderRequest({
    this.addressId,
    this.deliveryTime,
    this.paymentMethod = 'cod',
    this.foodRemarks = '',
    this.deliveryRemarks = '',
    this.isGift = false,
    this.giftMessage = '',
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> j) => CreateOrderRequest(
        addressId: j['addressId'] as String?,
        deliveryTime: j['deliveryTime'] as String?,
        paymentMethod: j['paymentMethod'] as String? ?? 'cod',
        foodRemarks: j['foodRemarks'] as String? ?? '',
        deliveryRemarks: j['deliveryRemarks'] as String? ?? '',
        isGift: j['isGift'] as bool? ?? false,
        giftMessage: j['giftMessage'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'addressId': addressId,
        'deliveryTime': deliveryTime,
        'paymentMethod': paymentMethod,
        'foodRemarks': foodRemarks,
        'deliveryRemarks': deliveryRemarks,
        'isGift': isGift,
        'giftMessage': giftMessage,
      };
}
