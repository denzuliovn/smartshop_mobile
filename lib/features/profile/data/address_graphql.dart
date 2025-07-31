// FILE PATH: lib/features/profile/data/address_graphql.dart

class AddressGraphQL {
  // Fragment giúp tái sử dụng, đảm bảo luôn trả về UserInfo đầy đủ
  static const String userFragmentForAddress = r'''
    fragment UserDataWithAddresses on UserInfo {
      _id, username, email, firstName, lastName, role, avatarUrl
      addresses { _id, fullName, phone, address, city, isDefault }
    }
  ''';

  static const String addAddress = '''
    mutation AddAddress(\$input: AddressInput!) {
      addAddress(input: \$input) { ...UserDataWithAddresses }
    }
    $userFragmentForAddress
  ''';

  static const String updateAddress = '''
    mutation UpdateAddress(\$addressId: ID!, \$input: AddressInput!) {
      updateAddress(addressId: \$addressId, input: \$input) { ...UserDataWithAddresses }
    }
    $userFragmentForAddress
  ''';

  static const String deleteAddress = '''
    mutation DeleteAddress(\$addressId: ID!) {
      deleteAddress(addressId: \$addressId) { ...UserDataWithAddresses }
    }
    $userFragmentForAddress
  ''';

  static const String setDefaultAddress = '''
    mutation SetDefaultAddress(\$addressId: ID!) {
      setDefaultAddress(addressId: \$addressId) { ...UserDataWithAddresses }
    }
    $userFragmentForAddress
  ''';
}