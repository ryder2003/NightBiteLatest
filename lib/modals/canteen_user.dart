class CanteenUser {
  CanteenUser({
    required this.image,
    required this.name,
    required this.contact,
    required this.id,
    required this.email,
    required this.address,
    required this.latitude,
    required this.longitude
  });
  late String image;
  late String name;
  late String contact;
  late String id;
  late String email;
  late String address;
  late double latitude;
  late double longitude;

  CanteenUser.fromJson(Map<String, dynamic> json){
    image = json['image'] ?? '';
    name = json['name']?? '';
    contact = json['contact']?? '';
    id = json['id']?? '';
    email = json['email']?? '';
    address = json['address']?? '';
    latitude = json['latitude']?? '';
    longitude = json['longitude']?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['created_at'] = contact;
    data['id'] = id;
    data['email'] = email;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}


