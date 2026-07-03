// In-memory data store. Seeded at boot; resets on restart.
// Holds shared `contracts` DTOs directly as its data model.
import 'package:contracts/contracts.dart';

int _seq = 1000;
String nextId([String prefix = 'id']) => '${prefix}_${++_seq}';

// ---- Categories ----
const _catImg = 'https://i.ibb.co/RTR96jCd/Group-7017.png';
final List<CategoryDto> categories = [
  const CategoryDto(id: 'cat_burgers', name: 'Burgers', image: _catImg, order: 1),
  const CategoryDto(id: 'cat_pizza', name: 'Pizza', image: _catImg, order: 2),
  const CategoryDto(id: 'cat_bakery', name: 'Bakery', image: _catImg, order: 3),
  const CategoryDto(id: 'cat_drinks', name: 'Drinks', image: _catImg, order: 4),
];

// ---- Addon groups ----
final Map<String, AddonGroupDto> addonGroups = {
  'ag_size': const AddonGroupDto(
    id: 'ag_size', name: 'Size', type: 'single', required: true,
    options: [
      AddonOptionDto(id: 'opt_regular', name: 'Regular', price: 0),
      AddonOptionDto(id: 'opt_large', name: 'Large', price: 80),
    ],
  ),
  'ag_toppings': const AddonGroupDto(
    id: 'ag_toppings', name: 'Extra Toppings', type: 'multi', required: false,
    options: [
      AddonOptionDto(id: 'opt_cheese', name: 'Extra Cheese', price: 50),
      AddonOptionDto(id: 'opt_bacon', name: 'Bacon', price: 70),
      AddonOptionDto(id: 'opt_mushroom', name: 'Mushroom', price: 40),
    ],
  ),
};

AddonOptionDto? optionById(String id) {
  for (final g in addonGroups.values) {
    for (final o in g.options) {
      if (o.id == id) return o;
    }
  }
  return null;
}

// ---- Products ----
const _img =
    'https://static.printmagic.com/uploads/2021/01/15192055/Restaurant-Vinyl-Banner-Indoor.jpg';
final List<ProductDto> products = [
  const ProductDto(id: 'prod_1', name: 'Classic Cheeseburger', description: 'Juicy beef patty, cheddar, house sauce.', categoryId: 'cat_burgers', storeId: '2', price: 350, imageUrl: _img, isVeg: false, isAvailable: true, prepTime: 15, tags: ['Bestseller'], addonGroupIds: ['ag_size', 'ag_toppings'], protein: 25, carbs: 40, fat: 30, rating: 4.6, ratingCount: 128),
  const ProductDto(id: 'prod_2', name: 'Veggie Delight Burger', description: 'Grilled veg patty, lettuce, tomato.', categoryId: 'cat_burgers', storeId: '2', price: 290, imageUrl: _img, isVeg: true, isAvailable: true, prepTime: 12, addonGroupIds: ['ag_size', 'ag_toppings'], protein: 12, carbs: 45, fat: 18, rating: 4.2, ratingCount: 64),
  const ProductDto(id: 'prod_3', name: 'Margherita Pizza', description: 'Classic tomato, mozzarella, basil.', categoryId: 'cat_pizza', storeId: '3', price: 480, imageUrl: _img, isVeg: true, isAvailable: true, prepTime: 20, tags: ['Popular'], addonGroupIds: ['ag_size'], protein: 18, carbs: 60, fat: 22, rating: 4.7, ratingCount: 210),
  const ProductDto(id: 'prod_4', name: 'Pepperoni Pizza', description: 'Loaded pepperoni and cheese.', categoryId: 'cat_pizza', storeId: '3', price: 560, imageUrl: _img, isVeg: false, isAvailable: true, prepTime: 22, addonGroupIds: ['ag_size'], protein: 24, carbs: 58, fat: 28, rating: 4.5, ratingCount: 175),
  const ProductDto(id: 'prod_5', name: 'Chocolate Croissant', description: 'Flaky butter croissant, dark chocolate.', categoryId: 'cat_bakery', storeId: '1', price: 150, imageUrl: _img, isVeg: true, isAvailable: true, prepTime: 5, protein: 6, carbs: 32, fat: 16, rating: 4.8, ratingCount: 90),
  const ProductDto(id: 'prod_6', name: 'Iced Latte', description: 'Chilled espresso with milk.', categoryId: 'cat_drinks', storeId: '4', price: 180, imageUrl: _img, isVeg: true, isAvailable: false, prepTime: 4, protein: 4, carbs: 14, fat: 5, rating: 4.0, ratingCount: 33),
];

ProductDto? findProduct(String id) {
  for (final p in products) {
    if (p.id == id) return p;
  }
  return null;
}

// ---- Home ----
final HomeDto home = const HomeDto(
  banner: 'https://i.ibb.co/RTR96jCd/Group-7017.png',
  bottomBanner: 'https://i.ibb.co/8nCHnw0J/Group-7021.png',
  stores: [
    StoreDto(id: '1', name: 'Bake House', image: _img),
    StoreDto(id: '2', name: 'Burger Point', image: _img),
    StoreDto(id: '3', name: 'Pizza Cottage', image: _img),
    StoreDto(id: '4', name: 'Cafe Brew', image: _img),
  ],
);

// ---- Coupons ----
final List<CouponDto> coupons = [
  const CouponDto(code: 'WELCOME50', type: 'flat', value: 50, minOrder: 300, validUntil: '2030-01-01'),
  const CouponDto(code: 'SAVE10', type: 'pct', value: 10, minOrder: 500, validUntil: '2030-01-01'),
];

CouponDto? findCoupon(String? code) {
  if (code == null) return null;
  for (final c in coupons) {
    if (c.code == code) return c;
  }
  return null;
}

// ---- Crisps ----
final List<CrispDto> crisps = [
  const CrispDto(id: 'crisp_1', title: 'How we source our ingredients', cover: _img, body: '# Fresh, always\n\nWe partner with local farms...', publishedAt: '2026-01-10'),
  const CrispDto(id: 'crisp_2', title: 'Behind the kitchen', cover: _img, body: '## Our crew\n\nMeet the people who cook...', publishedAt: '2026-02-02'),
];

// ---- Delivery zones (polygon-based serviceability) ----
// Each zone is a polygon of [lat, lng] vertices. A point is serviceable if it
// falls inside any zone's polygon (ray-casting point-in-polygon). Geohash is kept
// for client-side reverse-geocode caching, not for boundaries.
class DeliveryZone {
  final String id;
  final String name;
  final List<List<double>> polygon; // [[lat, lng], ...]
  const DeliveryZone({required this.id, required this.name, required this.polygon});
}

final List<DeliveryZone> zones = [
  const DeliveryZone(
    id: 'ktm-core',
    name: 'Kathmandu Core',
    polygon: [
      [27.80, 85.25],
      [27.80, 85.45],
      [27.65, 85.48],
      [27.62, 85.30],
      [27.68, 85.22],
    ],
  ),
];

bool _pointInPolygon(double lat, double lng, List<List<double>> poly) {
  var inside = false;
  final n = poly.length;
  for (var i = 0, j = n - 1; i < n; j = i++) {
    final yi = poly[i][0], xi = poly[i][1];
    final yj = poly[j][0], xj = poly[j][1];
    final intersect =
        ((yi > lat) != (yj > lat)) && (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

/// Returns the first zone whose polygon contains the point, or null.
DeliveryZone? findZoneForPoint(double lat, double lng) {
  for (final z in zones) {
    if (_pointInPolygon(lat, lng, z.polygon)) return z;
  }
  return null;
}

// ---- Internal mutable cart line (raw; priced view is built on read) ----
class RawCartLine {
  final String id;
  final String productId;
  int qty;
  final List<String> selectedAddons;
  final String notes;
  RawCartLine({required this.id, required this.productId, required this.qty, required this.selectedAddons, required this.notes});
}

class RawCart {
  final List<RawCartLine> items = [];
  String? couponCode;
}

// ---- Per-user mutable state ----
final Map<String, UserDto> users = {};
final Map<String, String> usersByEmail = {};
final Map<String, RawCart> carts = {};
final Map<String, List<AddressDto>> addressesByUser = {};
final Map<String, List<OrderDto>> ordersByUser = {};
final Map<String, List<NotificationDto>> notificationsByUser = {};
final Map<String, String> otps = {};
final List<Map<String, dynamic>> helpTickets = []; // "Contact the Crew" support requests
// Targeting data (a real backend would use these to choose push recipients).
final Map<String, Map<String, dynamic>> pushTokensByUser = {}; // userId -> {token, platform, registeredAt}
final Map<String, String> lastLoginByUser = {}; // userId -> ISO timestamp

/// Build the priced cart view DTO from a user's raw cart.
CartDto viewCart(String userId) {
  final cart = carts[userId] ?? RawCart();
  final items = cart.items.map((li) {
    final product = findProduct(li.productId);
    final addons = li.selectedAddons.map(optionById).whereType<AddonOptionDto>().toList();
    final addonTotal = addons.fold<num>(0, (s, a) => s + a.price);
    final unit = (product?.price ?? 0) + addonTotal;
    return CartLineDto(
      id: li.id,
      productId: li.productId,
      name: product?.name,
      imageUrl: product?.imageUrl,
      qty: li.qty,
      basePrice: product?.price ?? 0,
      selectedAddons: addons,
      notes: li.notes,
      lineTotal: unit * li.qty,
    );
  }).toList();
  final subtotal = items.fold<num>(0, (s, i) => s + i.lineTotal);
  final coupon = findCoupon(cart.couponCode);
  num discount = 0;
  if (coupon != null && subtotal >= coupon.minOrder) {
    discount = coupon.type == 'flat' ? coupon.value : (subtotal * coupon.value / 100).round();
  }
  final deliveryCharge = items.isEmpty ? 0 : 60;
  final total = (subtotal - discount).clamp(0, double.infinity) + deliveryCharge;
  return CartDto(
    items: items,
    couponCode: cart.couponCode,
    discount: discount,
    subtotal: subtotal,
    deliveryCharge: deliveryCharge,
    total: total,
  );
}

String _nowIso() => DateTime.now().toUtc().toIso8601String();

/// Seed a demo user so login works out of the box.
void seedDemoUser() {
  const id = 'user_demo';
  const user = UserDto(id: id, name: 'Demo User', email: 'demo@kitchencrew.net', phone: '9800000000');
  users[id] = user;
  usersByEmail[user.email] = id;
  carts[id] = RawCart();
  addressesByUser[id] = [
    AddressDto(id: nextId('addr'), title: 'Home', address: 'Chandol, Kundalini Diagnostic', phone: '9813612464', coordinates: const CoordinatesDto(latitude: 27.7172, longitude: 85.3240), isDefault: true, zone: 'ktm-core'),
  ];
  ordersByUser[id] = [];
  notificationsByUser[id] = [
    NotificationDto(id: nextId('ntf'), type: 'promo', title: 'Welcome to Kitchen Crew', body: 'Use WELCOME50 on your first order!', data: const {'targetScreen': 'home'}, sentAt: _nowIso()),
  ];
}
