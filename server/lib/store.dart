// In-memory data store. Seeded at boot; resets on restart.
// Holds shared `contracts` DTOs directly as its data model.
import 'package:contracts/contracts.dart';

int _seq = 1000;
String nextId([String prefix = 'id']) => '${prefix}_${++_seq}';

// Bundled Flutter asset used for crisp cover art (downloaded, CORS-safe).
const _img = 'assets/images/banners/home_top.png';

// ---- Categories ----
final List<CategoryDto> categories = [
  const CategoryDto(id: 'cat_bowls', name: 'Bowls', image: 'assets/images/catalog/peri-peri-chicken-rice-bowl.png', order: 1),
  const CategoryDto(id: 'cat_pizza', name: 'Pizza', image: 'assets/images/catalog/margherita.png', order: 2),
  const CategoryDto(id: 'cat_wraps', name: 'Wraps', image: 'assets/images/catalog/chicken-caesar-wrap.png', order: 3),
  const CategoryDto(id: 'cat_sandwiches', name: 'Sandwiches', image: 'assets/images/catalog/farmhouse-grilled-sandwich.png', order: 4),
  const CategoryDto(id: 'cat_burgers', name: 'Burgers', image: 'assets/images/catalog/grilled-chicken-burger.png', order: 5),
  const CategoryDto(id: 'cat_pasta', name: 'Pasta', image: 'assets/images/catalog/chicken-bolognese-pasta.png', order: 6),
  const CategoryDto(id: 'cat_wings', name: 'Wings', image: 'assets/images/catalog/honey-garlic-wings.png', order: 7),
  const CategoryDto(id: 'cat_desserts', name: 'Cheesecakes', image: 'assets/images/catalog/classic-cheesecake.png', order: 8),
  const CategoryDto(id: 'cat_donuts', name: 'Donuts', image: 'assets/images/catalog/vanilla-custard.png', order: 9),
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
final List<ProductDto> products = [
  const ProductDto(id: 'prod_1', name: "Peri Peri Chicken Rice Bowl", description: "Grilled Chicken, Peri Peri Sauce, Egg Corn Rice along with Sweet Corn Tomato Salsa. Fulfilling, tangy, delicious!", categoryId: 'cat_bowls', storeId: '1', price: 530, imageUrl: 'assets/images/catalog/peri-peri-chicken-rice-bowl.png', isVeg: false, isAvailable: true, prepTime: 22, tags: ['Bestseller'], addonGroupIds: ['ag_toppings'], protein: 30, carbs: 52, fat: 23, rating: 4.7, ratingCount: 240),
  const ProductDto(id: 'prod_2', name: "Good Ol' Egg Curry And Rice", description: "Nulla quis lorem ut libero malesuada feugiat.", categoryId: 'cat_bowls', storeId: '1', price: 460, imageUrl: 'assets/images/catalog/good-ol-egg-curry-and-rice.png', isVeg: false, isAvailable: true, prepTime: 18, addonGroupIds: ['ag_toppings'], protein: 33, carbs: 53, fat: 19, rating: 4.4, ratingCount: 25),
  const ProductDto(id: 'prod_3', name: "Mexican Veg Burrito Bowl", description: "Mexican Rice with beans, jalapeno, salsa, shredded cheese, sweet corn and chipotle Sauce, Fulfilling, tangy, delicious!", categoryId: 'cat_bowls', storeId: '1', price: 430, imageUrl: 'assets/images/catalog/mexican-veg-burrito-bowl.png', isVeg: true, isAvailable: true, prepTime: 19, addonGroupIds: ['ag_toppings'], protein: 31, carbs: 58, fat: 22, rating: 4.7, ratingCount: 133),
  const ProductDto(id: 'prod_4', name: "Paneer Butter Masala With Naan", description: "Creamy Paneer Butter Masala along with Butter Naan and Green Chutney. Classic Indian, Creamy gravy that hits the spot!", categoryId: 'cat_bowls', storeId: '1', price: 490, imageUrl: 'assets/images/catalog/paneer-butter-masala-with-naan.png', isVeg: true, isAvailable: true, prepTime: 20, addonGroupIds: ['ag_toppings'], protein: 27, carbs: 61, fat: 23, rating: 4.7, ratingCount: 103),
  const ProductDto(id: 'prod_5', name: "Chicken Caesar Wrap", description: "Grilled Chicken, Caesar Salad wrapped in our home made Tortilla.", categoryId: 'cat_wraps', storeId: '3', price: 460, imageUrl: 'assets/images/catalog/chicken-caesar-wrap.png', isVeg: false, isAvailable: true, prepTime: 20, tags: ['Bestseller'], protein: 19, carbs: 44, fat: 23, rating: 4.5, ratingCount: 69),
  const ProductDto(id: 'prod_6', name: "Creamy Hummus Chicken Wrap", description: "Grilled Chicken, Hummus, Tzatziki Sauce, Olive Salad wrapped in our home made Tortilla. Served with fries on the side.", categoryId: 'cat_wraps', storeId: '3', price: 475, imageUrl: 'assets/images/catalog/creamy-hummus-chicken-wrap.png', isVeg: false, isAvailable: true, prepTime: 11, protein: 19, carbs: 43, fat: 28, rating: 4.3, ratingCount: 247),
  const ProductDto(id: 'prod_7', name: "Creamy Hummus Veggie Wrap", description: "Roasted Veggies, Hummus, Tzatziki Sauce, Olive Salad wrapped in our home made Tortilla. Served with fries on the side.", categoryId: 'cat_wraps', storeId: '3', price: 350, imageUrl: 'assets/images/catalog/creamy-hummus-veggie-wrap.png', isVeg: false, isAvailable: true, prepTime: 20, protein: 20, carbs: 47, fat: 24, rating: 4.3, ratingCount: 255),
  const ProductDto(id: 'prod_8', name: "Spicy Chicken Choila Wrap", description: "Spicy Chicken Choila wrapped in our home made Tortilla.", categoryId: 'cat_wraps', storeId: '3', price: 390, imageUrl: 'assets/images/catalog/spicy-chicken-choila-wrap.png', isVeg: false, isAvailable: true, prepTime: 18, protein: 23, carbs: 49, fat: 28, rating: 4.4, ratingCount: 193),
  const ProductDto(id: 'prod_9', name: "Farmhouse Grilled Sandwich", description: "Grilled sandwich with mozzarella cheese, mix mushroom, roasted capsicum, onion and balsamic dressing Please note: This item does\u2026", categoryId: 'cat_sandwiches', storeId: '3', price: 450, imageUrl: 'assets/images/catalog/farmhouse-grilled-sandwich.png', isVeg: true, isAvailable: true, prepTime: 20, tags: ['Bestseller'], protein: 18, carbs: 41, fat: 20, rating: 4.8, ratingCount: 33),
  const ProductDto(id: 'prod_10', name: "Mozzarella Pesto Sandwich", description: "Grilled Sandwich layered with Mozzarella Cheese, Sun Dried Tomatoes and Pesto Sauce made using fresh basil. Please note: This item does\u2026", categoryId: 'cat_sandwiches', storeId: '3', price: 575, imageUrl: 'assets/images/catalog/mozzarella-pesto-sandwich.png', isVeg: true, isAvailable: true, prepTime: 21, protein: 18, carbs: 48, fat: 24, rating: 4.5, ratingCount: 259),
  const ProductDto(id: 'prod_11', name: "Grilled Chicken Cheese Sandwich", description: "Juicy Grilled Chicken with mozzarella Cheese, grilled to perfection. Please note: This item does not come with fries. The fries are\u2026", categoryId: 'cat_sandwiches', storeId: '3', price: 520, imageUrl: 'assets/images/catalog/grilled-chicken-cheese-sandwich.png', isVeg: false, isAvailable: true, prepTime: 10, protein: 19, carbs: 49, fat: 23, rating: 4.4, ratingCount: 58),
  const ProductDto(id: 'prod_12', name: "Grilled Chicken Panini", description: "Juicy chicken, melty Mozzarella, zesty mayo, and sun-dried tomatoes on Panini bread.", categoryId: 'cat_sandwiches', storeId: '3', price: 550, imageUrl: 'assets/images/catalog/grilled-chicken-panini.png', isVeg: false, isAvailable: true, prepTime: 20, protein: 23, carbs: 51, fat: 21, rating: 4.9, ratingCount: 68),
  const ProductDto(id: 'prod_13', name: "Grilled chicken Burger", description: "Grilled chicken Burger \u2014 a Kitchen Crew favourite.", categoryId: 'cat_burgers', storeId: '3', price: 440, imageUrl: 'assets/images/catalog/grilled-chicken-burger.png', isVeg: false, isAvailable: true, prepTime: 8, tags: ['Bestseller'], protein: 26, carbs: 42, fat: 26, rating: 4.9, ratingCount: 22),
  const ProductDto(id: 'prod_14', name: "Crispy chicken burger", description: "Crispy chicken burger \u2014 a Kitchen Crew favourite.", categoryId: 'cat_burgers', storeId: '3', price: 420, imageUrl: 'assets/images/catalog/crispy-chicken-burger.png', isVeg: false, isAvailable: true, prepTime: 17, protein: 22, carbs: 46, fat: 30, rating: 4.8, ratingCount: 219),
  const ProductDto(id: 'prod_15', name: "Veggie Lover Burger", description: "Veggie Lover Burger \u2014 a Kitchen Crew favourite.", categoryId: 'cat_burgers', storeId: '3', price: 350, imageUrl: 'assets/images/catalog/veggie-lover-burger.png', isVeg: false, isAvailable: true, prepTime: 19, protein: 21, carbs: 44, fat: 30, rating: 4.3, ratingCount: 69),
  const ProductDto(id: 'prod_16', name: "Chicken Bolognese Pasta", description: "A flavorful blend of minced chicken and rich tomato sauce served over al dente pasta. Served with Garlic Bread on the side.", categoryId: 'cat_pasta', storeId: '2', price: 590, imageUrl: 'assets/images/catalog/chicken-bolognese-pasta.png', isVeg: false, isAvailable: true, prepTime: 14, tags: ['Bestseller'], addonGroupIds: ['ag_toppings'], protein: 18, carbs: 71, fat: 22, rating: 4.9, ratingCount: 230),
  const ProductDto(id: 'prod_17', name: "Pesto Pasta", description: "Pesto sauce made from fresh basil, pine nuts, and Parmesan cheese, tossed with cooked pasta. Served with Garlic Bread on the side.", categoryId: 'cat_pasta', storeId: '2', price: 600, imageUrl: 'assets/images/catalog/pesto-pasta.png', isVeg: true, isAvailable: true, prepTime: 18, addonGroupIds: ['ag_toppings'], protein: 19, carbs: 71, fat: 23, rating: 4.8, ratingCount: 197),
  const ProductDto(id: 'prod_18', name: "Mushroom Alfredo Pasta", description: "Creamy and indulgent pasta featuring tender mushrooms cooked in a rich Alfredo sauce, creating a savory and satisfying blend of\u2026", categoryId: 'cat_pasta', storeId: '2', price: 510, imageUrl: 'assets/images/catalog/mushroom-alfredo-pasta.png', isVeg: true, isAvailable: true, prepTime: 15, addonGroupIds: ['ag_toppings'], protein: 22, carbs: 67, fat: 24, rating: 4.9, ratingCount: 189),
  const ProductDto(id: 'prod_19', name: "Classic Cheesecake", description: "Creamy, velvety, and oh-so-satisfying. A taste that never goes out of style!", categoryId: 'cat_desserts', storeId: '5', price: 460, imageUrl: 'assets/images/catalog/classic-cheesecake.png', isVeg: true, isAvailable: true, prepTime: 17, tags: ['Bestseller'], protein: 9, carbs: 42, fat: 32, rating: 4.3, ratingCount: 201),
  const ProductDto(id: 'prod_20', name: "Strawberry Cheesecake", description: "Taste the sweet symphony of creamy cheesecake crowned with luscious strawberries. A dream come true!", categoryId: 'cat_desserts', storeId: '5', price: 520, imageUrl: 'assets/images/catalog/strawberry-cheesecake.png', isVeg: true, isAvailable: true, prepTime: 14, protein: 6, carbs: 48, fat: 27, rating: 4.3, ratingCount: 159),
  const ProductDto(id: 'prod_21', name: "Oreo Cheesecake", description: "Creamy cheesecake meets the crunch of Oreos, sweet chaos in every bite!", categoryId: 'cat_desserts', storeId: '5', price: 450, imageUrl: 'assets/images/catalog/oreo-cheesecake.png', isVeg: true, isAvailable: true, prepTime: 17, protein: 10, carbs: 50, fat: 28, rating: 4.4, ratingCount: 225),
  const ProductDto(id: 'prod_22', name: "Chocolate Cheesecake", description: "Indulge your chocolate cravings with velvety cheesecake and a rich cocoa embrace. A chocolate lover's paradise!", categoryId: 'cat_desserts', storeId: '5', price: 560, imageUrl: 'assets/images/catalog/chocolate-cheesecake.png', isVeg: true, isAvailable: true, prepTime: 14, protein: 8, carbs: 49, fat: 26, rating: 4.7, ratingCount: 40),
  const ProductDto(id: 'prod_23', name: "Apple Crumble Cheesecake", description: "Creamy cheesecake, spiced apples and a crumbly top. It's a cozy, dessert-filled hug!", categoryId: 'cat_desserts', storeId: '5', price: 465, imageUrl: 'assets/images/catalog/apple-crumble-cheesecake.png', isVeg: true, isAvailable: true, prepTime: 19, protein: 5, carbs: 41, fat: 28, rating: 4.4, ratingCount: 84),
  const ProductDto(id: 'prod_24', name: "Vanilla Custard", description: "Creamy vanilla custard wrapped up in soft dough, dusted with sugar, straight-up comfort in a bite.", categoryId: 'cat_donuts', storeId: '5', price: 215, imageUrl: 'assets/images/catalog/vanilla-custard.png', isVeg: true, isAvailable: true, prepTime: 13, tags: ['Bestseller'], protein: 9, carbs: 46, fat: 24, rating: 4.9, ratingCount: 140),
  const ProductDto(id: 'prod_25', name: "Coffee", description: "Featuring a robust flavored coffee cream filling, coated with coffee & cocoa dust.", categoryId: 'cat_donuts', storeId: '5', price: 300, imageUrl: 'assets/images/catalog/coffee.png', isVeg: true, isAvailable: true, prepTime: 13, protein: 10, carbs: 44, fat: 24, rating: 4.4, ratingCount: 48),
  const ProductDto(id: 'prod_26', name: "Berries & Cream", description: "3This donut features a rich blend of berries swirled with a creamy filling, offering a sophisticated balance of sweet and tart flavors.", categoryId: 'cat_donuts', storeId: '5', price: 275, imageUrl: 'assets/images/catalog/berries-cream.png', isVeg: true, isAvailable: true, prepTime: 10, protein: 7, carbs: 44, fat: 24, rating: 4.7, ratingCount: 223),
  const ProductDto(id: 'prod_27', name: "Key Lime Cream", description: "Infused with zesty key limes, this cream filling offers a crisp, refreshing taste perfectly balanced with sweetness.", categoryId: 'cat_donuts', storeId: '5', price: 240, imageUrl: 'assets/images/catalog/key-lime-cream.png', isVeg: true, isAvailable: true, prepTime: 11, protein: 4, carbs: 45, fat: 18, rating: 4.7, ratingCount: 169),
  const ProductDto(id: 'prod_28', name: "Belgian Chocolate", description: "A premium velvety cream filling crafted with the finest Belgian chocolate, offering an exquisite, melt-in-your-mouth experience.", categoryId: 'cat_donuts', storeId: '5', price: 300, imageUrl: 'assets/images/catalog/belgian-chocolate.png', isVeg: true, isAvailable: true, prepTime: 13, protein: 8, carbs: 36, fat: 23, rating: 4.9, ratingCount: 150),
  const ProductDto(id: 'prod_29', name: "Honey Garlic Wings", description: "Pcs Wings glazed with honey, garlic, soy, and a touch of chili, topped with sesame seeds and herbs.", categoryId: 'cat_wings', storeId: '4', price: 450, imageUrl: 'assets/images/catalog/honey-garlic-wings.png', isVeg: true, isAvailable: true, prepTime: 9, tags: ['Bestseller'], protein: 32, carbs: 19, fat: 25, rating: 4.6, ratingCount: 258),
  const ProductDto(id: 'prod_30', name: "Hot Wings", description: "Pcs Spicy wings tossed in a fiery Nepali-style chili sauce, bursting with bold flavors.", categoryId: 'cat_wings', storeId: '4', price: 545, imageUrl: 'assets/images/catalog/hot-wings.png', isVeg: true, isAvailable: true, prepTime: 21, protein: 30, carbs: 23, fat: 29, rating: 4.3, ratingCount: 211),
  const ProductDto(id: 'prod_31', name: "Firecracker Wings", description: "Pcs Crispy wings coated in a spicy-sweet firecracker sauce with a bold, zesty kick.", categoryId: 'cat_wings', storeId: '4', price: 450, imageUrl: 'assets/images/catalog/firecracker-wings.png', isVeg: true, isAvailable: true, prepTime: 15, protein: 27, carbs: 15, fat: 26, rating: 4.9, ratingCount: 219),
  const ProductDto(id: 'prod_32', name: "Dragon Chicken", description: "Chicken tenders tossed in a spicy-sweet dragon sauce with bold Asian-inspired flavors", categoryId: 'cat_wings', storeId: '4', price: 475, imageUrl: 'assets/images/catalog/dragon-chicken.png', isVeg: false, isAvailable: true, prepTime: 21, protein: 28, carbs: 14, fat: 29, rating: 4.5, ratingCount: 81),
  const ProductDto(id: 'prod_33', name: "Margherita", description: "San Marzano tomato sauce, fior di latte, fresh basil, sourdough base", categoryId: 'cat_pizza', storeId: '2', price: 710, imageUrl: 'assets/images/catalog/margherita.png', isVeg: true, isAvailable: true, prepTime: 10, tags: ['Bestseller'], addonGroupIds: ['ag_size', 'ag_toppings'], protein: 17, carbs: 66, fat: 23, rating: 4.7, ratingCount: 34),
  const ProductDto(id: 'prod_34', name: "Funghi", description: "San Marzano tomato sauce, fior di latte, mushroom, sourdough base", categoryId: 'cat_pizza', storeId: '2', price: 845, imageUrl: 'assets/images/catalog/funghi.png', isVeg: true, isAvailable: true, prepTime: 8, addonGroupIds: ['ag_size', 'ag_toppings'], protein: 24, carbs: 62, fat: 25, rating: 4.8, ratingCount: 139),
  const ProductDto(id: 'prod_35', name: "Pestino", description: "FORNO SPECIAL // San marzano tomato sauce, fior di latte, stracciatella, sun-dried tomatoes, basil pesto, hot honey, sourdough base", categoryId: 'cat_pizza', storeId: '2', price: 885, imageUrl: 'assets/images/catalog/pestino.png', isVeg: true, isAvailable: true, prepTime: 14, addonGroupIds: ['ag_size', 'ag_toppings'], protein: 20, carbs: 58, fat: 28, rating: 4.3, ratingCount: 180),
  const ProductDto(id: 'prod_36', name: "Diavola", description: "San marzano tomato sauce, fior di latte, spicy chicken salami, fresh chili, sourdough base", categoryId: 'cat_pizza', storeId: '2', price: 975, imageUrl: 'assets/images/catalog/diavola.png', isVeg: false, isAvailable: true, prepTime: 15, addonGroupIds: ['ag_size', 'ag_toppings'], protein: 24, carbs: 58, fat: 21, rating: 4.7, ratingCount: 91),
];

ProductDto? findProduct(String id) {
  for (final p in products) {
    if (p.id == id) return p;
  }
  return null;
}

// ---- Home ----
final HomeDto home = const HomeDto(
  banner: 'assets/images/banners/home_top.png',
  bottomBanner: 'assets/images/banners/home_bottom.png',
  stores: [
    StoreDto(id: '1', name: "Bowl Co.", image: 'assets/images/catalog/peri-peri-chicken-rice-bowl.png'),
    StoreDto(id: '2', name: "Crew Pizzeria", image: 'assets/images/catalog/margherita.png'),
    StoreDto(id: '3', name: "Wrap & Grill", image: 'assets/images/catalog/chicken-caesar-wrap.png'),
    StoreDto(id: '4', name: "Wings & More", image: 'assets/images/catalog/honey-garlic-wings.png'),
    StoreDto(id: '5', name: "Sweet Crew", image: 'assets/images/catalog/classic-cheesecake.png'),
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
