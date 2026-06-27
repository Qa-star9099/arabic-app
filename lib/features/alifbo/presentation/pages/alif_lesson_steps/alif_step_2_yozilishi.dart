import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';

class AlifStep2Yozilishi extends StatelessWidget {
  final int? selectedFormIndex;
  final bool hasSubmitted;
  final ValueChanged<int> onOptionSelected;

  const AlifStep2Yozilishi({
    super.key,
    required this.selectedFormIndex,
    required this.hasSubmitted,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("2. Yozilishi", style: TextStyle(fontFamily: 'Geist', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 24),
          const Text(
            "Alifning 2 ko'rinishi",
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildFormCard('ALOHIDA', 'ا','اب')),
              const SizedBox(width: 16),
              Expanded(child: _buildFormCard('OXIRIDA', 'ـا', 'باب')),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.emerald, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Alif faqat o'ng tomondan ulanadi. Chap tomondan hech qachon ulanmaydi.",
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'MINI TEST',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildMiniTest(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormCard(String title, String letter, String example) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            letter,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 56,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              example,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 18,
                color: AppColors.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTest() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bu qaysi ko'rinish?",
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'ا',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 40,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildTestOption(0, 'Alohida')),
              const SizedBox(width: 12),
              Expanded(child: _buildTestOption(1, 'Oxirida')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestOption(int index, String label) {
    final isSelected = selectedFormIndex == index;
    final isCorrect = index == 0; // Alohida is correct for 'ا'
    
    Color borderColor = Colors.white.withValues(alpha: 0.05);
    Color textColor = Colors.white.withValues(alpha: 0.4);
    Color backgroundColor = const Color(0xFF191D24);

    if (isSelected) {
      borderColor = AppColors.emerald;
      textColor = AppColors.emerald;
      backgroundColor = AppColors.emerald.withValues(alpha: 0.1);
    }

    if (hasSubmitted && isSelected) {
      if (isCorrect) {
        borderColor = AppColors.emerald;
        textColor = AppColors.emerald;
        backgroundColor = AppColors.emerald.withValues(alpha: 0.1);
      } else {
        borderColor = Colors.redAccent;
        textColor = Colors.redAccent;
        backgroundColor = Colors.redAccent.withValues(alpha: 0.1);
      }
    }

    return GestureDetector(
      onTap: () => onOptionSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
            if (hasSubmitted && isSelected && isCorrect) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_rounded, size: 16, color: AppColors.emerald),
            ],
            if (hasSubmitted && isSelected && !isCorrect) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
            ],
          ],
        ),
      ),
    );
  }
}
