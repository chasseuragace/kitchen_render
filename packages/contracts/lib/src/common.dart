/// Geographic coordinate pair.
class CoordinatesDto {
  final double latitude;
  final double longitude;

  const CoordinatesDto({required this.latitude, required this.longitude});

  factory CoordinatesDto.fromJson(Map<String, dynamic> j) => CoordinatesDto(
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'latitude': latitude, 'longitude': longitude};
}

/// A single selectable option inside an addon group (e.g. "Large", "+Cheese").
class AddonOptionDto {
  final String id;
  final String name;
  final num price;

  const AddonOptionDto({required this.id, required this.name, required this.price});

  factory AddonOptionDto.fromJson(Map<String, dynamic> j) => AddonOptionDto(
        id: j['id'] as String,
        name: j['name'] as String,
        price: (j['price'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}

/// A group of addon options. `type` is 'single' or 'multi'.
class AddonGroupDto {
  final String id;
  final String name;
  final String type;
  final bool required;
  final List<AddonOptionDto> options;

  const AddonGroupDto({
    required this.id,
    required this.name,
    required this.type,
    required this.required,
    required this.options,
  });

  factory AddonGroupDto.fromJson(Map<String, dynamic> j) => AddonGroupDto(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String? ?? 'single',
        required: j['required'] as bool? ?? false,
        options: (j['options'] as List? ?? [])
            .map((e) => AddonOptionDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'required': required,
        'options': options.map((e) => e.toJson()).toList(),
      };
}
