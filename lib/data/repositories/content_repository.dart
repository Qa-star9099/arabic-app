import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson_models.dart';

class ContentRepository {
  /// Bitta mavzuni to'liq JSON dan o'qiydi
  Future<LessonTopic> getTopic(String topicId) async {
    try {
      // Masalan: 'T-01' -> 't01'
      final fileName = topicId.toLowerCase().replaceAll('-', '');
      final path = 'assets/content/topics/${fileName}_aeroport.json'; 
      // Hozircha fayl nomi qattiq kodlangan, lekin keyin dinamik bo'lishi mumkin
      final String jsonString = await rootBundle.loadString(path);
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return LessonTopic.fromJson(jsonData);
    } catch (e) {
      throw Exception('Mavzu topilmadi yoki o\'qishda xatolik: $e');
    }
  }
}
