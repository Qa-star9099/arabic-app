import 'package:flutter/material.dart';
import 'package:arabcha/app/theme/app_colors.dart';

class CourseChapter {
  final String title;
  final String duration;
  final int lessonCount;
  final Color accentColor;

  const CourseChapter({
    required this.title,
    required this.duration,
    required this.lessonCount,
    required this.accentColor,
  });
}

class CourseData {
  final String title;
  final String subtitle;
  final String totalUsers;
  final String totalDuration;
  final String rating;
  final List<CourseChapter> chapters;

  const CourseData({
    required this.title,
    required this.subtitle,
    required this.totalUsers,
    required this.totalDuration,
    required this.rating,
    required this.chapters,
  });
}

// Dummy data adapted for Arabic Learning (Tutor Style)
const mockCourseData = CourseData(
  title: "1. Alifbo (الحروف)",
  subtitle: "Arab alifbosi harflari va ularning talaffuzi",
  totalUsers: "24.5k",
  totalDuration: "3s 30d",
  rating: "4.9",
  chapters: [
    CourseChapter(
      title: "Arab tili demo dars",
      duration: "12 Soat 45 Daqiqa",
      lessonCount: 1,
      accentColor: AppColors.emerald,
    ),
    CourseChapter(
      title: "2. Salomlashish va Tanishuv (التعارف)",
      duration: "2 Soat 15 Daqiqa",
      lessonCount: 6,
      accentColor: AppColors.violet,
    ),
    CourseChapter(
      title: "3. Otlar va Jins (مذكر و مؤنث)",
      duration: "4 Soat 00 Daqiqa",
      lessonCount: 8,
      accentColor: AppColors.gold,
    ),
    CourseChapter(
      title: "4. Shamsiy va Qamariy harflar (حروف شمسية وقمرية)",
      duration: "1 Soat 45 Daqiqa",
      lessonCount: 4,
      accentColor: AppColors.emeraldLight,
    ),
  ],
);
