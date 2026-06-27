import re

files = {
    'lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_6_belgini_toping.dart': ('"Belgini toping"', '"6. Belgini toping"'),
    'lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart': ('"Talaffuz sinovi"', '"7. Talaffuz sinovi"')
}

for file_path, (old_val, new_val) in files.items():
    with open(file_path, 'r') as file:
        content = file.read()
    content = content.replace(old_val, new_val)
    with open(file_path, 'w') as file:
        file.write(content)
