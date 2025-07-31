// FILE PATH: lib/features/profile/data/profile_graphql.dart

class ProfileGraphQL {
  static const String updateProfile = r'''
    mutation UpdateProfile($input: UpdateProfileInput!) {
      updateProfile(input: $input) {
        _id
        username
        email
        firstName
        lastName
        role
        avatarUrl
      }
    }
  ''';

  static const String updateAvatar = r'''
    mutation UpdateAvatar($file: File!) {
      updateAvatar(file: $file) {
        _id
        username
        email
        firstName
        lastName
        role
        avatarUrl
      }
    }
  ''';
}