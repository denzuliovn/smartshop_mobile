// File: server/test-orderitems.js - Quick test script để check database functions

import { connectDB } from "./data/init.js";
import { db } from "./data/mongoRepo.js";

const testOrderItems = async () => {
  try {
    console.log('🔍 Testing OrderItems functionality...\n');
    
    // Connect to database
    await connectDB();
    console.log('✅ Database connected\n');
    
    // Check db object structure
    console.log('🔍 DB Object Structure:');
    console.log('Available keys:', Object.keys(db));
    console.log('');
    
    // Check orders object
    if (db.orders) {
      console.log('✅ db.orders exists');
      console.log('Orders methods:', Object.keys(db.orders));
    } else {
      console.error('❌ db.orders missing!');
    }
    console.log('');
    
    // Check orderItems object
    if (db.orderItems) {
      console.log('✅ db.orderItems exists');
      console.log('OrderItems methods:', Object.keys(db.orderItems));
      
      // Test getByOrderId method
      if (db.orderItems.getByOrderId) {
        console.log('✅ db.orderItems.getByOrderId exists');
        
        // Try to call it with a test ObjectId
        try {
          const testOrderId = '676f1234567890abcdef1234'; // dummy ObjectId
          console.log(`🔍 Testing getByOrderId with dummy ID: ${testOrderId}`);
          const result = await db.orderItems.getByOrderId(testOrderId);
          console.log(`✅ getByOrderId returned: ${result.length} items (expected 0 for dummy ID)`);
        } catch (error) {
          console.error('❌ Error testing getByOrderId:', error.message);
        }
      } else {
        console.error('❌ db.orderItems.getByOrderId missing!');
      }
    } else {
      console.error('❌ db.orderItems missing!');
    }
    console.log('');
    
    // Test with real order if exists
    console.log('🔍 Looking for real orders in database...');
    try {
      // Find first order to test with
      const { Order } = await import("./data/models/index.js");
      const firstOrder = await Order.findOne().limit(1);
      
      if (firstOrder) {
        console.log(`✅ Found real order: ${firstOrder.orderNumber} (ID: ${firstOrder._id})`);
        
        // Test getByOrderId with real order
        const realItems = await db.orderItems.getByOrderId(firstOrder._id);
        console.log(`✅ Real order has ${realItems.length} items`);
        
        if (realItems.length > 0) {
          console.log('📦 Sample order item:');
          console.log('  - Product Name:', realItems[0].productName);
          console.log('  - Quantity:', realItems[0].quantity);
          console.log('  - Unit Price:', realItems[0].unitPrice);
        }
      } else {
        console.log('ℹ️ No orders found in database');
      }
    } catch (error) {
      console.error('❌ Error testing with real order:', error.message);
    }
    
    console.log('\n🎉 Test completed!');
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Test failed:', error);
    process.exit(1);
  }
};

// Run test
testOrderItems();