class Accessories {
  Accessories({
    required String id,
    required String name,
    required String imageUrl,
    required String createdAt,
    required String updatedAt,
    required num v,
  })  : _id = id,
        _name = name,
        _imageUrl = imageUrl,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _v = v;

  Accessories.fromJson(Map<String, dynamic> json)
      : _id = json['_id'] ?? '',
        _name = json['name'] ?? '',
        _imageUrl = json['imageUrl'] ?? '',
        _createdAt = json['createdAt'] ?? '',
        _updatedAt = json['updatedAt'] ?? '',
        _v = json['__v'] ?? 0;

  final String _id;
  final String _name;
  final String _imageUrl;
  final String _createdAt;
  final String _updatedAt;
  final num _v;

  Accessories copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    return Accessories(
      id: id ?? _id,
      name: name ?? _name,
      imageUrl: imageUrl ?? _imageUrl,
      createdAt: createdAt ?? _createdAt,
      updatedAt: updatedAt ?? _updatedAt,
      v: v ?? _v,
    );
  }

  String get id => _id;
  String get name => _name;
  String get imageUrl => _imageUrl;
  String get createdAt => _createdAt;
  String get updatedAt => _updatedAt;
  num get v => _v;

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'name': _name,
      'imageUrl': _imageUrl,
      'createdAt': _createdAt,
      'updatedAt': _updatedAt,
      '__v': _v,
    };
  }
}
