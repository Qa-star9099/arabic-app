import 'test_question.dart';

const List<TestQuestion> mockTestQuestions = [
  // ── A1 Questions (First 3 determine early exit) ───────────────

  // 1. Multiple Choice
  TestQuestion(
    id: 'q1',
    type: QuestionType.multipleChoice,
    difficulty: 'A1',
    questionText: '"مَرْحَبًا" nimani anglatadi?',
    options: ['Xayr', 'Salom', 'Rahmat', 'Iltimos'],
    correctAnswerIndex: 1,
    xpReward: 10,
  ),

  // 2. Visual Identification
  TestQuestion(
    id: 'q2',
    type: QuestionType.visualId,
    difficulty: 'A1',
    questionText: 'Qaysi biri "kitob"?',
    imageUrl:
        'https://cdn-icons-png.flaticon.com/512/2232/2232688.png', // Generic book icon placeholder
    options: ['قَلَم', 'كِتَاب', 'بَيْت', 'مَدْرَسَة'],
    correctAnswerIndex: 1,
    xpReward: 10,
  ),

  // 3. Audio Test
  TestQuestion(
    id: 'q3',
    type: QuestionType.audioTest,
    difficulty: 'A1',
    questionText: 'Eshitgan so\'zingizni tanlang:',
    audioUrl:
        'https://translate.google.com/translate_tts?ie=UTF-8&q=%D8%B4%D9%8F%D9%83%D9%92%D8%B1%D9%8B%D8%A7&tl=ar&client=tw-ob',
    options: ['مَرْحَبًا', 'شُكْرًا', 'عَفْوًا', 'سَلَام'], // Add options
    correctAnswerIndex: 1, // 'شُكْرًا' is index 1
    xpReward: 10,
  ),

  // ── A2 Questions ──────────────────────────────────────────────

  // 4. Match Pairs
  TestQuestion(
    id: 'q4',
    type: QuestionType.matchPairs,
    difficulty: 'A2',
    questionText: 'So\'zlarni tarjimasi bilan moslashtiring:',
    matchingPairs: {
      'كَبِير': 'Katta',
      'صَغِير': 'Kichkina',
      'جَدِيد': 'Yangi',
      'قَدِيم': 'Eski',
    },
    xpReward: 15,
  ),

  // 5. Fill in the Blank
  TestQuestion(
    id: 'q5',
    type: QuestionType.fillInBlank,
    difficulty: 'A2',
    questionText: 'Bo\'sh joyni to\'ldiring: ذَهَبْتُ ___ المَدْرَسَة',
    options: ['فِي', 'إِلَى', 'مِنْ', 'عَلَى'],
    correctAnswerIndex: 1,
    xpReward: 15,
  ),

  // ── B1 Questions ──────────────────────────────────────────────

  // 6. Sentence Scramble
  TestQuestion(
    id: 'q6',
    type: QuestionType.sentenceScramble,
    difficulty: 'B1',
    questionText: 'Gapni to\'g\'ri tuzing: "Men qahva ichaman"',
    scrambledWords: ['القَهْوَةَ', 'أَنَا', 'أَشْرَبُ'],
    options: [
      'أَنَا',
      'أَشْرَبُ',
      'القَهْوَةَ'
    ], // The correct ordered sequence
    xpReward: 20,
  ),

  // 7. Error Identification
  TestQuestion(
    id: 'q7',
    type: QuestionType.errorId,
    difficulty: 'B1',
    questionText: 'Xato so\'zni toping: "هُوَ تَقْرَأُ الكِتَابَ"',
    options: ['هُوَ', 'تَقْرَأُ', 'الكِتَابَ'],
    errorWordIndex: 1, // تَقْرَأُ is incorrect for هُوَ (should be يَقْرَأُ)
    xpReward: 20,
  ),

  // 8. Multiple Choice
  TestQuestion(
    id: 'q8',
    type: QuestionType.multipleChoice,
    difficulty: 'A2',
    questionText: '"المُعَلِّمُ" so\'zining ko\'pligi qaysi?',
    options: ['المُعَلِّمَة', 'المُعَلِّمُونَ', 'المُعَلِّمَات', 'أَعْلَام'],
    correctAnswerIndex: 1,
    xpReward: 15,
  ),

  // 9. Match Pairs
  TestQuestion(
    id: 'q9',
    type: QuestionType.matchPairs,
    difficulty: 'A2',
    questionText: 'Fe\'llarni tarjimasi bilan moslashtiring:',
    matchingPairs: {
      'يَأْكُلُ': 'Yeydi',
      'يَشْرَبُ': 'Ichadi',
      'يَنَامُ': 'Uxlaydi',
      'يَلْعَبُ': 'O\'ynaydi',
    },
    xpReward: 15,
  ),

  // 10. Fill in the Blank
  TestQuestion(
    id: 'q10',
    type: QuestionType.fillInBlank,
    difficulty: 'B1',
    questionText:
        'Bo\'sh joyni to\'ldiring: الطَّالِبُ ___ يَدْرُسُ بَاكِرًا يَنْجَحُ',
    options: ['الَّذِي', 'الَّتِي', 'الَّذِينَ', 'اللَّوَاتِي'],
    correctAnswerIndex: 0,
    xpReward: 20,
  ),

  // 11. Error Identification
  TestQuestion(
    id: 'q11',
    type: QuestionType.errorId,
    difficulty: 'B1',
    questionText:
        'Xato so\'zni toping: "ذَهَبَتْ الأَوْلَادُ إِلَى المَلْعَبِ"',
    options: ['ذَهَبَتْ', 'الأَوْلَادُ', 'إِلَى', 'المَلْعَبِ'],
    errorWordIndex: 0, // ذَهَبَتْ should be ذَهَبَ for الأَوْلَاد
    xpReward: 20,
  ),

  // 12. Sentence Scramble
  TestQuestion(
    id: 'q12',
    type: QuestionType.sentenceScramble,
    difficulty: 'B1',
    questionText:
        'Gapni to\'g\'ri tuzing: "Men arab tilini o\'rganishni yaxshi ko\'raman"',
    scrambledWords: [
      'أُحِبُّ',
      'أَنْ',
      'أَتَعَلَّمَ',
      'اللُّغَةَ',
      'العَرَبِيَّةَ'
    ],
    options: ['أُحِبُّ', 'أَنْ', 'أَتَعَلَّمَ', 'اللُّغَةَ', 'العَرَبِيَّةَ'],
    xpReward: 20,
  ),
];
