import re
import glob

files = glob.glob('lib/features/alifbo/presentation/pages/alif_lesson_steps/*.dart')

for file_path in files:
    with open(file_path, 'r') as file:
        content = file.read()
    
    # 1. Tanishuv
    # 2. Yozilishi
    # 3. Talaffuz
    # 4. Yozish
    # 5. Harakatlar
    # 6. Belgini toping
    # 7. Talaffuz sinovi
    
    # regex to match: Text("X. Something", style: TextStyle(fontFamily: 'Geist', fontSize: 24 (or 28), fontWeight: FontWeight.w700, color: Colors.white))
    # Note: Step 7 has fontSize: 28, others have 24.
    
    pattern = r'(?:const )?Text\(\s*"(\d\.\s*[^"]+)",\s*style:\s*(?:const )?TextStyle\(\s*fontFamily:\s*\'Geist\',\s*fontSize:\s*(?:24|28),\s*fontWeight:\s*FontWeight\.w700,\s*color:\s*Colors\.white,?\s*\),?\s*\)'
    
    def replacer(match):
        text_val = match.group(1)
        return f'Text("{text_val}", style: TextStyle(fontFamily: \'Geist\', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5)))'
        
    content = re.sub(pattern, replacer, content)
    
    # Also adjust some SizedBoxes around it from 20/24 to 12/16 to save space
    # It's safer just to change the text widget itself first.
    
    with open(file_path, 'w') as file:
        file.write(content)
