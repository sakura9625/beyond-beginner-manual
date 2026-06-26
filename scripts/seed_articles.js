const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const articles = require('./articles_seed.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seed() {
  console.log(`投入開始: ${articles.length}件`);

  // 既存のarticlesコレクションを全削除
  const existing = await db.collection('articles').get();
  const deleteBatch = db.batch();
  existing.docs.forEach(doc => deleteBatch.delete(doc.ref));
  await deleteBatch.commit();
  console.log(`既存データ削除: ${existing.size}件`);

  // 50件ずつバッチ投入
  const chunkSize = 50;
  let total = 0;
  for (let i = 0; i < articles.length; i += chunkSize) {
    const chunk = articles.slice(i, i + chunkSize);
    const batch = db.batch();
    chunk.forEach(article => {
      const ref = db.collection('articles').doc(String(article.contentId));
      batch.set(ref, {
        ...article,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    await batch.commit();
    total += chunk.length;
    console.log(`投入済み: ${total}/${articles.length}件`);
  }

  console.log('完了！');
  process.exit(0);
}

seed().catch(err => {
  console.error(err);
  process.exit(1);
});
