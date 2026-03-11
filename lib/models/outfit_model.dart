class Outfitsmodel {
  String? _id;
  String? _name;
  String? _imageUrl;
  String? _createdAt;
  String? _updatedAt;
  num? _v;

  static const String baseUrl = 'https://tubbzyourself.techons.co.uk';

  Outfitsmodel({
    String? id,
    String? name,
    String? imageUrl,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _name = name;
    _imageUrl = imageUrl;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Outfitsmodel.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];

    String? path = json['imageUrl'];
    if (path != null && path.startsWith('/')) {
      _imageUrl = baseUrl + path;
    } else {
      _imageUrl = path;
    }

    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }

  Outfitsmodel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Outfitsmodel(
        id: id ?? _id,
        name: name ?? _name,
        imageUrl: imageUrl ?? _imageUrl,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );

  String? get id => _id;
  String? get name => _name;
  String? get imageUrl => _imageUrl;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['imageUrl'] = _imageUrl;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}
