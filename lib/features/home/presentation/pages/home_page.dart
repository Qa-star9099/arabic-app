import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arabcha/app/theme/app_colors.dart';
import 'package:arabcha/app/theme/app_typography.dart';
import 'package:arabcha/features/home/models/course_data.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Switch to dark mode matching the rest of the app design
    const bgColor = AppColors.background;
    const textColor = AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.restart_alt_rounded,
              color: Colors.white, size: 20),
          onPressed: () async {
            // FOR TESTING ONLY: Reset onboarding state
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({
                'learningGoal': FieldValue.delete(),
                'level': FieldValue.delete(),
              });
            }
            await FirebaseAuth.instance.signOut();
          },
        ),
        title: Text(
          'Kurs Tafsilotlari',
          style: AppTypography.heading2
              .copyWith(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: () => _showTopToast(context, "Tez kunda (قريباً)"),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond_rounded,
                          color: AppColors.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '10k',
                        style: AppTypography.label.copyWith(
                            color: AppColors.gold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMainCourseCard(context, mockCourseData),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Boblar',
                  style: AppTypography.heading2
                      .copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => _showTopToast(context, "Tez kunda (قريباً)"),
                  child: Text(
                    'Barchasi >',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.emerald, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...mockCourseData.chapters.map(
                (chapter) => _buildChapterCard(context, chapter, textColor)),
          ],
        ),
      ),
    );
  }

  void _showTopToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodySmall
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 40,
          right: 40,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildMainCourseCard(BuildContext context, CourseData data) {
    return InkWell(
      onTap: () {
        context.push('/agenda/T-01');
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: AppTypography.heading1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle,
                    size: 6, color: AppColors.emeraldLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0x66FFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatPill(Icons.people_alt_rounded, data.totalUsers,
                    AppColors.emeraldLight),
                _buildStatPill(Icons.access_time_rounded, data.totalDuration,
                    AppColors.violetLight),
                _buildStatPill(
                    Icons.star_rounded, data.rating, AppColors.goldLight),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String text, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.label.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(
      BuildContext context, CourseChapter chapter, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          _showTopToast(context, "Tez kunda (قريباً)");
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x07FFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0x12FFFFFF),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: chapter.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.play_lesson_rounded,
                  color: chapter.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: AppTypography.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14, color: chapter.accentColor),
                        Text(
                          chapter.duration,
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0x99FFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.library_books_rounded,
                            size: 14, color: chapter.accentColor),
                        Text(
                          "${chapter.lessonCount} Dars",
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0x99FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
