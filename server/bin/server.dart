import 'dart:convert';
import 'dart:io';

import 'package:contracts/contracts.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:server/auth.dart';
import 'package:server/store.dart';

// ---- response helpers ----
Response _json(Object? data, {int status = 200}) => Response(
      status,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );

Response _err(int status, String message) => _json({'error': message}, status: status);

Future<Map<String, dynamic>> _body(Request req) async {
  final raw = await req.readAsString();
  if (raw.isEmpty) return {};
  return (jsonDecode(raw) as Map).cast<String, dynamic>();
}

/// Wrap a handler that requires an authenticated user.
Handler _auth(Future<Response> Function(Request req, UserDto user) fn) {
  return (Request req) async {
    final user = userFromAuthHeader(req.headers['authorization']);
    if (user == null) return _err(401, 'unauthorized');
    return fn(req, user);
  };
}

String _nowIso() => DateTime.now().toUtc().toIso8601String();

Router _buildRouter() {
  final r = Router();

  // ---- health ----
  r.get('/health', (Request _) => _json({'ok': true, 'service': 'kitchen-crew-mock', 'ts': DateTime.now().millisecondsSinceEpoch}));

  // ---- auth ----
  r.post('/auth/register', (Request req) async {
    final b = await _body(req);
    final email = b['email'] as String?;
    if (email == null) return _err(400, 'email required');
    if (usersByEmail.containsKey(email)) return _err(409, 'email already registered');
    final id = nextId('user');
    final user = UserDto(id: id, name: (b['name'] as String?) ?? 'New User', email: email, phone: (b['phone'] as String?) ?? '');
    users[id] = user;
    usersByEmail[email] = id;
    carts[id] = RawCart();
    addressesByUser[id] = [];
    ordersByUser[id] = [];
    notificationsByUser[id] = [];
    lastLoginByUser[id] = _nowIso();
    return _json(AuthResultDto(token: signToken(id), user: user).toJson(), status: 201);
  });

  r.post('/auth/login', (Request req) async {
    final b = await _body(req);
    final userId = usersByEmail[b['email']];
    if (userId == null) return _err(404, 'user not found');
    lastLoginByUser[userId] = _nowIso();
    return _json(AuthResultDto(token: signToken(userId), user: users[userId]!).toJson());
  });

  r.post('/auth/otp/request', (Request req) async {
    final b = await _body(req);
    final phone = b['phone'] as String?;
    if (phone == null) return _err(400, 'phone required');
    otps[phone] = '123456';
    return _json({'sent': true, 'otp': '123456'}); // otp returned for local dev only
  });

  r.post('/auth/otp/verify', (Request req) async {
    final b = await _body(req);
    final phone = b['phone'] as String?;
    if (phone == null || otps[phone] != b['otp']) return _err(401, 'invalid otp');
    otps.remove(phone);
    var userId = users.values.where((u) => u.phone == phone).map((u) => u.id).firstOrNull;
    if (userId == null) {
      userId = nextId('user');
      final user = UserDto(id: userId, name: 'New User', email: '$phone@phone.local', phone: phone);
      users[userId] = user;
      usersByEmail[user.email] = userId;
      carts[userId] = RawCart();
      addressesByUser[userId] = [];
      ordersByUser[userId] = [];
      notificationsByUser[userId] = [];
    }
    lastLoginByUser[userId] = _nowIso();
    return _json(AuthResultDto(token: signToken(userId), user: users[userId]!).toJson());
  });

  r.get('/auth/me', _auth((req, user) async => _json(user.toJson())));

  // Register a device push token (targeting data). Prod: token from FCM.
  r.post('/push/register-token', _auth((req, user) async {
    final b = await _body(req);
    pushTokensByUser[user.id] = {
      'token': b['token'],
      'platform': b['platform'],
      'registeredAt': _nowIso(),
    };
    return _json({'ok': true});
  }));

  // Update profile (email kept immutable in the mock to avoid index remaps).
  r.patch('/auth/me', _auth((req, user) async {
    final b = await _body(req);
    final updated = UserDto(
      id: user.id,
      name: (b['name'] as String?) ?? user.name,
      email: user.email,
      phone: (b['phone'] as String?) ?? user.phone,
    );
    users[user.id] = updated;
    return _json(updated.toJson());
  }));

  // Delete account + all the user's data (GDPR data deletion).
  r.delete('/auth/me', _auth((req, user) async {
    users.remove(user.id);
    usersByEmail.remove(user.email);
    carts.remove(user.id);
    addressesByUser.remove(user.id);
    ordersByUser.remove(user.id);
    notificationsByUser.remove(user.id);
    pushTokensByUser.remove(user.id);
    lastLoginByUser.remove(user.id);
    helpTickets.removeWhere((t) => t['userId'] == user.id);
    return _json({'ok': true});
  }));

  // GDPR data export/portability: a JSON bundle of everything held about the user.
  r.get('/auth/me/export', _auth((req, user) async {
    return _json({
      'exportedAt': _nowIso(),
      'profile': user.toJson(),
      'addresses': (addressesByUser[user.id] ?? []).map((a) => a.toJson()).toList(),
      'orders': (ordersByUser[user.id] ?? []).map((o) => o.toJson()).toList(),
      'cart': viewCart(user.id).toJson(),
      'notifications': (notificationsByUser[user.id] ?? []).map((n) => n.toJson()).toList(),
      'pushToken': pushTokensByUser[user.id],
      'lastLogin': lastLoginByUser[user.id],
      'helpTickets': helpTickets.where((t) => t['userId'] == user.id).toList(),
    });
  }));

  // Forgot / reset password (mock — passwords aren't really stored, so this is
  // symbolic: a fixed dev reset code, verified on reset).
  r.post('/auth/forgot-password', (Request req) async {
    final b = await _body(req);
    final email = b['email'] as String?;
    if (email == null || !usersByEmail.containsKey(email)) {
      return _err(404, 'no account for that email');
    }
    return _json({'sent': true, 'resetCode': '654321'}); // code returned for local dev
  });

  r.post('/auth/reset-password', (Request req) async {
    final b = await _body(req);
    final email = b['email'] as String?;
    if (email == null || !usersByEmail.containsKey(email)) return _err(404, 'no account for that email');
    if (b['resetCode'] != '654321') return _err(401, 'invalid reset code');
    return _json({'ok': true});
  });

  // Change password while signed in (mock — passwords aren't stored, so the
  // current password isn't actually verified; we validate the new one).
  r.post('/auth/change-password', _auth((req, user) async {
    final b = await _body(req);
    final current = b['currentPassword'] as String?;
    final next = b['newPassword'] as String?;
    if (current == null || current.isEmpty) return _err(400, 'current password required');
    if (next == null || next.length < 6) return _err(400, 'new password must be at least 6 characters');
    return _json({'ok': true});
  }));

  // ---- catalogue ----
  r.get('/home', (Request _) => _json(home.toJson()));
  r.get('/categories', (Request _) => _json(categories.map((c) => c.toJson()).toList()));

  r.get('/products', (Request req) {
    final q = req.url.queryParameters;
    var list = products;
    if (q['storeId'] != null) list = list.where((p) => p.storeId == q['storeId']).toList();
    if (q['categoryId'] != null) list = list.where((p) => p.categoryId == q['categoryId']).toList();
    if (q['veg'] == 'true') list = list.where((p) => p.isVeg).toList();
    if (q['q'] != null) list = list.where((p) => p.name.toLowerCase().contains(q['q']!.toLowerCase())).toList();
    return _json(list.map((p) => p.toJson()).toList());
  });

  r.get('/products/<id>', (Request _, String id) {
    final p = findProduct(id);
    return p == null ? _err(404, 'not found') : _json(p.toJson());
  });

  r.get('/products/<id>/addons', (Request _, String id) {
    final p = findProduct(id);
    if (p == null) return _err(404, 'not found');
    return _json(p.addonGroupIds.map((gid) => addonGroups[gid]).whereType<AddonGroupDto>().map((g) => g.toJson()).toList());
  });

  // ---- cart ----
  r.get('/cart', _auth((req, user) async => _json(viewCart(user.id).toJson())));

  r.post('/cart/items', _auth((req, user) async {
    final reqBody = AddCartItemRequest.fromJson(await _body(req));
    if (findProduct(reqBody.productId) == null) return _err(400, 'invalid product');
    carts[user.id]!.items.add(RawCartLine(id: nextId('line'), productId: reqBody.productId, qty: reqBody.qty, selectedAddons: reqBody.selectedAddons, notes: reqBody.notes));
    return _json(viewCart(user.id).toJson(), status: 201);
  }));

  r.patch('/cart/items/<lineId>', _auth((req, user) async {
    final lineId = req.params['lineId'];
    final cart = carts[user.id]!;
    final li = cart.items.where((x) => x.id == lineId).firstOrNull;
    if (li == null) return _err(404, 'line not found');
    final b = await _body(req);
    if (b['qty'] is num) li.qty = (b['qty'] as num).toInt();
    if (li.qty <= 0) cart.items.removeWhere((x) => x.id == li.id);
    return _json(viewCart(user.id).toJson());
  }));

  r.delete('/cart/items/<lineId>', _auth((req, user) async {
    carts[user.id]!.items.removeWhere((x) => x.id == req.params['lineId']);
    return _json(viewCart(user.id).toJson());
  }));

  r.post('/cart/coupon', _auth((req, user) async {
    final b = await _body(req);
    if (findCoupon(b['code'] as String?) == null) return _err(404, 'invalid coupon');
    carts[user.id]!.couponCode = b['code'] as String?;
    return _json(viewCart(user.id).toJson());
  }));

  r.delete('/cart/coupon', _auth((req, user) async {
    carts[user.id]!.couponCode = null;
    return _json(viewCart(user.id).toJson());
  }));

  // ---- addresses ----
  r.get('/addresses', _auth((req, user) async => _json((addressesByUser[user.id] ?? []).map((a) => a.toJson()).toList())));

  r.post('/addresses', _auth((req, user) async {
    final b = await _body(req);
    final list = addressesByUser[user.id]!;
    final addr = AddressDto(
      id: nextId('addr'),
      title: (b['title'] as String?) ?? '',
      address: (b['address'] as String?) ?? '',
      phone: (b['phone'] as String?) ?? '',
      coordinates: b['coordinates'] == null ? null : CoordinatesDto.fromJson((b['coordinates'] as Map).cast<String, dynamic>()),
      isDefault: (b['isDefault'] as bool?) ?? false,
      zone: (b['zone'] as String?) ?? 'ktm-core',
    );
    if (addr.isDefault) {
      for (var i = 0; i < list.length; i++) {
        list[i] = AddressDto(id: list[i].id, title: list[i].title, address: list[i].address, phone: list[i].phone, coordinates: list[i].coordinates, isDefault: false, zone: list[i].zone);
      }
    }
    list.add(addr);
    return _json(addr.toJson(), status: 201);
  }));

  r.patch('/addresses/<id>', _auth((req, user) async {
    final id = req.params['id'];
    final list = addressesByUser[user.id]!;
    final idx = list.indexWhere((a) => a.id == id);
    if (idx < 0) return _err(404, 'not found');
    final b = await _body(req);
    final cur = list[idx];
    final updated = AddressDto(
      id: cur.id,
      title: (b['title'] as String?) ?? cur.title,
      address: (b['address'] as String?) ?? cur.address,
      phone: (b['phone'] as String?) ?? cur.phone,
      coordinates: b['coordinates'] == null ? cur.coordinates : CoordinatesDto.fromJson((b['coordinates'] as Map).cast<String, dynamic>()),
      isDefault: (b['isDefault'] as bool?) ?? cur.isDefault,
      zone: (b['zone'] as String?) ?? cur.zone,
    );
    list[idx] = updated;
    if (updated.isDefault) {
      for (var i = 0; i < list.length; i++) {
        if (i != idx) {
          final o = list[i];
          list[i] = AddressDto(id: o.id, title: o.title, address: o.address, phone: o.phone, coordinates: o.coordinates, isDefault: false, zone: o.zone);
        }
      }
    }
    return _json(updated.toJson());
  }));

  r.delete('/addresses/<id>', _auth((req, user) async {
    addressesByUser[user.id]!.removeWhere((a) => a.id == req.params['id']);
    return _json({'deleted': true});
  }));

  // Polygon-based serviceability: point-in-polygon against delivery zones.
  r.post('/delivery/check-zone', (Request req) async {
    final b = await _body(req);
    final lat = (b['latitude'] as num?)?.toDouble() ?? 0;
    final lng = (b['longitude'] as num?)?.toDouble() ?? 0;
    final zone = findZoneForPoint(lat, lng);
    return _json(CheckZoneResultDto(serviceable: zone != null, zone: zone?.id).toJson());
  });

  // ---- orders ----
  r.post('/orders', _auth((req, user) async {
    final priced = viewCart(user.id);
    if (priced.items.isEmpty) return _err(400, 'cart is empty');
    final reqBody = CreateOrderRequest.fromJson(await _body(req));
    final address = (addressesByUser[user.id] ?? []).where((a) => a.id == reqBody.addressId).firstOrNull;
    final now = _nowIso();
    final order = OrderDto(
      id: nextId('order'),
      items: priced.items,
      deliveryAddress: address,
      deliveryTime: reqBody.deliveryTime,
      foodRemarks: reqBody.foodRemarks,
      deliveryRemarks: reqBody.deliveryRemarks,
      isGift: reqBody.isGift,
      giftMessage: reqBody.giftMessage,
      couponCode: priced.couponCode,
      subtotal: priced.subtotal,
      discount: priced.discount,
      deliveryCharge: priced.deliveryCharge,
      total: priced.total,
      paymentMethod: reqBody.paymentMethod,
      status: 'received',
      statusHistory: [OrderStatusEntryDto(status: 'received', at: now)],
      createdAt: now,
    );
    ordersByUser[user.id]!.insert(0, order);
    carts[user.id] = RawCart(); // clear cart
    notificationsByUser[user.id]!.insert(0, NotificationDto(
      id: nextId('ntf'), type: 'order_status', title: 'Order received',
      body: 'Your order ${order.id} has been received.',
      data: {'targetScreen': 'order_detail', 'orderId': order.id}, sentAt: now,
    ));
    return _json(order.toJson(), status: 201);
  }));

  r.get('/orders', _auth((req, user) async => _json((ordersByUser[user.id] ?? []).map((o) => o.toJson()).toList())));

  r.get('/orders/<id>', _auth((req, user) async {
    final order = (ordersByUser[user.id] ?? []).where((o) => o.id == req.params['id']).firstOrNull;
    return order == null ? _err(404, 'not found') : _json(order.toJson());
  }));

  // Full-order cancellation with a reason (no item-level cancel in the mock).
  r.post('/orders/<id>/cancel', _auth((req, user) async {
    final list = ordersByUser[user.id] ?? [];
    final idx = list.indexWhere((o) => o.id == req.params['id']);
    if (idx < 0) return _err(404, 'not found');
    final order = list[idx];
    if (order.status == 'delivered' || order.status == 'cancelled') {
      return _err(400, 'order can no longer be cancelled');
    }
    final b = await _body(req);
    final reason = (b['reason'] as String?) ?? 'Cancelled by customer';
    final now = _nowIso();
    final updated = order.copyWith(
      status: 'cancelled',
      cancelReason: reason,
      statusHistory: [...order.statusHistory, OrderStatusEntryDto(status: 'cancelled', at: now)],
    );
    list[idx] = updated;
    notificationsByUser[user.id]!.insert(0, NotificationDto(
      id: nextId('ntf'), type: 'order_status', title: 'Order cancelled',
      body: 'Order ${order.id} was cancelled.',
      data: {'targetScreen': 'order_detail', 'orderId': order.id}, sentAt: now,
    ));
    return _json(updated.toJson());
  }));

  // Partial / item-level cancellation: cancel specific line items with a reason.
  // The rest of the order stays; subtotal/total are recomputed from the
  // non-cancelled lines. If all lines end up cancelled, this becomes a full cancel.
  r.post('/orders/<id>/cancel-items', _auth((req, user) async {
    final list = ordersByUser[user.id] ?? [];
    final idx = list.indexWhere((o) => o.id == req.params['id']);
    if (idx < 0) return _err(404, 'not found');
    final order = list[idx];
    if (order.status == 'delivered' || order.status == 'cancelled') {
      return _err(400, 'order can no longer be cancelled');
    }
    final b = await _body(req);
    final lineIds = ((b['lineIds'] as List?) ?? []).map((e) => e as String).toSet();
    final reason = (b['reason'] as String?) ?? 'Cancelled by customer';
    if (lineIds.isEmpty) return _err(400, 'no line items selected');

    // Mark the requested (not-already-cancelled) lines as cancelled.
    final items = order.items.map((li) {
      if (lineIds.contains(li.id) && !li.cancelled) {
        return CartLineDto(
          id: li.id,
          productId: li.productId,
          name: li.name,
          imageUrl: li.imageUrl,
          qty: li.qty,
          basePrice: li.basePrice,
          selectedAddons: li.selectedAddons,
          notes: li.notes,
          lineTotal: li.lineTotal,
          cancelled: true,
        );
      }
      return li;
    }).toList();

    // Recompute subtotal/total from the NON-cancelled lines (keep delivery logic).
    final active = items.where((li) => !li.cancelled).toList();
    final allCancelled = active.isEmpty;
    final subtotal = active.fold<num>(0, (s, i) => s + i.lineTotal);
    final coupon = findCoupon(order.couponCode);
    num discount = 0;
    if (!allCancelled && coupon != null && subtotal >= coupon.minOrder) {
      discount = coupon.type == 'flat' ? coupon.value : (subtotal * coupon.value / 100).round();
    }
    final deliveryCharge = allCancelled ? 0 : order.deliveryCharge;
    final total = (subtotal - discount).clamp(0, double.infinity) + deliveryCharge;

    final now = _nowIso();
    final updated = OrderDto(
      id: order.id,
      items: items,
      deliveryAddress: order.deliveryAddress,
      deliveryTime: order.deliveryTime,
      foodRemarks: order.foodRemarks,
      deliveryRemarks: order.deliveryRemarks,
      isGift: order.isGift,
      giftMessage: order.giftMessage,
      couponCode: order.couponCode,
      subtotal: subtotal,
      discount: discount,
      deliveryCharge: deliveryCharge,
      total: total,
      paymentMethod: order.paymentMethod,
      status: allCancelled ? 'cancelled' : order.status,
      statusHistory: [
        ...order.statusHistory,
        OrderStatusEntryDto(status: allCancelled ? 'cancelled' : 'items_cancelled', at: now),
      ],
      createdAt: order.createdAt,
      cancelReason: allCancelled ? reason : order.cancelReason,
      feedbackRating: order.feedbackRating,
      feedbackComment: order.feedbackComment,
    );
    list[idx] = updated;
    notificationsByUser[user.id]!.insert(0, NotificationDto(
      id: nextId('ntf'), type: 'order_status',
      title: allCancelled ? 'Order cancelled' : 'Items cancelled',
      body: allCancelled
          ? 'Order ${order.id} was cancelled.'
          : 'Some items in order ${order.id} were cancelled.',
      data: {'targetScreen': 'order_detail', 'orderId': order.id}, sentAt: now,
    ));
    return _json(updated.toJson());
  }));

  // "Contact the Crew" / Get Help — record a support request against an order.
  r.post('/orders/<id>/help', _auth((req, user) async {
    final id = req.params['id'];
    final exists = (ordersByUser[user.id] ?? []).any((o) => o.id == id);
    if (!exists) return _err(404, 'not found');
    final b = await _body(req);
    final ticket = {
      'id': nextId('help'),
      'orderId': id,
      'userId': user.id,
      'topic': (b['topic'] as String?) ?? 'General',
      'message': (b['message'] as String?) ?? '',
      'status': 'open',
      'at': _nowIso(),
    };
    helpTickets.add(ticket);
    return _json(ticket, status: 201);
  }));

  // Dev/demo: advance an order to the next status (no kitchen to do it for real).
  r.post('/orders/<id>/advance', _auth((req, user) async {
    final list = ordersByUser[user.id] ?? [];
    final idx = list.indexWhere((o) => o.id == req.params['id']);
    if (idx < 0) return _err(404, 'not found');
    final order = list[idx];
    const stages = ['received', 'preparing', 'out_for_delivery', 'delivered'];
    final cur = stages.indexOf(order.status);
    if (order.status == 'cancelled' || cur < 0 || cur >= stages.length - 1) {
      return _err(400, 'order cannot advance');
    }
    final next = stages[cur + 1];
    final now = _nowIso();
    final updated = order.copyWith(
      status: next,
      statusHistory: [...order.statusHistory, OrderStatusEntryDto(status: next, at: now)],
    );
    list[idx] = updated;
    notificationsByUser[user.id]!.insert(0, NotificationDto(
      id: nextId('ntf'), type: 'order_status', title: 'Order update',
      body: 'Order ${order.id} is now ${next.replaceAll('_', ' ')}.',
      data: {'targetScreen': 'order_detail', 'orderId': order.id}, sentAt: now,
    ));
    return _json(updated.toJson());
  }));

  // Post-delivery feedback (rating 1..5 + optional comment).
  r.post('/orders/<id>/feedback', _auth((req, user) async {
    final list = ordersByUser[user.id] ?? [];
    final idx = list.indexWhere((o) => o.id == req.params['id']);
    if (idx < 0) return _err(404, 'not found');
    final order = list[idx];
    if (order.status != 'delivered') return _err(400, 'feedback is only available after delivery');
    final b = await _body(req);
    final rating = (b['rating'] as num?)?.toInt() ?? 0;
    if (rating < 1 || rating > 5) return _err(400, 'rating must be 1..5');
    final updated = order.copyWith(feedbackRating: rating, feedbackComment: (b['comment'] as String?) ?? '');
    list[idx] = updated;
    return _json(updated.toJson());
  }));

  // ---- crisps ----
  r.get('/crisps', (Request _) => _json(crisps.map((c) => CrispDto(id: c.id, title: c.title, cover: c.cover, publishedAt: c.publishedAt).toJson()).toList()));
  r.get('/crisps/<id>', (Request _, String id) {
    final c = crisps.where((x) => x.id == id).firstOrNull;
    return c == null ? _err(404, 'not found') : _json(c.toJson());
  });

  // ---- notifications ----
  r.get('/notifications', _auth((req, user) async => _json((notificationsByUser[user.id] ?? []).map((n) => n.toJson()).toList())));

  r.post('/notifications/<id>/read', _auth((req, user) async {
    final id = req.params['id'];
    final list = notificationsByUser[user.id] ?? [];
    final idx = list.indexWhere((n) => n.id == id);
    if (idx < 0) return _err(404, 'not found');
    final n = list[idx];
    list[idx] = NotificationDto(id: n.id, type: n.type, title: n.title, body: n.body, imageUrl: n.imageUrl, data: n.data, read: true, sentAt: n.sentAt);
    return _json(list[idx].toJson());
  }));

  r.post('/notifications/test-push', _auth((req, user) async {
    final b = await _body(req);
    final n = NotificationDto(
      id: nextId('ntf'), type: (b['type'] as String?) ?? 'promo', title: 'Test push',
      body: 'This is a simulated push.', data: const {'targetScreen': 'home'}, sentAt: _nowIso(),
    );
    notificationsByUser[user.id]!.insert(0, n);
    return _json(n.toJson(), status: 201);
  }));

  return r;
}

// Permissive CORS for local dev (web/emulator clients).
Middleware _cors() => (Handler inner) => (Request req) async {
      const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      };
      if (req.method == 'OPTIONS') return Response.ok('', headers: headers);
      final res = await inner(req);
      return res.change(headers: {...res.headers, ...headers});
    };

void main(List<String> args) async {
  seedDemoUser();
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 3000;
  final handler = const Pipeline().addMiddleware(logRequests()).addMiddleware(_cors()).addHandler(_buildRouter().call);
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Kitchen Crew mock server on http://localhost:${server.port}');
}
