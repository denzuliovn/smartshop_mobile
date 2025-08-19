import mongoose from "mongoose";

export const typeDef = `
  type WishlistItem {
    _id: ID!
    userId: ID!
    product: Product!
    createdAt: String
  }

  extend type Query {
    # Lấy danh sách yêu thích của người dùng hiện tại
    myWishlist: [WishlistItem!]!
    
    # Kiểm tra xem một sản phẩm có trong wishlist không (để hiển thị icon trái tim)
    isProductInWishlist(productId: ID!): Boolean!
  }

  extend type Mutation {
    # Thêm một sản phẩm vào wishlist
    addToWishlist(productId: ID!): WishlistItem!

    # Xóa một sản phẩm khỏi wishlist
    removeFromWishlist(productId: ID!): Boolean!
  }
`;

export const resolvers = {
  Query: {
    myWishlist: async (parent, args, context) => {
      if (!context.user) throw new Error("Authentication required");
      
      const wishlistItems = await context.db.wishlists.findByUserId(context.user.id);
      return wishlistItems;
    },
    
    isProductInWishlist: async (parent, { productId }, context) => {
      if (!context.user) return false;
      
      const item = await context.db.wishlists.findOne(context.user.id, productId);
      return !!item; // Trả về true nếu tìm thấy, ngược lại trả về false
    },
  },

  Mutation: {
    addToWishlist: async (parent, { productId }, context) => {
      if (!context.user) throw new Error("Authentication required");
      
      // Kiểm tra xem sản phẩm có tồn tại không
      const product = await context.db.products.findById(productId);
      if (!product) throw new Error("Product not found");

      // Tạo mới trong wishlist
      const newItem = await context.db.wishlists.create(context.user.id, productId);
      return newItem;
    },

    removeFromWishlist: async (parent, { productId }, context) => {
      if (!context.user) throw new Error("Authentication required");

      const success = await context.db.wishlists.remove(context.user.id, productId);
      return success;
    },
  },
  
  // Resolver cho các trường lồng nhau
  WishlistItem: {
    product: async (parent, args, context) => {
      return await context.db.products.findById(parent.productId);
    }
  }
};