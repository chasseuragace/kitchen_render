/// Shared API contract: DTOs with fromJson/toJson used by both the Flutter app
/// (data layer) and the Dart mock server. Keep this layer serialization-only —
/// the app maps these DTOs to its own domain entities so the backend stays
/// swappable.
library contracts;

export 'src/common.dart';
export 'src/catalogue.dart';
export 'src/account.dart';
export 'src/cart.dart';
export 'src/order.dart';
