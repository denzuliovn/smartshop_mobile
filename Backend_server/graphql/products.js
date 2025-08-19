import csv from 'csv-parser';
import { Readable } from 'stream';

export const typeDef = `
  input BulkUpdateInput {
    ids: [ID!]!
    price: Float
    stock: Int
  }

  type ImportResult {
    success: Boolean!
    message: String!
    created: Int!
    updated: Int!
    errors: [String!]
  }

  type Product {
    _id: ID!
    name: String!
    description: String
    price: Float!
    originalPrice: Float
    sku: String!
    category: Category!
    brand: Brand!
    images: [String]
    stock: Int!
    isActive: Boolean
    isFeatured: Boolean
    createdAt: String
    updatedAt: String
  }

  enum ProductsOrderBy {
    ID_ASC
    ID_DESC
    NAME_ASC
    NAME_DESC
    PRICE_ASC
    PRICE_DESC
    STOCK_ASC
    STOCK_DESC
    CREATED_ASC
    CREATED_DESC
  }

  type ProductConnection {
    nodes: [Product]
    totalCount: Int
    hasNextPage: Boolean
    hasPreviousPage: Boolean
  }

  input RangeConditionInput {
    min: Float
    max: Float
  }

  input ProductConditionInput {
    name: String
    brand: ID
    category: ID
    price: RangeConditionInput
    stock: RangeConditionInput
    isActive: Boolean
    isFeatured: Boolean
  }

  extend type Query {
    products(
      first: Int = 10,
      offset: Int = 0,
      orderBy: ProductsOrderBy = CREATED_DESC,
      condition: ProductConditionInput
    ): ProductConnection
    
    product(id: ID!): Product
    
    
    # Backward compatibility - simple lists
    allProducts: [Product]
    featuredProducts: [Product]
    productsByCategory(categoryId: ID!): [Product]
    productsByBrand(brandId: ID!): [Product]
    productsByBrandAndCategory(brandId: ID!, categoryId: ID!): [Product]
    
    # Search products
    searchProducts(
      query: String!,
      first: Int = 10,
      offset: Int = 0,
      orderBy: ProductsOrderBy = CREATED_DESC
    ): ProductConnection
  }
  
  extend type Mutation {
    createProduct(input: ProductInput!): Product
    updateProduct(id: ID!, input: ProductInput!): Product
    deleteProduct(id: ID!): ID
    deleteManyProducts(ids: [ID!]!): Boolean!
    importProducts(file: File!): ImportResult!
    bulkUpdateProducts(input: BulkUpdateInput!): Boolean!
  }
  
  input ProductInput {
    name: String!
    description: String
    price: Float!
    originalPrice: Float
    sku: String!
    category: ID!
    brand: ID!
    images: [String]
    stock: Int!
    isActive: Boolean = true
    isFeatured: Boolean = false
  }
`;

export const resolvers = {
  Query: {
    products: async (parent, args, context, info) => {
      console.log('Products query args:', args);
      const result = await context.db.products.getAll(args);
      
      const { first = 10, offset = 0 } = args;
      const hasNextPage = offset + first < result.totalCount;
      const hasPreviousPage = offset > 0;
      
      return {
        nodes: result.items,
        totalCount: result.totalCount,
        hasNextPage,
        hasPreviousPage
      };
    },
    
    product: async (parent, args, context, info) => {
      return await context.db.products.findById(args.id);
    },
    
    searchProducts: async (parent, args, context, info) => {
      console.log('Search products args:', args);
      const result = await context.db.products.search(args);
      
      const { first = 10, offset = 0 } = args;
      const hasNextPage = offset + first < result.totalCount;
      const hasPreviousPage = offset > 0;
      
      return {
        nodes: result.items,
        totalCount: result.totalCount,
        hasNextPage,
        hasPreviousPage
      };
    },
    
    // Simple lists for backward compatibility
    allProducts: async (parent, args, context, info) => {
      return await context.db.products.getAllSimple();
    },
    
    featuredProducts: async (parent, args, context, info) => {
      return await context.db.products.getFeatured();
    },
    
    productsByCategory: async (parent, args, context, info) => {
      return await context.db.products.getByCategory(args.categoryId);
    },
    productsByBrand: async (parent, args, context, info) => {
      return await context.db.products.getByBrand(args.brandId);
    },
    productsByBrandAndCategory: async (parent, args, context, info) => {
      return await context.db.products.getByBrandAndCategory(args.brandId, args.categoryId);
    },
    productsByBrandAndCategory: async (parent, args, context, info) => {
      return await context.db.products.getByBrandAndCategory(args.brandId, args.categoryId);
    }
  },
  
  Mutation: {
    bulkUpdateProducts: async (parent, { input }, context) => {
      const { ids, price, stock } = input;
      if (!ids || ids.length === 0) return false;

      const updateData = {};
      if (price !== null && price !== undefined) {
        updateData.price = price;
      }
      if (stock !== null && stock !== undefined) {
        updateData.stock = stock;
      }

      if (Object.keys(updateData).length === 0) {
        throw new Error("No fields to update.");
      }

      try {
        await Product.updateMany(
          { _id: { $in: ids } },
          { $set: updateData }
        );
        return true;
      } catch (error) {
        console.error('Bulk update error:', error);
        return false;
      }
    },

    importProducts: async (parent, { file }, context) => {
      console.log(`Bắt đầu import sản phẩm từ file: ${file.name}`);
      const results = [];
      const errors = [];
      let created = 0;
      let updated = 0;

      try {
        const fileBuffer = Buffer.from(await file.arrayBuffer());
        const stream = Readable.from(fileBuffer.toString());

        await new Promise((resolve, reject) => {
          stream
            .pipe(csv())
            .on('data', (data) => results.push(data))
            .on('end', resolve)
            .on('error', reject);
        });

        console.log(`Đã đọc được ${results.length} dòng từ file CSV.`);

        for (const row of results) {
          try {
            // Giả sử file CSV có các cột: SKU, Name, Price, Stock, CategoryID, BrandID
            if (!row.SKU || !row.Name) {
              errors.push(`Dòng ${results.indexOf(row) + 2}: Thiếu SKU hoặc Name.`);
              continue;
            }

            const productData = {
              name: row.Name,
              price: parseFloat(row.Price) || 0,
              stock: parseInt(row.Stock) || 0,
              description: row.Description || '',
              category: row.CategoryID,
              brand: row.BrandID,
              // Thêm các trường khác nếu có
            };

            // Dùng SKU để tìm và cập nhật, hoặc tạo mới nếu chưa có
            const existingProduct = await Product.findOne({ sku: row.SKU });
            if (existingProduct) {
              await Product.updateOne({ _id: existingProduct._id }, { $set: productData });
              updated++;
            } else {
              await Product.create({ sku: row.SKU, ...productData });
              created++;
            }
          } catch (rowError) {
            errors.push(`Dòng ${results.indexOf(row) + 2}: ${rowError.message}`);
          }
        }

        return {
          success: true,
          message: `Import hoàn tất.`,
          created,
          updated,
          errors,
        };

      } catch (e) {
        console.error("Lỗi khi import file:", e);
        throw new GraphQLError(`Không thể xử lý file: ${e.message}`);
      }
    },

    deleteManyProducts: async (parent, { ids }, context, info) => {
      if (!ids || ids.length === 0) {
        throw new Error("IDs array cannot be empty.");
      }
      try {
        // Cần import Product từ /data/models
        await context.db.products.deleteManyByIds(ids); // Giả sử có hàm này trong repo
        return true;
      } catch (error) {
        console.error('Error deleting many products:', error);
        return false;
      }
    },
    createProduct: async (parent, args, context, info) => {
      try {
        console.log('Creating product with input:', args.input);
        
        // Validate required fields
        const { name, price, sku, category, stock } = args.input;
        
        if (!name || !price || !sku || !category || stock === undefined) {
          throw new Error('Missing required fields: name, price, sku, category, stock');
        }

        // Check if category exists
        const categoryExists = await context.db.categories.findById(category);
        if (!categoryExists) {
          throw new Error('Category not found');
        }

        // Check if SKU is unique
        const existingProduct = await context.db.products.getAllSimple();
        const skuExists = existingProduct.find(p => p.sku === sku);
        if (skuExists) {
          throw new Error('SKU already exists');
        }

        const product = await context.db.products.create(args.input);
        console.log('Product created successfully:', product._id);
        
        return product;
      } catch (error) {
        console.error('Error creating product:', error);
        throw error;
      }
    },
    
    updateProduct: async (parent, args, context, info) => {
      try {
        console.log('Updating product:', args.id, 'with input:', args.input);
        
        // Check if product exists
        const existingProduct = await context.db.products.findById(args.id);
        if (!existingProduct) {
          throw new Error('Product not found');
        }

        // If category is being updated, check if it exists
        if (args.input.category) {
          const categoryExists = await context.db.categories.findById(args.input.category);
          if (!categoryExists) {
            throw new Error('Category not found');
          }
        }

        // If SKU is being updated, check uniqueness
        if (args.input.sku && args.input.sku !== existingProduct.sku) {
          const allProducts = await context.db.products.getAllSimple();
          const skuExists = allProducts.find(p => p.sku === args.input.sku && p._id.toString() !== args.id);
          if (skuExists) {
            throw new Error('SKU already exists');
          }
        }

        const product = await context.db.products.updateById(args.id, args.input);
        console.log('Product updated successfully:', product._id);
        
        return product;
      } catch (error) {
        console.error('Error updating product:', error);
        throw error;
      }
    },
    
    deleteProduct: async (parent, args, context, info) => {
      try {
        console.log('Deleting product:', args.id);
        
        // Check if product exists and get its images
        const existingProduct = await context.db.products.findById(args.id);
        if (!existingProduct) {
          throw new Error('Product not found');
        }

        // Delete product images from filesystem (optional)
        if (existingProduct.images && existingProduct.images.length > 0) {
          const fs = await import('fs');
          const path = await import('path');
          const { fileURLToPath } = await import('url');
          const { dirname } = await import('path');
          
          const __filename = fileURLToPath(import.meta.url);
          const __dirname = dirname(__filename);
          
          for (const imageName of existingProduct.images) {
            try {
              const imagePath = path.join(__dirname, '../img/', imageName);
              if (fs.existsSync(imagePath)) {
                fs.unlinkSync(imagePath);
                console.log('Deleted image file:', imageName);
              }
            } catch (imageError) {
              console.warn('Could not delete image file:', imageName, imageError.message);
            }
          }
        }

        const deletedId = await context.db.products.deleteById(args.id);
        console.log('Product deleted successfully:', deletedId);
        
        return deletedId;
      } catch (error) {
        console.error('Error deleting product:', error);
        throw error;
      }
    },
  },
};