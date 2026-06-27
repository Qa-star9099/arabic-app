with open('lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart', 'r') as f:
    c = f.read()

c = c.replace("""              const Text(
                "Harakat tanlang, eshiting va talaffuz qiling",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
        ),""", """              const Text(
                "Harakat tanlang, eshiting va talaffuz qiling",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),""")

with open('lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart', 'w') as f:
    f.write(c)
