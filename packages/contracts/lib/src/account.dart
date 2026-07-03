import 'common.dart';

class UserDto {
  final String id;
  final String name;
  final String email;
  final String phone;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory UserDto.fromJson(Map<String, dynamic> j) => UserDto(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'email': email, 'phone': phone};
}

/// Response of /auth/login, /auth/register, /auth/otp/verify.
class AuthResultDto {
  final String token;
  final UserDto user;

  const AuthResultDto({required this.token, required this.user});

  factory AuthResultDto.fromJson(Map<String, dynamic> j) => AuthResultDto(
        token: j['token'] as String,
        user: UserDto.fromJson(j['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}

class AddressDto {
  final String id;
  final String title;
  final String address;
  final String phone;
  final CoordinatesDto? coordinates;
  final bool isDefault;
  final String? zone;

  const AddressDto({
    required this.id,
    required this.title,
    required this.address,
    required this.phone,
    this.coordinates,
    this.isDefault = false,
    this.zone,
  });

  factory AddressDto.fromJson(Map<String, dynamic> j) => AddressDto(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        address: j['address'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        coordinates: j['coordinates'] == null
            ? null
            : CoordinatesDto.fromJson(j['coordinates'] as Map<String, dynamic>),
        isDefault: j['isDefault'] as bool? ?? false,
        zone: j['zone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'address': address,
        'phone': phone,
        'coordinates': coordinates?.toJson(),
        'isDefault': isDefault,
        'zone': zone,
      };
}

class NotificationDto {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final bool read;
  final String sentAt;

  const NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data = const {},
    this.read = false,
    required this.sentAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> j) => NotificationDto(
        id: j['id'] as String,
        type: j['type'] as String? ?? 'generic',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        imageUrl: j['imageUrl'] as String?,
        data: (j['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        read: j['read'] as bool? ?? false,
        sentAt: j['sentAt'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'data': data,
        'read': read,
        'sentAt': sentAt,
      };
}

class CheckZoneResultDto {
  final bool serviceable;
  final String? zone;

  const CheckZoneResultDto({required this.serviceable, this.zone});

  factory CheckZoneResultDto.fromJson(Map<String, dynamic> j) =>
      CheckZoneResultDto(serviceable: j['serviceable'] as bool? ?? false, zone: j['zone'] as String?);

  Map<String, dynamic> toJson() => {'serviceable': serviceable, 'zone': zone};
}
