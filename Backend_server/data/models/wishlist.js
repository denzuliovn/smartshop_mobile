import mongoose from "mongoose";

const Schema = mongoose.Schema;

export const WishlistSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    productId: {
      type: Schema.Types.ObjectId,
      ref: 'Product',
      required: true,
    },
  },
  {
    collection: "wishlists",
    timestamps: true, // Tự động thêm createdAt và updatedAt
  }
);

// Tạo một index kết hợp để đảm bảo một user chỉ có thể "thích" một sản phẩm một lần
WishlistSchema.index({ userId: 1, productId: 1 }, { unique: true });