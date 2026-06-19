# Onboarding → Cognate-First Spiral moslashtirish
## Aniq o'zgarishlar hujjati (kod bilan)
### Qoida: animatsiya/mexanika SAQLANADI, faqat kontent/matn o'zgaradi

---

## 1. splash_page.dart — O'ZGARISH: MINIMAL

Splash yaxshi. Faqat tagline matn o'zgarishi kerak (agar bor bo'lsa).

**Eslatma:** Splash kodda "Arabcha" brend nomi va animatsiya. Bu saqlanadi. O'zgarish shart emas.

**Xulosa: TEGMANG.**

---

## 2. welcome_page.dart — O'ZGARISH: MATN VA KETMA-KETLIK

Animatsiyalar, kartalar, orb'lar, Google Auth — hammasi saqlanadi.
Faqat quyidagi matnlarni o'zgartiring (find & replace):

### 2a. Sarlavha

TOPIB O'ZGARTIRING:
```
HOZIR:  'Arab tilini oson o\'rganing!\n🌟 هيا نتعلم'
KERAK:  'Siz allaqachon arab tilini bilasiz!\n🌟 هيا نتعلم'
```

### 2b. Feature kartalar TARTIBINI o'zgartiring (2-karta → 1-kartaga chiqsin)

HOZIR (tartib):
1. Maxrajni SI bilan tekshirish
2. O'zaro bog'liq O'zbek-Arab so'zlari
3. Interaktiv o'rganish metodikasi

KERAK (tartib):
1. O'zbek-Arab cognate so'zlari (BIRINCHI — bu bizning UVP!)
2. Saudiyaga survival tili (YANGI — aniq pozitsiya)
3. Maxrajni AI bilan tekshirish (uchinchi — Bosqich B)

TOPIB O'ZGARTIRING (birinchi karta):
```dart
// === BIRINCHI KARTA (hozirgi ikkinchi kartani birinchiga ko'chiring) ===
// HOZIR:
title: 'Maxrajni SI bilan tekshirish ',
subtitle: 'Talaffuzingiz to\'g\'riligini baholaymiz!',
// O'ZGARTIRING:
title: 'Siz bilgan so\'zlar — allaqachon arab!',
subtitle: '3000+ o\'zbekcha so\'z arabchadan kelgan',
```

TOPIB O'ZGARTIRING (ikkinchi karta):
```dart
// === IKKINCHI KARTA ===
// HOZIR:
title: 'O\'zaro bog\'liq O\'zbek-Arab so\'zlari ',
subtitle: 'Umumiy so\'zlar orqali 2x tez o\'rganing!',
// O'ZGARTIRING:
title: 'Saudiyaga tayyor bo\'ling',
subtitle: 'Aeroport, taksi, dorixona — survival tili',
```

TOPIB O'ZGARTIRING (uchinchi karta):
```dart
// === UCHINCHI KARTA ===
// HOZIR:
title: 'Interaktiv o\'rganish metodikasi',
subtitle: 'XP yig\'ing va peshqadam bo\'ling! ممتاز',
// O'ZGARTIRING:
title: 'Maxrajni AI bilan tekshiring',
subtitle: 'Talaffuzingiz to\'g\'riligini baholaymiz',
```

### 2c. Soxta statistika olib tashlash

HOZIR:
```dart
'12,400+',
// va
'O\'zbek o\'quvchilari 🇺🇿',
```

KERAK: Bu soxta raqam (mahsulot hali chiqmagan). Investor yoki QA ko'rsa — ishonch yo'qoladi.
```dart
'3000+',
// va
'O\'zbekcha-arabcha umumiy so\'zlar',
```

### 2d. CTA tugmasi

HOZIR:
```dart
'Boshlash — mutlaqo bepul! انطلق'
```

KERAK (survival framing):
```dart
'Bepul boshlash — انطلق'
```

---

## 3. goal_selection_page.dart — O'ZGARISH: VARIANTLAR

Goals ro'yxatini o'zgartiring. Mavjud `_GoalOption` class va UI mexanikasi saqlanadi.
Faqat `_goals` listini o'zgartiring:

HOZIR:
```dart
_GoalOption(
  title: 'Biznes uchun  Arab Tili',
  subtitle: 'Kelishuvlar · Shartnomalar · Uchrashuvlar',
  icon: Icons.business_center_rounded,
  accentColor: AppColors.emerald,
  accentLight: AppColors.emeraldLight,
),
_GoalOption(
  title: 'Sayohat uchun Arab Tili ',
  subtitle: 'Mehmonxonalar · Aeroportlar · Kundalik hayot',
  icon: Icons.flight_rounded,
  accentColor: AppColors.gold,
  accentLight: AppColors.goldLight,
),
_GoalOption(
  title: 'Akademik Arab Tili ',
  subtitle: 'Universitet · Imtihonlar · Izlanishlar',
  icon: Icons.school_rounded,
  accentColor: AppColors.violet,
  accentLight: AppColors.violetLight,
),
```

KERAK:
```dart
_GoalOption(
  title: 'Saudiyaga sayohat',
  subtitle: 'Aeroport · Mehmonxona · Taksi · Dorixona',
  icon: Icons.flight_rounded,
  accentColor: AppColors.gold,
  accentLight: AppColors.goldLight,
),
_GoalOption(
  title: 'Biznes uchun arab tili',
  subtitle: 'Uchrashuvlar · Kelishuvlar · Shartnomalar',
  icon: Icons.business_center_rounded,
  accentColor: AppColors.emerald,
  accentLight: AppColors.emeraldLight,
),
_GoalOption(
  title: 'Mehnat uchun (migratsiya)',
  subtitle: 'Kundalik hayot · Rasmiy murojaat · Xavfsizlik',
  icon: Icons.engineering_rounded,
  accentColor: AppColors.violet,
  accentLight: AppColors.violetLight,
),
```

> Eslatma: "Akademik" olib tashlandi, "Mehnat migranti" qo'shildi (Lean Canvas segmenti).
> "Saudiyaga sayohat" aniq pozitsiya — umumiy "Sayohat" emas.

---

## 4. level_selection_page.dart — O'ZGARISH: FRAMING

Eng muhim o'zgarish — A1/A2/B1 **saqlanadi** (ichki data sifatida), lekin
foydalanuvchiga ko'rinadigan **matn** cognate framingga o'zgaradi.

HOZIR:
```dart
_LevelOption(
  title: 'Boshlang\'ich (A1)',
  subtitle: 'Men endi o\'rganishni boshlayapman',
  icon: Icons.filter_1_rounded,
  accentColor: AppColors.emerald,
  accentLight: AppColors.emeraldLight,
),
_LevelOption(
  title: 'O\'rta (A2)',
  subtitle: 'Asosiy so\'zlar va qoidalarni bilaman',
  icon: Icons.filter_2_rounded,
  accentColor: AppColors.gold,
  accentLight: AppColors.goldLight,
),
_LevelOption(
  title: 'Ilg\'or (B1)',
  subtitle: 'Erkin suhbatlasha olaman',
  icon: Icons.filter_3_rounded,
  accentColor: AppColors.violet,
  accentLight: AppColors.violetLight,
),
```

KERAK:
```dart
_LevelOption(
  title: 'Arab harflarini bilmayman',
  subtitle: 'Lekin ko\'p so\'zni allaqachon bilasiz!',
  icon: Icons.auto_awesome_rounded,
  accentColor: AppColors.emerald,
  accentLight: AppColors.emeraldLight,
),
_LevelOption(
  title: 'Harflarni tanib olaman',
  subtitle: 'Ba\'zi so\'zlarni o\'qiy olaman',
  icon: Icons.visibility_rounded,
  accentColor: AppColors.gold,
  accentLight: AppColors.goldLight,
),
_LevelOption(
  title: 'Sodda gaplar tuza olaman',
  subtitle: 'Asosiy suhbat qila olaman',
  icon: Icons.chat_rounded,
  accentColor: AppColors.violet,
  accentLight: AppColors.violetLight,
),
```

> Diqqat: "Boshlang'ich" o'rniga "Arab harflarini bilmayman, LEKIN ko'p so'zni
> allaqachon bilasiz!" — bu cognate framing. Foydalanuvchi A1 deb
> tushkunlashmaydi, aksincha "voy, men bilar ekanman" his qiladi.

---

## 5. path_selection_page.dart — O'ZGARISH: TO'LIQ REFRAMING

Eng katta o'zgarish shu yerda.

HOZIR:
```dart
title: 'Darajani aniqlash',
subtitle: 'Siz bilgan mavzularni o\'tkazib yuboring.\nAynan o\'z darajangizdan boshlang.',
icon: Icons.checklist_rtl_rounded,
accentColor: AppColors.emerald,
pills: const ['A1 -> B2 aniqlash', '10 ta savol'],
tag: '~3 daq',
```
```dart
title: 'Noldan boshlash',
subtitle: 'Arab tilini eng boshidan,\nalifbodan boshlab o\'rganing.',
icon: Icons.auto_stories_rounded,
accentColor: AppColors.violet,
pills: const ['Alifbo', 'Boshlang\'ich sozlar'],
tag: null,
```

KERAK:
```dart
title: 'Qancha arab so\'zni bilasiz?',
subtitle: 'O\'zbekchada yashiringan arab so\'zlarni\ntopib, darajangizni aniqlang.',
icon: Icons.search_rounded,
accentColor: AppColors.emerald,
pills: const ['Cognate test', '10 ta savol'],
tag: '~2 daq',
```
```dart
title: 'Darhol boshlayman!',
subtitle: 'Tanish so\'zlardan boshlab,\nqadam-baqadam o\'rganamiz.',
icon: Icons.rocket_launch_rounded,
accentColor: AppColors.violet,
pills: const ['Tanish so\'zlar', 'Survival arab tili'],
tag: null,
```

> MUHIM: "Noldan boshlash" → "Darhol boshlayman!" (nol so'zi YO'Q).
> "Alifbodan" → "Tanish so'zlardan" (cognate framing).
> Placement test → "Cognate test" (qancha arab so'zni bilasiz?).

---

## 6. YANGI SAHIFA: aha_moment_page.dart

Bu placement test natijasidan keyin chiqadi.
Foydalanuvchiga "Siz allaqachon 47 ta arab so'zini bilasiz!" ko'rsatadi.
Bu emosional yuqori nuqta — bu ilovadan ketmaslik sababi.

To'liq yangi fayl:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';

/// "Aha!" moment sahifasi — Cognate-First Spiral'ning kalit lahzasi.
///
/// Placement/cognate test natijasidan keyin foydalanuvchiga
/// qancha arab so'zni allaqachon bilishini ko'rsatadi.
/// Maqsad: ishonch + motivatsiya + "men buni qila olaman" hissi.
class AhaMomentPage extends StatefulWidget {
  /// Foydalanuvchi cognate testda nechta to'g'ri topgani.
  final int knownWordsCount;

  /// Umumiy berilgan so'zlar soni.
  final int totalWords;

  const AhaMomentPage({
    super.key,
    required this.knownWordsCount,
    required this.totalWords,
  });

  @override
  State<AhaMomentPage> createState() => _AhaMomentPageState();
}

class _AhaMomentPageState extends State<AhaMomentPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _countAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _countAnim = Tween<double>(begin: 0, end: widget.knownWordsCount.toDouble())
        .animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
    ));

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.totalWords > 0
        ? (widget.knownWordsCount / widget.totalWords * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated counter
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnim.value,
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.emeraldLight,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${_countAnim.value.toInt()}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w500,
                              color: AppColors.emerald,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'arab so\'zni allaqachon bilasiz!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Motivatsiya xabari
              AnimatedBuilder(
                animation: _fadeAnim,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnim.value,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'O\'zbek tilida 3000+ so\'z arabchadan kelgan.\n'
                            'Siz noldan boshlamayapsiz!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'kitob, safar, sabab, javob, dunyo...',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(flex: 3),

              // CTA tugma
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutes.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'O\'rganishni boshlash',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> Eslatma: `AppColors` va `AppRoutes` nomlarini sizning kodingizga moslang.
> `AnimatedBuilder` → sizning kodingizda `AnimatedBuilder` bor, lekin
> Flutter standard `AnimatedBuilder` (yoki `AnimatedWidget`). Tekshiring.
> Router'da yangi route qo'shish kerak: /aha-moment

---

## 7. app_router.dart — YANGI ROUTE QO'SHISH

Placement test natijasidan keyin aha_moment sahifasiga yo'naltirish.

```dart
// AppRoutes class'iga qo'shing:
static const String ahaMoment = '/aha-moment';

// GoRouter route'lariga qo'shing:
GoRoute(
  path: '/aha-moment',
  builder: (context, state) {
    final known = state.extra as Map<String, int>? ?? {};
    return AhaMomentPage(
      knownWordsCount: known['known'] ?? 0,
      totalWords: known['total'] ?? 10,
    );
  },
),
```

---

## 8. Placement test → Cognate test

placement_test_controller.dart va mock_test_data.dart o'zgarishi
kerak — umumiy arab tili savollaridan cognate awareness savollariga.

BU KATTA ISH — alohida sprint. Hozircha mavjud placement test saqlanadi,
faqat path_selection_page'dagi framing o'zgaradi ("Cognate test" deyiladi).

Keyingi qadam sifatida mock_test_data.dart'dagi savollarni cognate
savollariga almashtirish kerak:

```dart
// Misol: Cognate awareness savol
TestQuestion(
  id: 'cog1',
  type: QuestionType.multipleChoice,
  difficulty: 'A1',
  questionText: '"Kitob" so\'zi arabchadan kelganmi?',
  options: ['Ha, arabcha كِتَاب', 'Yo\'q, forscha', 'Yo\'q, turkcha'],
  correctAnswerIndex: 0,
  xpReward: 10,
),
```

> Bu to'liq almashtirishni keyingi sessiyada qilamiz.

---

## O'zgarishlar qo'llash tartibi

1. welcome_page.dart — matnlar (2a-2d)
2. goal_selection_page.dart — variantlar (3)
3. level_selection_page.dart — framing (4)
4. path_selection_page.dart — reframing (5)
5. aha_moment_page.dart — YANGI fayl (6)
6. app_router.dart — yangi route (7)
7. (Keyin) mock_test_data.dart — cognate savollar (8)

