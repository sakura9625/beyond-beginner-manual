const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const articles = [
  {
    chapter: '0',
    chapterName: 'はじめに',
    no: '0-1',
    title: 'なぜ私はスキルアップを決意したのか',
    myStory: '石垣島でノリでモルディブツアーを申し込んだ。今のスキルでは死ぬかもしれないと思った。',
    whyItHappened: 'OW取得後10年・30本のエンジョイダイバー。毎回リセットされて初心者のまま。',
    improvement: '目標があると練習の動機になる。まず動き出すことで気持ちが前向きになる。',
    todaysQuest: [],
    reviewChecks: [],
    difficulty: 1,
    recommendedDives: '0〜',
    isPro: false,
  },
  {
    chapter: '1',
    chapterName: '心構え',
    no: '1-1',
    title: 'とりあえず動いてみる',
    myStory: '不安で頭の中だけで考え続けていた。どこから手をつければいいか分からなかった。',
    whyItHappened: '考えるだけでは気持ちが沈む一方。小さな行動が前向きな気持ちを生む。',
    improvement: 'まず1つだけ動いてみる。器材ショップに行く、プール予約をする、など小さくていい。',
    todaysQuest: ['次のダイブの予約を今日入れた'],
    reviewChecks: ['予約を入れられた'],
    difficulty: 1,
    recommendedDives: '0〜',
    isPro: false,
  },
  {
    chapter: '1',
    chapterName: '心構え',
    no: '1-2',
    title: '趣味は頻度がすべて',
    myStory: '10年で30本。毎回感覚がリセットされて毎回初心者だった。',
    whyItHappened: 'スキルは積み上がらない。間隔が空くと体得した感覚を失う。',
    improvement: '月1本より週1本。短期間に回数を重ねる方が上達が速い。',
    todaysQuest: ['直近1ヶ月以内に潜る予定を入れた'],
    reviewChecks: ['前回から1ヶ月以内に潜れた'],
    difficulty: 2,
    recommendedDives: '0〜',
    isPro: false,
  },
  {
    chapter: '2',
    chapterName: '耳抜き・潜行',
    no: '2-1',
    title: '痛くなってから耳抜きする私',
    myStory: '耳が痛くなったのをサインに耳抜きしていた。痛みが出てからでは手遅れだった。',
    whyItHappened: '痛みはすでに鼓膜が圧迫されているサイン。そこから戻すのは難しく焦りも加わる。',
    improvement: '1〜2m潜るごとに、痛みがなくても先手で耳抜きする。水面でも1回やっておく。',
    todaysQuest: ['水面で1回耳抜きしてみた', '耳が痛くなる前に耳抜きした'],
    reviewChecks: ['痛みなく潜れた', '先手で耳抜きできた'],
    difficulty: 2,
    recommendedDives: '0〜30',
    isPro: false,
  },
  {
    chapter: '2',
    chapterName: '耳抜き・潜行',
    no: '2-2',
    title: '歯を食いしばって潜る私',
    myStory: '耳抜きが苦手で、毎回緊張していた。気づいたらマウスピースを強く噛みしめていた。',
    whyItHappened: '苦手意識から全身に力が入る。顎を締めると耳管も締まり、耳抜きがさらに難しくなる。',
    improvement: '顎を意識的に緩める。マウスピースは軽く咥えるだけでいい。',
    todaysQuest: ['顎の力を抜いて潜行した'],
    reviewChecks: ['マウスピースを噛みすぎなかった', '顎が緩んでいた'],
    difficulty: 2,
    recommendedDives: '0〜30',
    isPro: false,
  },
  {
    chapter: '3',
    chapterName: 'エア消費',
    no: '3-1',
    title: '周りより先に上がる私',
    myStory: '毎回自分のエアが基準になって先に上がることになった。マンタを見ている最中に。',
    whyItHappened: '無駄な動き・緊張・力みがエアを消費する。気がかりが多いと呼吸が荒くなる。',
    improvement: 'エアを減らす行動を1つずつ潰す。まず「力んでいないか」を意識する。',
    todaysQuest: ['エントリー前に肩の力を抜いた', '水中で力んでいないか確認した'],
    reviewChecks: ['前回より残圧が残った'],
    difficulty: 3,
    recommendedDives: '10〜50',
    isPro: false,
  },
  {
    chapter: '4',
    chapterName: '中性浮力',
    no: '4-1',
    title: '足を止めると沈むと思っていた私',
    myStory: '足を動かし続けないと沈むと思っていた。実は足で深度を維持していた。',
    whyItHappened: '無意識にフィンキックで浮力を補っていた。BCDが実は浮力不足の状態だった。',
    improvement: '足を止めてみる。沈むならBCDに空気が足りていないサイン。',
    todaysQuest: ['足を10秒止めてみた', '沈んだらBCDに空気を足した'],
    reviewChecks: ['足を止めても深度を維持できた'],
    difficulty: 3,
    recommendedDives: '10〜50',
    isPro: false,
  },
  {
    chapter: '4',
    chapterName: '中性浮力',
    no: '4-3',
    title: '被写体から離れていく私',
    myStory: '写真を撮ろうとするたびに浮いてしまい、被写体から離れていった。',
    whyItHappened: 'ピントを合わせる際に無意識に息を止める。息を止めると浮く。',
    improvement: 'シャッターを押す瞬間も呼吸を止めない。息をゆっくり吐きながら撮影する。',
    todaysQuest: ['撮影中も呼吸を続けた'],
    reviewChecks: ['撮影中に浮かなかった', '被写体との距離を保てた'],
    difficulty: 3,
    recommendedDives: '30〜100',
    isPro: false,
  },
  {
    chapter: '5',
    chapterName: '器材',
    no: '5-2',
    title: '中圧ホースを忘れる私',
    myStory: 'セッティングしてエントリー直前に中圧ホースのつなぎ忘れに気づいた。2回連続でやった。',
    whyItHappened: '器材セッティングの手順が体に入っていない。確認作業を省略していた。',
    improvement: 'セッティング後にインフレータで空気を入れてみる。これで中圧ホース・タンク開栓・接続を同時確認できる。',
    todaysQuest: ['インフレータでBCDに空気を入れて確認した'],
    reviewChecks: ['中圧ホースのつなぎ忘れがなかった'],
    difficulty: 1,
    recommendedDives: '0〜',
    isPro: false,
  },
];

async function seedArticles() {
  console.log('Firestoreにデータを投入中...');

  for (const article of articles) {
    const docRef = db.collection('articles').doc(`${article.chapter}-${article.no}`);
    await docRef.set(article);
    console.log(`投入完了: ${article.no} ${article.title}`);
  }

  console.log('完了！');
  process.exit(0);
}

seedArticles().catch(console.error);
