class Device {
  final String id;
  final String name;
  final String brand;
  final String image;
  final String price;
  final String processor;
  final String ram;
  final String storage;
  final String battery;
  final String camera;
  final String display;

  Device({
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    required this.processor,
    required this.ram,
    required this.storage,
    required this.battery,
    required this.camera,
    required this.display,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    final nameStr = json['name']?.toString() ?? '';
    final brandStr = json['brand']?.toString() ?? '';

    return Device(
      // Uses existing JSON 'id' or generates a fallback string from brand and name
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '${brandStr}_$nameStr',
      name: nameStr,
      brand: brandStr,
      image: json['image']?.toString() ??
          json['imgUrl']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      price: json['price']?.toString() ?? '',
      processor: json['processor']?.toString() ?? '',
      ram: json['ram']?.toString() ?? '',
      storage: json['storage']?.toString() ?? '',
      battery: json['battery']?.toString() ?? '',
      camera: json['camera']?.toString() ?? '',
      display: json['display']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'image': image,
      'price': price,
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'battery': battery,
      'camera': camera,
      'display': display,
    };
  }
}