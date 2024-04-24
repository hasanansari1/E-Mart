import 'package:cloud_firestore/cloud_firestore.dart';

class AddressItem {
  AddressItem({
    required this.address,
    required this.name,
    required this.phone,
    required this.id,
  });
  late final String address;
  late final String name;
  late final String phone;
  late final String id;

  AddressItem.fromJson(DocumentSnapshot json) {
    address = json['address'];
    name = json['name'];
    phone = json['PhoneNumber'];
    id = json.id;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['address'] = address;
    _data['name'] = name;
    _data['PhoneNumber'] = phone;
    return _data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AddressItem &&
              runtimeType == other.runtimeType &&
              address == other.address &&
              name == other.name &&
              phone == other.phone &&
              id == other.id;

  @override
  int get hashCode =>
      address.hashCode ^ name.hashCode ^ phone.hashCode ^ id.hashCode;
}
