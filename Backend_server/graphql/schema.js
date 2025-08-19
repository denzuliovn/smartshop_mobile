import { createSchema } from "graphql-yoga";
import _ from "lodash";
import { typeDef as hello, resolvers as helloResolvers } from "./hello.js";
import { typeDef as categories, resolvers as categoriesResolvers } from "./categories.js";
import { typeDef as products, resolvers as productsResolvers } from "./products.js";
import { typeDef as brands, resolvers as brandsResolvers } from "./brands.js";
import { typeDef as authentication, resolvers as authenticationResolvers } from "./authentication.js";
import { typeDef as upload, resolvers as uploadResolvers } from "./upload.js";
import { typeDef as carts, resolvers as cartsResolvers } from "./carts.js";
import { typeDef as orders, resolvers as ordersResolvers } from "./orders.js";
import { typeDef as wishlist, resolvers as wishlistResolvers } from "./wishlist.js"; // Thêm dòng này

const query = `
  type Query {
    _empty: String
  }
  
  type Mutation {
    _emptyAction: String
  }
`;

const typeDefs = [query, hello,  categories, products, brands, authentication, upload, carts, orders, wishlist];
const resolvers = _.merge(
  helloResolvers, 
  categoriesResolvers,
  productsResolvers,
  brandsResolvers,
  authenticationResolvers,
  uploadResolvers,
  cartsResolvers,
  ordersResolvers,
  wishlistResolvers // Thêm wishlistResolvers vào merge
 
);

export const schema = createSchema({
  typeDefs: typeDefs,
  resolvers: resolvers,
});