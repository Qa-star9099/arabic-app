import json
import sys

transcript_path = '/Users/abdulbasitswe/.gemini/antigravity-ide/brain/f3348ac9-9514-4fbe-9ee2-bc815b475476/.system_generated/logs/transcript.jsonl'
target_file = '/Users/abdulbasitswe/arabic_app/lib/features/placement_test/screens/placement_test_screen.dart'

try:
    with open(transcript_path, 'r') as f:
        lines = f.readlines()
except Exception as e:
    print(f"Error reading transcript: {e}")
    sys.exit(1)

best_content = None
max_len = 0

for line in lines:
    try:
        step = json.loads(line)
        if 'tool_calls' in step:
            for tc in step['tool_calls']:
                args = tc.get('arguments', {})
                if args.get('TargetFile') == target_file:
                    if 'CodeContent' in args:
                        content = args['CodeContent']
                        if len(content) > max_len:
                            max_len = len(content)
                            best_content = content
    except Exception as e:
        continue

if best_content:
    with open('recovered_screen.dart', 'w') as f:
        f.write(best_content)
    print("Recovered file to recovered_screen.dart!")
else:
    print("Could not find CodeContent in transcript.")
