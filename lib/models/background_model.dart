class Background {
  final String id;
  final String name;
  final String imageUrl;
  final String createdAt;
  final String updatedAt;
  final int v;

  Background({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Background.fromJson(Map<String, dynamic> json) {
    return Background(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
