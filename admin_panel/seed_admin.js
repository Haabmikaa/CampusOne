const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
let serviceAccount;
const localPath = path.join(__dirname, 'service-account.json');
const parentPath = path.join(__dirname, '..', 'service-account.json');

if (fs.existsSync(localPath)) {
  serviceAccount = require(localPath);
} else if (fs.existsSync(parentPath)) {
  serviceAccount = require(parentPath);
} else {
  console.error('❌ Error: service-account.json not found!');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedDatabase() {
  try {
    console.log('🚀 Starting Admin Database Seeding...');
    
    // Read the updated products.json
    const productsPath = path.join(__dirname, '../assets/data/products.json');
    const productsData = JSON.parse(fs.readFileSync(productsPath, 'utf8'));
    
    console.log(`📦 Found ${productsData.length} products to seed.`);

    // Write products to Firestore
    const batch = db.batch();
    let count = 0;
    
    for (const product of productsData) {
      const docRef = db.collection('products').doc(product.id);
      
      // Ensure prices are numbers
      const price = typeof product.price === 'string' ? parseFloat(product.price) : product.price;
      const originalPrice = product.originalPrice ? 
        (typeof product.originalPrice === 'string' ? parseFloat(product.originalPrice) : product.originalPrice) : null;
      
      batch.set(docRef, {
        ...product,
        price,
        originalPrice,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true }); // Use merge to update existing documents without destroying subcollections like reviews
      
      count++;
      
      // Commit in batches of 400 (Firestore limit is 500)
      if (count % 400 === 0) {
        await batch.commit();
        console.log(`✅ Committed ${count} products...`);
      }
    }
    
    // Commit any remaining
    if (count % 400 !== 0) {
      await batch.commit();
    }
    
    console.log(`\n🧹 Cleaning up old discarded products (e.g. groceries)...`);
    const cleanupBatch = db.batch();
    for (let i = 168; i <= 200; i++) {
        cleanupBatch.delete(db.collection('products').doc(`p${i}`));
    }
    await cleanupBatch.commit();
    
    console.log(`\n📂 Seeding new Categories...`);
    const catBatch = db.batch();
    catBatch.set(db.collection('categories').doc('cat9'), {
        id: 'cat9',
        name: 'Vehicles',
        description: 'Cars, motorcycles, and accessories',
        imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=800&q=80',
        isActive: true,
        order: 9,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
    
    catBatch.set(db.collection('categories').doc('cat10'), {
        id: 'cat10',
        name: 'Furniture',
        description: 'Premium home furniture and decor',
        imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=800&q=80',
        isActive: true,
        order: 10,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
    await catBatch.commit();

    console.log(`🎉 Successfully seeded all ${productsData.length} products to Firestore!`);
    
    // Verify a product
    const sampleDoc = await db.collection('products').doc(productsData[0].id).get();
    console.log(`\n🔍 Verification:`);
    console.log(`Product Name: ${sampleDoc.data().name}`);
    console.log(`Image URL: ${sampleDoc.data().images[0]}`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase();
