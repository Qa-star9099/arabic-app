import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import 'alif_lesson_steps/alif_step_1_tanishuv.dart';
import 'alif_lesson_steps/alif_step_2_yozilishi.dart';
import 'alif_lesson_steps/alif_step_3_talaffuz.dart';
import 'alif_lesson_steps/alif_step_4_yozish.dart';
import 'alif_lesson_steps/alif_step_5_harakatlar.dart';
import 'alif_lesson_steps/alif_step_6_belgini_toping.dart';
import 'alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart';
import 'alif_lesson_steps/alif_step_8_tekshirish.dart';
import 'alif_lesson_steps/alif_step_9_finish.dart';

class AlifLessonPage extends StatefulWidget {
  const AlifLessonPage({super.key});

  @override
  State<AlifLessonPage> createState() => _AlifLessonPageState();
}

class _AlifLessonPageState extends State<AlifLessonPage> {
  int _currentPage = 0;
  static const int _totalPages = 9; // Step 9 is finish

  // Step 2 State
  int? _selectedFormIndex;
  bool _hasSubmittedPage2 = false;

  // Step 6 State
  int _mashqCurrentRound = 1;
  int _mashqCorrectCount = 0;
  int? _mashqSelectedAnswer;
  bool _mashqAnswered = false;
  final List<int> _mashqQuestions = [1, 2, 0, 1, 0, 2]; // 0:fatha, 1:kasra, 2:damma

  // Step 8 (Tekshirish) State
  int _tekshirishKey = 0;

  // Global Score Tracking
  int _step3TalaffuzScore = 0;
  bool _step4YozishSuccess = false;
  int _step7TalaffuzScore = 0;
  int _step8TekshirishScore = 0;

  int _calculateOverallScore() {
    double earned = 0;
    earned += (_step3TalaffuzScore >= 80 ? 1 : 0);
    earned += (_step4YozishSuccess ? 1 : 0);
    earned += _mashqCorrectCount;
    earned += (_step7TalaffuzScore >= 80 ? 1 : 0);
    earned += _step8TekshirishScore;
    
    double maxPossible = 1 + 1 + 6 + 1 + 3; // 12 total
    return ((earned / maxPossible) * 100).toInt().clamp(0, 100);
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      context.go('/home');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _resetMashq() {
    setState(() {
      _mashqCurrentRound = 1;
      _mashqCorrectCount = 0;
      _mashqSelectedAnswer = null;
      _mashqAnswered = false;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void _resetTekshirish() {
    setState(() {
      _tekshirishKey++;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void _showResultModal(bool isSuccess, {bool isTalaffuz = false, bool isMashq = false, int? score, VoidCallback? onRetry}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        final displayScore = score ?? (isTalaffuz ? (isSuccess ? 87 : 32) : null);
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
          decoration: BoxDecoration(
            color: const Color(0xFF13171D), // Dark premium background
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultCircle(isSuccess, score: displayScore),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (isSuccess) {
                      _nextPage();
                    } else if (isMashq) {
                      _resetMashq();
                      _resetTekshirish();
                    } else if (!isTalaffuz) {
                      setState(() {
                        _hasSubmittedPage2 = false;
                        _selectedFormIndex = null;
                      });
                    }
                    if (!isSuccess && onRetry != null) {
                      onRetry();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? AppColors.emerald : Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isSuccess ? 'Davom etish' : 'Qayta urinish',
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1614),
                    ),
                  ),
                ),
              ),
              if (!isSuccess) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _nextPage();
                  },
                  child: Text(
                    "O'tkazib yuborish",
                    style: TextStyle(fontFamily: 'Geist', color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultCircle(bool isSuccess, {int? score}) {
    final color = isSuccess ? AppColors.emerald : Colors.redAccent;
    return Column(
      key: ValueKey('result_$isSuccess'),
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: score != null ? (score / 100) : 1.0,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.1),
                color: color,
                strokeCap: StrokeCap.round,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (score != null) ...[
                    Text(
                      '$score%',
                      style: const TextStyle(fontFamily: 'Geist', fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      'aniq',
                      style: TextStyle(fontFamily: 'Geist', fontSize: 14, color: Colors.white.withOpacity(0.6)),
                    ),
                  ] else ...[
                    Icon(
                      isSuccess ? Icons.check_rounded : Icons.close_rounded,
                      size: 72,
                      color: color,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (score != null) ...[
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeedbackChip("Tovush", isSuccess),
              const SizedBox(width: 12),
              _buildFeedbackChip("Cho'zish", isSuccess),
            ],
          ),
          if (!isSuccess) ...[
            const SizedBox(height: 16),
            Text(
              "Iltimos, harfni ovozingizni chiqarib, aniqroq talaffuz qiling.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ]
        ] else ...[
          const SizedBox(height: 24),
          Text(
            isSuccess ? "To'g'ri javob!" : "Noto'g'ri javob",
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (!isSuccess) ...[
            const SizedBox(height: 8),
            Text(
              "Qayta urinib ko'ring!",
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildFeedbackChip(String label, bool isSuccess) {
    final color = isSuccess ? AppColors.emerald : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSuccess ? Icons.check_rounded : Icons.close_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontFamily: 'Geist', fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentPage == 8 ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () {
            if (_currentPage > 0) {
              _previousPage();
            } else {
              context.go('/home');
            }
          },
        ),
        title: _buildProgressBar(),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.center,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.1),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentPage),
                  child: _buildStepContent(),
                ),
              ),
            ),
            _buildBottomButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 6,
              width: constraints.maxWidth * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: 6,
              width: (constraints.maxWidth * 0.7) * ((_currentPage + 1) / _totalPages),
              decoration: BoxDecoration(
                color: AppColors.emerald,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepContent() {
    switch (_currentPage) {
      case 0:
        return AlifStep1Tanishuv(onStepStateChanged: ({required bool isReady}) {});
      case 1:
        return AlifStep2Yozilishi(
          selectedFormIndex: _selectedFormIndex,
          hasSubmitted: _hasSubmittedPage2,
          onOptionSelected: (index) {
            setState(() {
              _selectedFormIndex = index;
            });
          },
        );
      case 2:
        return AlifStep3Talaffuz(
          onResult: (bool isSuccess, {int? score}) {
            if (score != null && score > _step3TalaffuzScore) {
              _step3TalaffuzScore = score;
            }
            _showResultModal(isSuccess, isTalaffuz: true, score: score);
          },
        );
      case 3:
        return AlifStep4Yozish(
          onResult: (bool isSuccess) {
            if (isSuccess) _step4YozishSuccess = true;
            _showResultModal(isSuccess, isTalaffuz: false);
          },
        );
      case 4:
        return AlifStep5Harakatlar(onStepStateChanged: ({required bool isReady}) {});
      case 5:
        return AlifStep6BelginiToping(
          currentRound: _mashqCurrentRound,
          totalRounds: _mashqQuestions.length,
          correctAnswer: _mashqQuestions[_mashqCurrentRound - 1],
          selectedAnswer: _mashqSelectedAnswer,
          answered: _mashqAnswered,
          onOptionSelected: (index) {
            if (!_mashqAnswered) {
              setState(() {
                _mashqSelectedAnswer = index;
              });
            }
          },
          onReset: _resetMashq,
        );
      case 6:
        return AlifStep7TalaffuzSinovi(
          onResult: (bool isSuccess, {int? score, VoidCallback? onRetry}) {
            if (score != null && score > _step7TalaffuzScore) {
              _step7TalaffuzScore = score;
            }
            _showResultModal(isSuccess, isTalaffuz: true, score: score, onRetry: onRetry);
          },
        );
      case 7:
        return AlifStep8Tekshirish(
          key: ValueKey(_tekshirishKey),
          onResult: (bool isPassed, {int? score}) {
            if (score != null && score > _step8TekshirishScore) {
              _step8TekshirishScore = score;
            }
            _showResultModal(isPassed, isMashq: true);
          },
        );
      case 8:
        return AlifStep9Finish(
          overallScore: _calculateOverallScore(),
          onFinish: () => context.go('/home'),
        );
      default:
        return _buildPlaceholderPage();
    }
  }

  Widget _buildPlaceholderPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction_rounded, color: Colors.white38, size: 64),
          const SizedBox(height: 24),
          Text(
            "Tez orada...",
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final isLastPage = _currentPage == _totalPages - 1;
    bool isEnabled = true;
    if (_currentPage == 1) {
      isEnabled = _selectedFormIndex != null;
    } else if (_currentPage == 5) {
      isEnabled = _mashqSelectedAnswer != null;
    }

    if (_currentPage == 2 || _currentPage == 3 || _currentPage == 6 || _currentPage == 7 || _currentPage == 8) {
      return const SizedBox.shrink(); // Hidden on steps that trigger their own validation
    }

    String buttonText = isLastPage ? 'Yakunlash' : 'Davom etish';
    if (_currentPage == 5 && !_mashqAnswered) {
      buttonText = 'Tekshirish';
    }

    Widget mainButton = SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? () {
          if (_currentPage == 1) {
            setState(() {
              _hasSubmittedPage2 = true;
            });
            if (_selectedFormIndex == 0) { 
              HapticFeedback.lightImpact();
              _showResultModal(true, isTalaffuz: false);
            } else {
              HapticFeedback.heavyImpact();
              _showResultModal(false, isTalaffuz: false);
            }
          } else if (_currentPage == 5) {
            if (!_mashqAnswered) {
              setState(() {
                _mashqAnswered = true;
                int correctAnswer = _mashqQuestions[_mashqCurrentRound - 1];
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                
                if (_mashqSelectedAnswer == correctAnswer) {
                  _mashqCorrectCount++;
                  HapticFeedback.lightImpact();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text(
                            "To'g'ri!",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.emerald,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height - 150,
                        left: 20,
                        right: 20,
                      ),
                      duration: const Duration(seconds: 2),
                      elevation: 0,
                    ),
                  );
                  
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted && _currentPage == 5 && _mashqAnswered) {
                      if (_mashqCurrentRound < 6) {
                        setState(() {
                          _mashqCurrentRound++;
                          _mashqAnswered = false;
                          _mashqSelectedAnswer = null;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        bool isPassed = _mashqCorrectCount >= 4;
                        _showResultModal(isPassed, isMashq: true);
                      }
                    }
                  });
                  
                } else {
                  HapticFeedback.heavyImpact();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.close_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text(
                            "Noto'g'ri, davom eting!",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height - 150,
                        left: 20,
                        right: 20,
                      ),
                      duration: const Duration(seconds: 2),
                      elevation: 0,
                    ),
                  );

                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted && _currentPage == 5 && _mashqAnswered) {
                      if (_mashqCurrentRound < 6) {
                        setState(() {
                          _mashqCurrentRound++;
                          _mashqAnswered = false;
                          _mashqSelectedAnswer = null;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        bool isPassed = _mashqCorrectCount >= 4;
                        _showResultModal(isPassed, isMashq: true);
                      }
                    }
                  });
                }
              });
            }
          } else {
            _nextPage();
          }
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.emerald : Colors.white.withOpacity(0.1),
          foregroundColor: isEnabled ? const Color(0xFF041A0E) : Colors.white.withOpacity(0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Padding(
          key: const ValueKey('main_button'),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: mainButton,
        ),
      ),
    );
  }
}
