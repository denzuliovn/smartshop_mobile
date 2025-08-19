import { Category, User, Product, Brand, Cart, Order, OrderItem, Wishlist } from "./models/index.js";
import mongoose from "mongoose";

// Helper function to build sort options from GraphQL enum
const buildSortOptions = (orderBy, columnMapping) => {
  if (!orderBy) return { createdAt: -1 }; // Default sort
  
  const [field, direction] = orderBy.split('_');
  const fieldName = columnMapping[field] || 'createdAt';
  const sortDirection = direction === 'ASC' ? 1 : -1;
  
  return { [fieldName]: sortDirection };
};

// Helper function to build query conditions
const buildQueryConditions = (condition) => {
  console.log('🔍 [Backend] Received filter condition:', JSON.stringify(condition, null, 2));

  
  const query = {};
  
  if (!condition) return query;
  
  // Text search with regex (case insensitive)
  if (condition.name && condition.name.trim() !== '') {
    query.name = { $regex: condition.name.trim(), $options: 'i' };
  }
  
  if (condition.brand) {
    query.brand = condition.brand;
  }
  
  if (condition.country && condition.country.trim() !== '') {
    query.country = { $regex: condition.country.trim(), $options: 'i' };
  }
  
  // Exact matches
  if (condition.category) {
    query.category = condition.category;
  }
  
  if (condition.categories && condition.categories.length > 0) {
    query.categories = { $in: condition.categories };
  }
  
  if (condition.isActive !== undefined) {
    query.isActive = condition.isActive;
  }
  
  if (condition.isFeatured !== undefined) {
    query.isFeatured = condition.isFeatured;
  }
  
  // Range queries
  if (condition.price) {
    const priceQuery = {};
    if (condition.price.min !== undefined) {
      priceQuery.$gte = condition.price.min;
    }
    if (condition.price.max !== undefined) {
      priceQuery.$lte = condition.price.max;
    }
    if (Object.keys(priceQuery).length > 0) {
      query.price = priceQuery;
    }
  }
  
  if (condition.stock) {
    const stockQuery = {};
    if (condition.stock.min !== undefined) {
      stockQuery.$gte = condition.stock.min;
    }
    if (condition.stock.max !== undefined) {
      stockQuery.$lte = condition.stock.max;
    }
    if (Object.keys(stockQuery).length > 0) {
      query.stock = stockQuery;
    }
  }
  
  return query;
};

const db = {
  categories: {
    // New paginated method
    getAll: async ({ first = 10, offset = 0, orderBy = 'CREATED_DESC', condition } = {}) => {
      try {
        const columnMapping = {
          ID: '_id',
          NAME: 'name',
          CREATED: 'createdAt'
        };
        
        const query = buildQueryConditions(condition);
        const sortOptions = buildSortOptions(orderBy, columnMapping);
        
        console.log('Categories query:', query);
        console.log('Categories sort:', sortOptions);
        
        // Get total count
        const totalCount = await Category.countDocuments(query);
        
        // Ensure offset doesn't exceed total count
        const safeOffset = Math.min(offset, Math.max(0, totalCount - 1));
        
        // Get paginated items
        const items = await Category.find(query)
          .sort(sortOptions)
          .skip(safeOffset)
          .limit(first);
        
        return {
          items,
          totalCount
        };
      } catch (error) {
        console.error('Error in categories.getAll:', error);
        throw error;
      }
    },
    
    // Simple method for backward compatibility
    getAllSimple: async () => {
      return await Category.find({ isActive: true }).sort({ createdAt: -1 });
    },
    
    findById: async (id) => {
      return await Category.findById(id);
    },
    
    create: async (input) => {
      const category = new Category(input);
      return await category.save();
    },
    
    updateById: async (id, input) => {
      return await Category.findByIdAndUpdate(id, input, { new: true });
    },
    
    deleteById: async (id) => {
      const result = await Category.findByIdAndDelete(id);
      return result ? id : null;
    },
  },

  brands: {
    // New paginated method
    getAll: async ({ first = 10, offset = 0, orderBy = 'CREATED_DESC', condition } = {}) => {
      try {
        const columnMapping = {
          ID: '_id',
          NAME: 'name',
          FOUNDED: 'foundedYear',
          CREATED: 'createdAt'
        };
        
        const query = buildQueryConditions(condition);
        const sortOptions = buildSortOptions(orderBy, columnMapping);
        
        console.log('Brands query:', query);
        console.log('Brands sort:', sortOptions);
        
        // Get total count
        const totalCount = await Brand.countDocuments(query);
        
        // Ensure offset doesn't exceed total count
        const safeOffset = Math.min(offset, Math.max(0, totalCount - 1));
        
        // Get paginated items with population
        const items = await Brand.find(query)
          .populate('categories')
          .sort(sortOptions)
          .skip(safeOffset)
          .limit(first);
        
        return {
          items,
          totalCount
        };
      } catch (error) {
        console.error('Error in brands.getAll:', error);
        throw error;
      }
    },
    
    // Simple method for backward compatibility
    getAllSimple: async () => {
      return await Brand.find({ isActive: true })
        .populate('categories')
        .sort({ createdAt: -1 });
    },
    
    findById: async (id) => {
      return await Brand.findById(id).populate('categories');
    },
    
    findBySlug: async (slug) => {
      return await Brand.findOne({ slug }).populate('categories');
    },
    
    findByName: async (name) => {
      return await Brand.findOne({ name });
    },
    
    create: async (input) => {
      const brand = new Brand(input);
      const savedBrand = await brand.save();
      return await Brand.findById(savedBrand._id).populate('categories');
    },
    
    updateById: async (id, input) => {
      const updatedBrand = await Brand.findByIdAndUpdate(id, input, { new: true });
      return await Brand.findById(updatedBrand._id).populate('categories');
    },
    
    deleteById: async (id) => {
      const result = await Brand.findByIdAndDelete(id);
      return result ? id : null;
    },

    // Get featured brands
    getFeatured: async () => {
      return await Brand.find({ isFeatured: true, isActive: true })
        .populate('categories')
        .sort({ createdAt: -1 });
    },

    // Get brands by category
    getByCategory: async (categoryId) => {
      return await Brand.find({ categories: categoryId, isActive: true })
        .populate('categories')
        .sort({ name: 1 });
    },
  },

  products: {
    deleteManyByIds: async (ids) => {
        // Dùng Product model đã được import
        return await Product.deleteMany({ _id: { $in: ids } });
    },
    // New paginated method with filtering
    getAll: async ({ first = 10, offset = 0, orderBy = 'CREATED_DESC', condition } = {}) => {
      try {
        const columnMapping = {
          ID: '_id',
          NAME: 'name',
          PRICE: 'price',
          STOCK: 'stock',
          CREATED: 'createdAt'
        };
        
        const query = buildQueryConditions(condition);
        const sortOptions = buildSortOptions(orderBy, columnMapping);
        
        console.log('Products query:', query);
        console.log('Products sort:', sortOptions);
        
        // Get total count
        const totalCount = await Product.countDocuments(query);
        
        // Ensure offset doesn't exceed total count
        const safeOffset = Math.min(offset, Math.max(0, totalCount - 1));
        
        // Get paginated items with population
        const items = await Product.find(query)
          .populate('category')
          .populate('brand')
          .sort(sortOptions)
          .skip(safeOffset)
          .limit(first);
        
        return {
          items,
          totalCount
        };
      } catch (error) {
        console.error('Error in products.getAll:', error);
        throw error;
      }
    },
    
    // Search method
    search: async ({ query: searchQuery, first = 10, offset = 0, orderBy = 'CREATED_DESC' } = {}) => {
      try {
        const columnMapping = {
          ID: '_id',
          NAME: 'name',
          PRICE: 'price',
          STOCK: 'stock',
          CREATED: 'createdAt'
        };
        
        // Build search query
        const searchTerms = searchQuery.trim().split(/\s+/);
        const searchConditions = searchTerms.map(term => ({
          $or: [
            { name: { $regex: term, $options: 'i' } },
            { description: { $regex: term, $options: 'i' } },
            { sku: { $regex: term, $options: 'i' } }
          ]
        }));
        
        const query = {
          $and: searchConditions,
          isActive: true // Only search active products
        };
        
        const sortOptions = buildSortOptions(orderBy, columnMapping);
        
        console.log('Search query:', JSON.stringify(query, null, 2));
        
        // Get total count
        const totalCount = await Product.countDocuments(query);
        
        // Ensure offset doesn't exceed total count
        const safeOffset = Math.min(offset, Math.max(0, totalCount - 1));
        
        // Get paginated items with population
        const items = await Product.find(query)
          .populate('category')
          .populate('brand')
          .sort(sortOptions)
          .skip(safeOffset)
          .limit(first);
        
        return {
          items,
          totalCount
        };
      } catch (error) {
        console.error('Error in products.search:', error);
        throw error;
      }
    },
    
    // Simple method for backward compatibility
    getAllSimple: async () => {
      return await Product.find({ isActive: true })
        .populate('category')
        .populate('brand')
        .sort({ createdAt: -1 });
    },
    
    findById: async (id) => {
      return await Product.findById(id).populate('category').populate('brand');
    },
    
    create: async (input) => {
      const product = new Product(input);
      const savedProduct = await product.save();
      return await Product.findById(savedProduct._id).populate('category').populate('brand');
    },
    
    updateById: async (id, input) => {
      const updatedProduct = await Product.findByIdAndUpdate(id, input, { new: true });
      return await Product.findById(updatedProduct._id).populate('category').populate('brand');
    },
    
    deleteById: async (id) => {
      const result = await Product.findByIdAndDelete(id);
      return result ? id : null;
    },

    // Get featured products
    getFeatured: async () => {
      return await Product.find({ isFeatured: true, isActive: true })
        .populate('category')
        .populate('brand')
        .sort({ createdAt: -1 });
    },

    // Get products by category
    getByCategory: async (categoryId) => {
      return await Product.find({ category: categoryId, isActive: true })
        .populate('category')
        .populate('brand')
        .sort({ createdAt: -1 });
    },

    // Get products by brand
    getByBrand: async (brandId) => {
      return await Product.find({ brand: brandId, isActive: true })
        .populate('category')
        .populate('brand')
        .sort({ createdAt: -1 });
    },

    // Get products by brand and category
    getByBrandAndCategory: async (brandId, categoryId) => {
      return await Product.find({ 
        brand: brandId, 
        category: categoryId, 
        isActive: true 
      })
        .populate('category')
        .populate('brand')
        .sort({ createdAt: -1 });
    },

    // Add image to product
    addImage: async (productId, filename) => {
      const product = await Product.findById(productId);
      if (!product) throw new Error('Product not found');
      
      const currentImages = product.images || [];
      const updatedImages = [...currentImages, filename];
      
      return await Product.findByIdAndUpdate(
        productId, 
        { images: updatedImages }, 
        { new: true }
      ).populate('category').populate('brand');
    },

    // Remove image from product
    removeImage: async (productId, filename) => {
      const product = await Product.findById(productId);
      if (!product) throw new Error('Product not found');
      
      const currentImages = product.images || [];
      const updatedImages = currentImages.filter(img => img !== filename);
      
      return await Product.findByIdAndUpdate(
        productId, 
        { images: updatedImages }, 
        { new: true }
      ).populate('category').populate('brand');
    }
  },

  users: {
    findOne: async (username) => {
      return await User.findOne({ username }).lean();
    },
    
    findById: async (id) => {
      return await User.findById(id);
    },
    
    findByEmail: async (email) => {
      return await User.findOne({ email }).lean();
    },
    
    create: async (input) => {
      const user = new User(input);
      return await user.save();
    },

    // ===== CÁC METHOD ĐÃ CÓ TỪ TRƯỚC =====
    updateById: async (id, updateData) => {
      try {
        // Sử dụng findByIdAndUpdate của Mongoose để cập nhật và trả về tài liệu mới
        return await User.findByIdAndUpdate(id, updateData, { new: true }).lean(); [cite_start]// [cite: 35]
      } catch (error) {
        console.error('User updateById error:', error);
        throw error;
      }
    },

    updateOne: async (filter, update) => {
      try {
        const result = await User.updateOne(filter, update);
        return result;
      } catch (error) {
        console.error('User updateOne error:', error);
        throw error;
      }
    },

    findOneByQuery: async (query) => {
      try {
        return await User.findOne(query).lean();
      } catch (error) {
        console.error('User findOneByQuery error:', error);
        throw error;
      }
    },

    // ===== THÊM MỚI: OTP-specific methods =====
    
    // Lưu OTP vào database
    savePasswordResetOTP: async (email, otp, otpExpires) => {
      try {
        console.log('Saving OTP to DB:', { email, otp, otpExpires });
        const result = await User.updateOne(
          { email: email },
          {
            $set: {
              passwordResetOTP: otp,
              passwordResetOTPExpires: otpExpires,
              passwordResetEmail: email
            }
          }
        );
        console.log('Save OTP result:', result);
        return result;
      } catch (error) {
        console.error('Save OTP error:', error);
        throw error;
      }
    },

    // Tìm user theo OTP hợp lệ
    findByValidOTP: async (email, otp) => {
      try {
        console.log('Finding user by valid OTP:', { email, otp });
        const user = await User.findOne({
          passwordResetEmail: email,
          passwordResetOTP: otp,
          passwordResetOTPExpires: { $gt: new Date() } // OTP chưa hết hạn
        }).lean();
        console.log('Found user with valid OTP:', user ? 'Yes' : 'No');
        return user;
      } catch (error) {
        console.error('Find by valid OTP error:', error);
        throw error;
      }
    },

    // Reset password và clear OTP
    resetPasswordAndClearOTP: async (userId, hashedPassword) => {
      try {
        console.log('Resetting password and clearing OTP for user:', userId);
        const result = await User.updateOne(
          { _id: userId },
          {
            $set: {
              password: hashedPassword
            },
            $unset: {
              passwordResetOTP: "",
              passwordResetOTPExpires: "",
              passwordResetEmail: ""
            }
          }
        );
        console.log('Reset password result:', result);
        return result;
      } catch (error) {
        console.error('Reset password and clear OTP error:', error);
        throw error;
      }
    }
  },

  carts: {
    // Lấy tất cả items trong cart của user
    getByUserId: async (userId) => {
      try {
        const cartItems = await Cart.find({ userId })
          .populate('productId')
          .sort({ addedAt: -1 });
        
        return cartItems;
      } catch (error) {
        console.error('Error in carts.getByUserId:', error);
        throw error;
      }
    },

    // Tìm cart item của user cho 1 product cụ thể
    findByUserAndProduct: async (userId, productId) => {
      try {
        return await Cart.findOne({ userId, productId });
      } catch (error) {
        console.error('Error in carts.findByUserAndProduct:', error);
        throw error;
      }
    },

    // Tạo cart item mới
    create: async (cartData) => {
      try {
        const cartItem = new Cart(cartData);
        const savedItem = await cartItem.save();
        
        // Populate product info trước khi return
        return await Cart.findById(savedItem._id).populate('productId');
      } catch (error) {
        console.error('Error in carts.create:', error);
        if (error.code === 11000) {
          throw new Error('Item already exists in cart');
        }
        throw error;
      }
    },

    // Cập nhật quantity của cart item
    updateQuantity: async (userId, productId, quantity) => {
      try {
        const updatedItem = await Cart.findOneAndUpdate(
          { userId, productId },
          { quantity },
          { new: true }
        ).populate('productId');

        if (!updatedItem) {
          throw new Error('Cart item not found');
        }

        return updatedItem;
      } catch (error) {
        console.error('Error in carts.updateQuantity:', error);
        throw error;
      }
    },

    // Xóa 1 item khỏi cart
    removeItem: async (userId, productId) => {
      try {
        const result = await Cart.findOneAndDelete({ userId, productId });
        return result !== null;
      } catch (error) {
        console.error('Error in carts.removeItem:', error);
        throw error;
      }
    },

    // Xóa toàn bộ cart của user
    clearByUserId: async (userId) => {
      try {
        const result = await Cart.deleteMany({ userId });
        return result.deletedCount > 0;
      } catch (error) {
        console.error('Error in carts.clearByUserId:', error);
        throw error;
      }
    },

    // Lấy tổng số items trong cart (để hiển thị badge)
    getItemCount: async (userId) => {
      try {
        const cartItems = await Cart.find({ userId });
        return cartItems.reduce((sum, item) => sum + item.quantity, 0);
      } catch (error) {
        console.error('Error in carts.getItemCount:', error);
        throw error;
      }
    },

    // Kiểm tra và validate cart trước khi checkout
    validateCart: async (userId) => {
      try {
        const cartItems = await Cart.find({ userId }).populate('productId');
        
        const validationErrors = [];
        const validItems = [];

        for (const item of cartItems) {
          if (!item.productId) {
            validationErrors.push(`Product ${item.productName} no longer exists`);
            continue;
          }

          if (!item.productId.isActive) {
            validationErrors.push(`Product ${item.productName} is no longer available`);
            continue;
          }

          if (item.productId.stock < item.quantity) {
            validationErrors.push(`${item.productName}: Only ${item.productId.stock} items available (you have ${item.quantity} in cart)`);
            continue;
          }

          // Kiểm tra giá có thay đổi không
          if (item.unitPrice !== item.productId.price) {
            validationErrors.push(`${item.productName}: Price changed from ${item.unitPrice} to ${item.productId.price}`);
          }

          validItems.push(item);
        }

        return {
          isValid: validationErrors.length === 0,
          errors: validationErrors,
          validItems
        };
      } catch (error) {
        console.error('Error in carts.validateCart:', error);
        throw error;
      }
    }
  },
  orders: {
    // Create order from cart
    createFromCart: async (userId, orderInput) => {
      const session = await mongoose.startSession();
      
      try {
        session.startTransaction();
        
        // 1. Get and validate cart
        const cartItems = await Cart.find({ userId }).populate('productId');
        
        if (!cartItems || cartItems.length === 0) {
          throw new Error('Cart is empty');
        }
        
        // 2. Calculate order totals
        let subtotal = 0;
        const orderItemsData = [];
        
        for (const cartItem of cartItems) {
          const product = cartItem.productId;
          
          if (!product) {
            throw new Error(`Product not found for cart item ${cartItem._id}`);
          }
          
          if (product.stock < cartItem.quantity) {
            throw new Error(`Insufficient stock for ${product.name}. Available: ${product.stock}, Requested: ${cartItem.quantity}`);
          }
          
          const itemTotal = cartItem.unitPrice * cartItem.quantity;
          subtotal += itemTotal;
          
          // Prepare order item data
          orderItemsData.push({
            productId: product._id,
            productName: product.name,
            productSku: product.sku,
            quantity: cartItem.quantity,
            unitPrice: cartItem.unitPrice,
            totalPrice: itemTotal,
            productSnapshot: {
              description: product.description,
              images: product.images,
              brand: product.brand?.name || 'Unknown',
              category: product.category?.name || 'Unknown'
            }
          });
        }
        
        // 3. Generate order number
        const orderCount = await Order.countDocuments() + 1;
        const orderNumber = `DH${new Date().getFullYear()}${String(Date.now()).slice(-8)}${String(orderCount).padStart(3, '0')}`;
        
        // 4. Create order
        const orderData = {
          orderNumber,
          userId,
          customerInfo: orderInput.customerInfo,
          paymentMethod: orderInput.paymentMethod,
          paymentStatus: 'pending',
          status: 'pending',
          subtotal,
          totalAmount: subtotal, // Could add tax, shipping later
          customerNotes: orderInput.customerNotes,
          orderDate: new Date()
        };
        
        const order = await Order.create([orderData], { session });
        const orderId = order[0]._id;
        
        // 5. Create order items
        const orderItemsWithOrderId = orderItemsData.map(item => ({
          ...item,
          orderId
        }));
        
        await OrderItem.create(orderItemsWithOrderId, { session, ordered: true });
        
        // 6. Update product stock and clear cart
        for (const cartItem of cartItems) {
          await Product.findByIdAndUpdate(
            cartItem.productId._id,
            { $inc: { stock: -cartItem.quantity } },
            { session }
          );
        }
        
        // Clear cart
        await Cart.deleteMany({ userId }, { session });
        
        await session.commitTransaction();
        
        // 7. Return populated order
        return await db.orders.getByOrderNumber(orderNumber);
        
      } catch (error) {
        await session.abortTransaction();
        console.error('Error creating order from cart:', error);
        throw error;
      } finally {
        session.endSession();
      }
    },

    // Get order by order number
    getByOrderNumber: async (orderNumber) => {
      try {
        console.log('🔍 mongoRepo: Getting order by number:', orderNumber);
        const order = await Order.findOne({ orderNumber })
          .populate('userId', 'username email firstName lastName');
        
        console.log('📦 mongoRepo: Order found:', order ? 'Yes' : 'No');
        return order;
      } catch (error) {
        console.error('❌ mongoRepo: Error in getByOrderNumber:', error);
        throw error;
      }
    },

    // Get orders by user ID
    getByUserId: async (userId, { first = 10, offset = 0, orderBy = 'DATE_DESC' } = {}) => {
      try {
        const columnMapping = {
          DATE: 'orderDate',
          STATUS: 'status',
          TOTAL: 'totalAmount'
        };
        
        const query = { userId };
        const sortOptions = buildSortOptions(orderBy, columnMapping);
        
        const totalCount = await Order.countDocuments(query);
        const safeOffset = Math.min(offset, Math.max(0, totalCount - 1));
        
        const items = await Order.find(query)
          .sort(sortOptions)
          .skip(safeOffset)
          .limit(first);
        
        return { items, totalCount };
      } catch (error) {
        console.error('Error in orders.getByUserId:', error);
        throw error;
      }
    },

    // Get all orders (admin)
    getAll: async ({ first = 10, offset = 0, orderBy = 'DATE_DESC', condition, search } = {}) => {
      try {
        const columnMapping = {
          DATE: 'orderDate',
          STATUS: 'status',
          TOTAL: 'totalAmount'
        };
        
        const query = {};
        
        if (condition) {
          if (condition.status) query.status = condition.status;
          if (condition.paymentStatus) query.paymentStatus = condition.paymentStatus;
          if (condition.paymentMethod) query.paymentMethod = condition.paymentMethod;
          if (condition.userId) query.userId = condition.userId;
          
          if (condition.dateFrom || condition.dateTo) {
            query.orderDate = {};
            if (condition.dateFrom) query.orderDate.$gte = new Date(condition.dateFrom);
            if (condition.dateTo) query.orderDate.$lte = new Date(condition.dateTo);
          }
        }
        
        if (search && search.trim()) {
          const searchRegex = { $regex: search.trim(), $options: 'i' };
          query.$or = [
            { orderNumber: searchRegex },
            { 'customerInfo.fullName': searchRegex },
            { 'customerInfo.phone': searchRegex },
            { 'customerInfo.address': searchRegex }
          ];
        }
        
        const sortOptions = buildSortOptions(orderBy, columnMapping);
        
        const totalCount = await Order.countDocuments(query);
        const safeOffset = Math.min(offset, Math.max(0, totalCount - 1));
        
        const items = await Order.find(query)
          .populate('userId', 'username email firstName lastName')
          .sort(sortOptions)
          .skip(safeOffset)
          .limit(first);
        
        return { items, totalCount };
      } catch (error) {
        console.error('Error in orders.getAll:', error);
        throw error;
      }
    },

    // Update order status
    updateStatus: async (orderNumber, status, adminNotes) => {
      try {
        const updateData = { 
          status,
          ...(adminNotes && { adminNotes })
        };
        
        const now = new Date();
        switch (status) {
          case 'confirmed':
            updateData.confirmedAt = now;
            break;
          case 'processing':
            updateData.processedAt = now;
            break;
          case 'shipping':
            updateData.shippedAt = now;
            break;
          case 'delivered':
            updateData.deliveredAt = now;
            updateData.paymentStatus = 'paid';
            break;
          case 'cancelled':
            updateData.cancelledAt = now;
            await db.orders.restoreStockForOrder(orderNumber);
            break;
        }
        
        return await Order.findOneAndUpdate(
          { orderNumber },
          updateData,
          { new: true }
        ).populate('userId', 'username email firstName lastName');
      } catch (error) {
        console.error('Error in orders.updateStatus:', error);
        throw error;
      }
    },

    // Update payment status
    updatePaymentStatus: async (orderNumber, paymentStatus) => {
      try {
        return await Order.findOneAndUpdate(
          { orderNumber },
          { paymentStatus },
          { new: true }
        ).populate('userId', 'username email firstName lastName');
      } catch (error) {
        console.error('Error in orders.updatePaymentStatus:', error);
        throw error;
      }
    },

    // Cancel order
    cancel: async (orderNumber, reason) => {
      try {
        const updateData = {
          status: 'cancelled',
          cancelledAt: new Date(),
          ...(reason && { adminNotes: reason })
        };
        
        await db.orders.restoreStockForOrder(orderNumber);
        
        return await Order.findOneAndUpdate(
          { orderNumber },
          updateData,
          { new: true }
        ).populate('userId', 'username email firstName lastName');
      } catch (error) {
        console.error('Error in orders.cancel:', error);
        throw error;
      }
    },

    // Restore stock for cancelled order
    restoreStockForOrder: async (orderNumber) => {
      try {
        const order = await Order.findOne({ orderNumber });
        if (!order) throw new Error('Order not found');
        
        const orderItems = await OrderItem.find({ orderId: order._id });
        
        for (const item of orderItems) {
          await Product.findByIdAndUpdate(
            item.productId,
            { $inc: { stock: item.quantity } }
          );
        }
        
        console.log(`Stock restored for order ${orderNumber}`);
      } catch (error) {
        console.error('Error restoring stock:', error);
        throw error;
      }
    },

    // Get order statistics
    getStats: async () => {
      try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        const [
          totalOrders,
          pendingOrders,
          confirmedOrders,
          shippingOrders,
          deliveredOrders,
          cancelledOrders,
          todayOrders,
          revenueResult
        ] = await Promise.all([
          Order.countDocuments(),
          Order.countDocuments({ status: 'pending' }),
          Order.countDocuments({ status: 'confirmed' }),
          Order.countDocuments({ status: 'shipping' }),
          Order.countDocuments({ status: 'delivered' }),
          Order.countDocuments({ status: 'cancelled' }),
          Order.countDocuments({ orderDate: { $gte: today } }),
          Order.aggregate([
            { $match: { status: 'delivered' } },
            { $group: { _id: null, total: { $sum: '$totalAmount' } } }
          ])
        ]);
        
        const totalRevenue = revenueResult[0]?.total || 0;
        
        return {
          totalOrders,
          pendingOrders,
          confirmedOrders,
          shippingOrders,
          deliveredOrders,
          cancelledOrders,
          totalRevenue,
          todayOrders
        };
      } catch (error) {
        console.error('Error in orders.getStats:', error);
        throw error;
      }
    }
  },

  // ✅ FIX: OrderItems section - ĐÚNG STRUCTURE
  orderItems: {
    // Get order items by order ID - ĐÂY LÀ FUNCTION BỊ THIẾU
    getByOrderId: async (orderId) => {
      try {
        console.log('🔍 mongoRepo: Getting order items for orderId:', orderId);
        
        if (!orderId) {
          console.log('❌ mongoRepo: orderId is null/undefined');
          return [];
        }
        
        if (!mongoose.Types.ObjectId.isValid(orderId)) {
          console.log('❌ mongoRepo: Invalid orderId format:', orderId);
          return [];
        }
        
        const items = await OrderItem.find({ orderId })
          .sort({ createdAt: 1 });
        
        console.log(`📦 mongoRepo: Found ${items?.length || 0} order items`);
        return items || [];
      } catch (error) {
        console.error('❌ mongoRepo: Error in orderItems.getByOrderId:', error);
        return []; // Return empty array instead of throwing
      }
    },

    // Get order items by product ID (for analytics)
    getByProductId: async (productId) => {
      try {
        return await OrderItem.find({ productId })
          .populate('orderId')
          .sort({ createdAt: -1 });
      } catch (error) {
        console.error('Error in orderItems.getByProductId:', error);
        throw error;
      }
    },

    // Create order items (used during order creation)
    createMany: async (orderItemsData, session = null) => {
      try {
        const options = session ? { session } : {};
        return await OrderItem.create(orderItemsData, options);
      } catch (error) {
        console.error('Error creating order items:', error);
        throw error;
      }
    },

    // Get order items summary for reporting
    getSummary: async (orderId) => {
      try {
        const items = await OrderItem.find({ orderId });
        
        const summary = {
          totalItems: items.length,
          totalQuantity: items.reduce((sum, item) => sum + item.quantity, 0),
          totalValue: items.reduce((sum, item) => sum + item.totalPrice, 0)
        };
        
        return summary;
      } catch (error) {
        console.error('Error getting order items summary:', error);
        throw error;
      }
    }
  },

  wishlists: {
    findByUserId: async (userId) => {
      return await Wishlist.find({ userId }).sort({ createdAt: -1 }).populate('productId');
    },

    findOne: async (userId, productId) => {
      return await Wishlist.findOne({ userId, productId });
    },

    create: async (userId, productId) => {
      // Dùng findOneAndUpdate với `upsert: true` để tránh lỗi trùng lặp
      // Nếu đã tồn tại, nó sẽ không làm gì. Nếu chưa, nó sẽ tạo mới.
      const wishlistItem = await Wishlist.findOneAndUpdate(
        { userId, productId },
        { $setOnInsert: { userId, productId } },
        { new: true, upsert: true, runValidators: true }
      );
      return await wishlistItem.populate('productId');
    },

    remove: async (userId, productId) => {
      try {
        // Log để kiểm tra
        console.log(`Attempting to remove wishlist item for userId: ${userId}, productId: ${productId}`);
        
        // Dùng `deleteOne` để xóa tài liệu khớp điều kiện
        const result = await Wishlist.deleteOne({ userId, productId });
        
        // Log kết quả
        console.log('Deletion result:', result);
        
        // `deletedCount` sẽ là 1 nếu xóa thành công, 0 nếu không tìm thấy
        return result.deletedCount > 0;
      } catch (error) {
        console.error('Error removing from wishlist:', error);
        return false; // Trả về false nếu có lỗi
      }
    },

  },
};

export { db };