class ReviewGraphQL {
  static const String reviewFragment = r'''
    fragment ReviewData on Review {
      _id
      rating
      comment
      createdAt
      user {
        _id
        firstName
        lastName
        avatarUrl # Giả sử có trường này
      }
    }
  ''';
  
  static const String getProductReviews = '''
    query GetProductReviews(\$productId: ID!) {
      getProductReviews(productId: \$productId) {
        ...ReviewData
      }
    }
    $reviewFragment
  ''';

  static const String createReview = '''
    mutation CreateReview(\$input: CreateReviewInput!) {
      createReview(input: \$input) {
        ...ReviewData
      }
    }
    $reviewFragment
  ''';
}
