import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';
import 'package:gizmoglobe_client/objects/address_related/district.dart';
import 'package:gizmoglobe_client/objects/address_related/province.dart';
import 'package:gizmoglobe_client/objects/address_related/ward.dart';

class ChooseAddressScreenState with EquatableMixin {
  final List<Address> addressList;

  const ChooseAddressScreenState({
    this.addressList = const [],
  });

  @override
  List<Object?> get props => [addressList];

  ChooseAddressScreenState copyWith({
    List<Address>? addressList,
  }) {
    return ChooseAddressScreenState(
      addressList: addressList ?? this.addressList,
    );
  }
}