import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String chapter;
  final String chapterName;
  final String no;
  final String title;
  final String myStory;
  final String whyItHappened;
  final String improvement;
  final List<String> todaysQuest;
  final List<String> reviewChecks;
  final int difficulty;
  final String recommendedDives;
  final bool isPro;

  Article({
    required this.id,
    required this.chapter,
    required this.chapterName,
    required this.no,
    required this.title,
    required this.myStory,
    required this.whyItHappened,
    required this.improvement,
    required this.todaysQuest,
    required this.reviewChecks,
    required this.difficulty,
    required this.recommendedDives,
    required this.isPro,
  });

  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Article(
      id: doc.id,
      chapter: data['chapter'] ?? '',
      chapterName: data['chapterName'] ?? '',
      no: data['no'] ?? '',
      title: data['title'] ?? '',
      myStory: data['myStory'] ?? '',
      whyItHappened: data['whyItHappened'] ?? '',
      improvement: data['improvement'] ?? '',
      todaysQuest: List<String>.from(data['todaysQuest'] ?? []),
      reviewChecks: List<String>.from(data['reviewChecks'] ?? []),
      difficulty: data['difficulty'] ?? 1,
      recommendedDives: data['recommendedDives'] ?? '',
      isPro: data['isPro'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chapter': chapter,
      'chapterName': chapterName,
      'no': no,
      'title': title,
      'myStory': myStory,
      'whyItHappened': whyItHappened,
      'improvement': improvement,
      'todaysQuest': todaysQuest,
      'reviewChecks': reviewChecks,
      'difficulty': difficulty,
      'recommendedDives': recommendedDives,
      'isPro': isPro,
    };
  }
}
