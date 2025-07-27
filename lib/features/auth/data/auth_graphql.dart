class AuthGraphQL {
  static const String loginMutation = r'''
    mutation Login($input: LoginInput!) {
      login(input: $input) {
        success
        message
        data {
          jwt
          user { _id username email firstName lastName role }
        }
      }
    }
  ''';

  static const String registerMutation = r'''
    mutation Register($input: RegisterInput!) {
      register(input: $input) {
        success
        message
      }
    }
  ''';
}