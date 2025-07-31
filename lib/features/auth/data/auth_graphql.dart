class AuthGraphQL {
  static const String loginMutation = r'''
  mutation Login($input: LoginInput!) {
    login(input: $input) {
      success
      message
      data {
        jwt
        user {
          _id
          username
          email
          firstName
          lastName
          role
          avatarUrl 
        }
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

  static const String sendPasswordResetOTP = r'''
    mutation SendPasswordResetOTP($input: SendOTPInput!) {
      sendPasswordResetOTP(input: $input) {
        success
        message
      }
    }
  ''';

  static const String verifyOTPAndResetPassword = r'''
    mutation VerifyOTPAndResetPassword($input: VerifyOTPAndResetPasswordInput!) {
      verifyOTPAndResetPassword(input: $input) {
        success
        message
      }
    }
  ''';

}