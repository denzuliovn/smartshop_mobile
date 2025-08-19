// File: server/data/models/user.js
// CẬP NHẬT User Schema để thêm các field cho forgot password

import mongoose from "mongoose";

let Schema = mongoose.Schema;
let String = Schema.Types.String;

// ===== THÊM SCHEMA MỚI CHO ĐỊA CHỈ =====
const AddressSchema = new Schema({
  fullName: { type: String, required: true },
  phone: { type: String, required: true },
  address: { type: String, required: true },
  city: { type: String, required: true },
  isDefault: { type: Boolean, default: false },
});

export const UserSchema = new Schema(
  {
    username: {
      type: String,
      required: true,
      unique: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
    },
    firstName: String,
    lastName: String,
    avatarUrl: {
      type: String,
      default: null
    },
    role: {
      type: String,
      enum: ['admin', 'manager', 'customer'],
      default: 'customer',
    },
    phone: String,
    isActive: {
      type: Boolean,
      default: true,
    },
    addresses: [AddressSchema],   

    passwordResetOTP: {
      type: String,
      default: null
    },
    passwordResetOTPExpires: {
      type: Date,
      default: null
    },
    passwordResetEmail: {
      type: String, // Email được dùng để reset (để tránh confusion)
      default: null
    },
    
    // Email verification (giữ lại nếu cần)
    emailVerified: {
      type: Boolean,
      default: false
    },
    emailVerificationToken: {
      type: String,
      default: null
    }
  },
  {
    collection: "users",
    timestamps: true,
  }
);