// File: server/graphql/authentication.js (HOÀN CHỈNH VÀ CLEAN)

import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { GraphQLError } from "graphql";
import { otpUtils } from "../utils/otpUtils.js";
import { emailService } from "../services/emailService.js";

import fs from "fs";
import { dirname } from "path";
import { fileURLToPath } from "url";
import { v4 as uuidv4 } from "uuid";
import path from "path"; 

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export const typeDef = `
  type LoginResult {
    jwt: String!
    user: UserInfo!
  }

  type UserInfo {
    _id: ID!
    username: String!
    email: String!
    firstName: String
    lastName: String
    role: String!
    avatarUrl: String
    addresses: [Address!]
  }

  type Address {
    _id: ID!
    fullName: String!
    phone: String!
    address: String!
    city: String!
    isDefault: Boolean!
  }

  type LoginResponse {
    success: Boolean!
    message: String!
    data: LoginResult
  }

  type RegisterResponse {
    success: Boolean!
    message: String!
    data: UserInfo
  }

  type GenericResponse {
    success: Boolean!
    message: String!
  }

  input AddressInput {
    fullName: String!
    phone: String!
    address: String!
    city: String!
    isDefault: Boolean
  }

  input LoginInput {
    username: String!
    password: String!
  }

  input RegisterInput {
    username: String!
    email: String!
    password: String!
    firstName: String!
    lastName: String!
    phone: String
  }

  input SendOTPInput {
    email: String!
  }

  input VerifyOTPAndResetPasswordInput {
    email: String!
    otp: String!
    newPassword: String!
  }

  input UpdateProfileInput {
    firstName: String
    lastName: String
    phone: String
  }

  extend type Mutation {
    login(input: LoginInput!): LoginResponse
    register(input: RegisterInput!): RegisterResponse
    sendPasswordResetOTP(input: SendOTPInput!): GenericResponse
    verifyOTPAndResetPassword(input: VerifyOTPAndResetPasswordInput!): GenericResponse
    updateProfile(input: UpdateProfileInput!): UserInfo!
    updateAvatar(file: File!): UserInfo!
    addAddress(input: AddressInput!): UserInfo!
    updateAddress(addressId: ID!, input: AddressInput!): UserInfo!
    deleteAddress(addressId: ID!): UserInfo!
    setDefaultAddress(addressId: ID!): UserInfo!
  }

  extend type Query {
    me: UserInfo
  }
`;

export const resolvers = {
  Query: {
    me: async (parent, args, context, info) => {
      if (!context.user) {
        throw new GraphQLError("Authentication required");
      }
      
      const user = await context.db.users.findById(context.user.id);
      if (!user) {
        throw new GraphQLError("User not found");
      }
      
      return {
        _id: user._id,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        avatarUrl: user.avatarUrl,
      };
    },
  },

  Mutation: {
    addAddress: async (parent, { input }, context) => {
      if (!context.user) throw new GraphQLError("Authentication required");

      const user = await context.db.users.findById(context.user.id);
      if (!user) throw new GraphQLError("User not found");

      // Nếu đây là địa chỉ đầu tiên, hoặc được set là mặc định,
      // hãy đảm bảo các địa chỉ khác không phải là mặc định
      if (input.isDefault || user.addresses.length === 0) {
        user.addresses.forEach(addr => addr.isDefault = false);
        input.isDefault = true;
      }

      user.addresses.push(input);
      await user.save();
      return user;
    },

    updateAddress: async (parent, { addressId, input }, context) => {
      if (!context.user) throw new GraphQLError("Authentication required");

      const user = await context.db.users.findById(context.user.id);
      const address = user.addresses.id(addressId);
      if (!address) throw new GraphQLError("Address not found");

      // Xử lý isDefault
      if (input.isDefault) {
        user.addresses.forEach(addr => addr.isDefault = false);
      }

      // Cập nhật các trường
      address.set(input);

      await user.save();
      return user;
    },

    deleteAddress: async (parent, { addressId }, context) => {
      if (!context.user) throw new GraphQLError("Authentication required");

      const user = await context.db.users.findById(context.user.id);
      const address = user.addresses.id(addressId);
      if (!address) throw new GraphQLError("Address not found");

      const wasDefault = address.isDefault;
      address.remove();

      // Nếu địa chỉ bị xóa là mặc định, và vẫn còn địa chỉ khác,
      // hãy đặt địa chỉ đầu tiên làm mặc định mới.
      if (wasDefault && user.addresses.length > 0) {
        user.addresses[0].isDefault = true;
      }

      await user.save();
      return user;
    },

    setDefaultAddress: async (parent, { addressId }, context) => {
      if (!context.user) throw new GraphQLError("Authentication required");

      const user = await context.db.users.findById(context.user.id);

      // Set tất cả về false trước
      user.addresses.forEach(addr => addr.isDefault = false);

      // Tìm và set địa chỉ mới là true
      const address = user.addresses.id(addressId);
      if (!address) throw new GraphQLError("Address not found");
      address.isDefault = true;

      await user.save();
      return user;
    },
    updateProfile: async (parent, { input }, context, info) => {
      if (!context.user) {
        throw new GraphQLError("Authentication required");
      }
      const updateData = Object.fromEntries(
        Object.entries(input).filter(([_, v]) => v != null)
      );
      if (Object.keys(updateData).length === 0) {
        throw new GraphQLError("Nothing to update.");
      }
      const updatedUser = await context.db.users.updateById(context.user.id, updateData);
      if (!updatedUser) {
        throw new GraphQLError("Failed to update profile.");
      }
      return updatedUser;
    },

    updateAvatar: async (parent, { file }, context) => {
      if (!context.user) {
        throw new GraphQLError("Authentication required");
      }
      try {
        const fileArrayBuffer = await file.arrayBuffer();
        const originalName = file.name;
        const fileExtension = path.extname(originalName);
        const uniqueFilename = `avatar_${context.user.id}_${Date.now()}${fileExtension}`;
        const uploadDir = path.join(__dirname, "../img/");
        if (!fs.existsSync(uploadDir)) {
          fs.mkdirSync(uploadDir, { recursive: true });
        }
        await fs.promises.writeFile(
          path.join(uploadDir, uniqueFilename),
          Buffer.from(fileArrayBuffer)
        );
        const fileUrl = `/img/${uniqueFilename}`;
        const updatedUser = await context.db.users.updateById(context.user.id, {
          avatarUrl: fileUrl
        });
        if (!updatedUser) {
          throw new GraphQLError("Could not update user avatar in database.");
        }
        return updatedUser;
      } catch (error) {
        console.error("Update avatar error:", error);
        throw new GraphQLError(`Failed to upload avatar: ${error.message}`);
      }
    }, 

    login: async (parent, args, context, info) => {
      const { username, password } = args.input;
      
      if (!username || username.length === 0 || !password || password.length === 0) {
        return {
          success: false,
          message: "Username and password are required",
        };
      }

      const user = await context.db.users.findOne(username);
      if (!user) {
        return {
          success: false,
          message: "Invalid username or password",
        };
      }

      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        return {
          success: false,
          message: "Invalid username or password",
        };
      }

      if (!user.isActive) {
        return {
          success: false,
          message: "Account is deactivated. Please contact support.",
        };
      }

      const token = jwt.sign(
        {
          id: user._id,
          username: user.username,
          role: user.role,
        },
        process.env.JWT_SECRET,
        {
          expiresIn: "24h",
        }
      );

      return {
        success: true,
        message: "Login successful",
        data: {
          jwt: token,
          user: {
            _id: user._id,
            username: user.username,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            avatarUrl: user.avatarUrl,
          },
        },
      };
    },

    register: async (parent, args, context, info) => {
      const { username, email, password, firstName, lastName, phone } = args.input;

      const existingUserByUsername = await context.db.users.findOne(username);
      if (existingUserByUsername) {
        return {
          success: false,
          message: "Username already exists",
        };
      }

      const existingUserByEmail = await context.db.users.findByEmail(email);
      if (existingUserByEmail) {
        return {
          success: false,
          message: "Email already exists",
        };
      }

      if (password.length < 6) {
        return {
          success: false,
          message: "Password must be at least 6 characters long",
        };
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const newUser = await context.db.users.create({
        username,
        email,
        password: hashedPassword,
        firstName,
        lastName,
        phone,
        role: "customer",
        isActive: true,
      });

      return {
        success: true,
        message: "Registration successful",
        data: {
          _id: newUser._id,
          username: newUser.username,
          email: newUser.email,
          firstName: newUser.firstName,
          lastName: newUser.lastName,
          role: newUser.role,
          avatarUrl: newUser.avatarUrl,
        },
      };
    },


    sendPasswordResetOTP: async (parent, args, context, info) => {
      const { email } = args.input;

      console.log('=== SEND OTP REQUEST ===');
      console.log('Email:', email);

      if (!email || !email.includes('@')) {
        return {
          success: false,
          message: "Valid email address is required",
        };
      }

      const user = await context.db.users.findByEmail(email);
      console.log('User found:', user ? 'Yes' : 'No');
      
      if (!user) {
        // ===== THAY ĐỔI: Trả về success false cho email không tồn tại =====
        return {
          success: false,
          message: "Email không tồn tại trong hệ thống. Vui lòng kiểm tra lại.",
        };
        
        // HOẶC nếu muốn giữ bảo mật, có thể delay và trả về như đã gửi:
        // await new Promise(resolve => setTimeout(resolve, 2000)); // Delay 2s
        // return {
        //   success: true,
        //   message: "Nếu email tồn tại, mã OTP đã được gửi.",
        // };
      }

      if (!user.isActive) {
        return {
          success: false,
          message: "Account is deactivated. Please contact support.",
        };
      }

      const otp = otpUtils.generateOTP();
      const otpExpires = otpUtils.generateOTPExpiry();

      console.log('Generated OTP:', otp);
      console.log('OTP expires at:', otpExpires);

      try {
        const updateResult = await context.db.users.savePasswordResetOTP(email, otp, otpExpires);
        console.log('OTP saved to DB:', updateResult.modifiedCount > 0 ? 'Yes' : 'No');

        await emailService.sendPasswordResetOTP(email, otp, user.firstName || user.username);
        console.log('OTP email sent successfully');

        return {
          success: true,
          message: "OTP has been sent to your email. Please check your inbox.", // ← Message này sẽ được frontend check
        };

      } catch (error) {
        console.error('Send OTP error:', error);
        return {
          success: false,
          message: "Failed to send OTP. Please try again later.",
        };
      }
    },

    verifyOTPAndResetPassword: async (parent, args, context, info) => {
      const { email, otp, newPassword } = args.input;

      console.log('=== VERIFY OTP AND RESET PASSWORD ===');
      console.log('Email:', email);
      console.log('OTP:', otp);

      if (!email || !otp || !newPassword) {
        return {
          success: false,
          message: "Email, OTP, and new password are required",
        };
      }

      if (!otpUtils.isValidOTPFormat(otp)) {
        return {
          success: false,
          message: "OTP must be 6 digits",
        };
      }

      if (newPassword.length < 6) {
        return {
          success: false,
          message: "Password must be at least 6 characters long",
        };
      }

      try {
        const user = await context.db.users.findByValidOTP(email, otp);
        console.log('User with valid OTP found:', user ? 'Yes' : 'No');

        if (!user) {
          return {
            success: false,
            message: "Invalid or expired OTP",
          };
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        const updateResult = await context.db.users.resetPasswordAndClearOTP(user._id, hashedPassword);
        console.log('Password reset successful:', updateResult.modifiedCount > 0 ? 'Yes' : 'No');

        return {
          success: true,
          message: "Password has been successfully reset. You can now login with your new password.",
        };

      } catch (error) {
        console.error('Verify OTP and reset password error:', error);
        return {
          success: false,
          message: "Failed to reset password. Please try again later.",
        };
      }
    },
  },
};