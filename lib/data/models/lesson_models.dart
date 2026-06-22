/// ============================================================
/// Lesson data models — Cognate-First Spiral (8 bosqich)
/// Survival Arabic for Uzbekistan
///
/// Uslub mavjud `placement_test/models` bilan izchil:
/// const konstruktorlar, /// dokumentatsiya, null-safety.
/// Manba: statik JSON (assets) — serverless.
/// ============================================================

/// Bitta survival mavzu (masalan T-01 Aeroport).
/// Bir mavzu bir nechta [LessonWord] dan iborat — har biri 8 bosqichdan o'tadi.
class LessonTopic {
  const LessonTopic({
    required this.id,
    required this.title,
    required this.titleUz,
    required this.phase,
    required this.icon,
    required this.isFree,
    required this.words,
  });

  /// Unikal identifikator: 'T-01', 'T-13' va h.k.
  final String id;

  /// Mavzu nomi (display): "Aeroport".
  final String title;

  /// O'zbekcha tavsif: "Aeroport va pasport nazorati".
  final String titleUz;

  /// Journey bosqichi: 'arrival', 'transport', 'daily', 'emergency'.
  final String phase;

  /// Ikona nomi (Tabler/Material): 'plane-departure'.
  final String icon;

  /// Freemium: free tier (Arrival + Emergency) yoki premium.
  final bool isFree;

  /// Shu mavzudagi so'zlar — har biri to'liq 8 bosqichli spiral.
  final List<LessonWord> words;

  factory LessonTopic.fromJson(Map<String, dynamic> json) {
    return LessonTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      titleUz: json['titleUz'] as String,
      phase: json['phase'] as String,
      icon: json['icon'] as String,
      isFree: json['isFree'] as bool? ?? false,
      words: (json['words'] as List<dynamic>)
          .map((w) => LessonWord.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Bitta so'zning to'liq 8 bosqichli o'quv birligi.
/// Har bir maydon ma'lum bir bosqichga xizmat qiladi.
class LessonWord {
  const LessonWord({
    required this.id,
    required this.uzbekCognate,
    required this.uzbekMeaning,
    required this.arabic,
    required this.transliteration,
    required this.stressSyllable,
    required this.root,
    required this.family,
    required this.listenOptions,
    required this.sentence,
    required this.scenario,
  });

  /// Unikal: 'w-safar'.
  final String id;

  // ── 1. RECOGNIZE bosqichi ──
  /// Tanish o'zbekcha so'z: "safar".
  final String uzbekCognate;

  /// O'zbekcha ma'no izohi: "sayohat, yo'l".
  final String uzbekMeaning;

  // ── 2. REVEAL bosqichi ──
  /// Arab yozuvi (harakat bilan): "سَفَر".
  final String arabic;

  /// Lotin transliteratsiya: "safar".
  final String transliteration;

  /// Urg'u tushadigan bo'g'in indeksi (transliteratsiyada): 1 = "FAR".
  final int stressSyllable;

  /// 3-harfli ildiz.
  final LessonRoot root;

  // ── 3. EXPAND bosqichi ──
  /// So'z oilasi (root family).
  final List<FamilyWord> family;

  // ── 4. LISTEN bosqichi ──
  /// Tinglash mashqi variantlari (biri to'g'ri).
  final List<ListenOption> listenOptions;

  // ── 6. COMBINE bosqichi ──
  /// Gap tuzish mashqi: "men musofirman".
  final SentenceTask sentence;

  // ── 7. APPLY bosqichi ──
  /// Survival mini-scenario.
  final ScenarioTask scenario;

  factory LessonWord.fromJson(Map<String, dynamic> json) {
    return LessonWord(
      id: json['id'] as String,
      uzbekCognate: json['uzbekCognate'] as String,
      uzbekMeaning: json['uzbekMeaning'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      stressSyllable: json['stressSyllable'] as int? ?? 0,
      root: LessonRoot.fromJson(json['root'] as Map<String, dynamic>),
      family: (json['family'] as List<dynamic>)
          .map((f) => FamilyWord.fromJson(f as Map<String, dynamic>))
          .toList(),
      listenOptions: (json['listenOptions'] as List<dynamic>)
          .map((o) => ListenOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      sentence: SentenceTask.fromJson(json['sentence'] as Map<String, dynamic>),
      scenario: ScenarioTask.fromJson(json['scenario'] as Map<String, dynamic>),
    );
  }
}

/// 3-harfli ildiz (REVEAL bosqichi).
class LessonRoot {
  const LessonRoot({
    required this.letters,
    required this.meaning,
  });

  /// Ildiz harflari: ['س', 'ف', 'ر'].
  final List<String> letters;

  /// Ildiz ma'nosi: "sayohat".
  final String meaning;

  factory LessonRoot.fromJson(Map<String, dynamic> json) {
    return LessonRoot(
      letters: (json['letters'] as List<dynamic>).cast<String>(),
      meaning: json['meaning'] as String,
    );
  }
}

/// So'z oilasidagi bitta so'z (EXPAND bosqichi).
class FamilyWord {
  const FamilyWord({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.isKnownInUzbek = false,
  });

  final String arabic;
  final String transliteration;
  final String meaning;

  /// O'zbekchada ham tanishmi? (masalan "musofir") → "tanish!" belgisi.
  final bool isKnownInUzbek;

  factory FamilyWord.fromJson(Map<String, dynamic> json) {
    return FamilyWord(
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
      isKnownInUzbek: json['isKnownInUzbek'] as bool? ?? false,
    );
  }
}

/// Tinglash mashqi varianti (LISTEN bosqichi).
class ListenOption {
  const ListenOption({
    required this.arabic,
    required this.meaning,
    required this.isCorrect,
  });

  /// Arab yozuvi (harakat bilan).
  final String arabic;

  /// O'zbekcha tarjima.
  final String meaning;

  /// To'g'ri javobmi?
  final bool isCorrect;

  factory ListenOption.fromJson(Map<String, dynamic> json) {
    return ListenOption(
      arabic: json['arabic'] as String,
      meaning: json['meaning'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}

/// Gap tuzish mashqi (COMBINE bosqichi).
class SentenceTask {
  const SentenceTask({
    required this.promptUz,
    required this.correctOrder,
    required this.wordBank,
  });

  /// O'zbekcha topshiriq: "Men musofirman" deb ayting.
  final String promptUz;

  /// To'g'ri tartibdagi arab so'zlari: ['أنا', 'مُسَافِر'].
  final List<String> correctOrder;

  /// Tanlash uchun so'zlar (chalg'ituvchi bilan).
  final List<SentenceChip> wordBank;

  factory SentenceTask.fromJson(Map<String, dynamic> json) {
    return SentenceTask(
      promptUz: json['promptUz'] as String,
      correctOrder: (json['correctOrder'] as List<dynamic>).cast<String>(),
      wordBank: (json['wordBank'] as List<dynamic>)
          .map((c) => SentenceChip.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Gap tuzishdagi bitta so'z bo'lagi.
class SentenceChip {
  const SentenceChip({
    required this.arabic,
    required this.meaning,
  });

  final String arabic;
  final String meaning;

  factory SentenceChip.fromJson(Map<String, dynamic> json) {
    return SentenceChip(
      arabic: json['arabic'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

/// Survival mini-scenario (APPLY bosqichi).
class ScenarioTask {
  const ScenarioTask({
    required this.locationUz,
    required this.npcRole,
    required this.npcQuestionArabic,
    required this.npcQuestionUz,
    required this.options,
  });

  /// Vaziyat tavsifi: "Jidda aeroporti. Xodim savol beradi.".
  final String locationUz;

  /// NPC roli: "Pasport nazorati xodimi".
  final String npcRole;

  /// NPC savoli (arab, harakat bilan): "ما هو سبب سفرك؟".
  final String npcQuestionArabic;

  /// NPC savoli tarjimasi: "Safaringiz sababi nima?".
  final String npcQuestionUz;

  /// Javob variantlari (biri to'g'ri).
  final List<ScenarioOption> options;

  factory ScenarioTask.fromJson(Map<String, dynamic> json) {
    return ScenarioTask(
      locationUz: json['locationUz'] as String,
      npcRole: json['npcRole'] as String,
      npcQuestionArabic: json['npcQuestionArabic'] as String,
      npcQuestionUz: json['npcQuestionUz'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => ScenarioOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Scenario javob varianti.
class ScenarioOption {
  const ScenarioOption({
    required this.arabic,
    required this.meaning,
    required this.isCorrect,
  });

  final String arabic;
  final String meaning;
  final bool isCorrect;

  factory ScenarioOption.fromJson(Map<String, dynamic> json) {
    return ScenarioOption(
      arabic: json['arabic'] as String,
      meaning: json['meaning'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}
