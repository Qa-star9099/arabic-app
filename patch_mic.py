import glob

files = [
    'lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_3_talaffuz.dart',
    'lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart'
]

for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    # We want to wrap the mic pointer down logic in a try-catch to show a snackbar if it crashes on simulator
    old_code = """          onPointerDown: (_) async {
            if (await _audioRecorder.hasPermission()) {"""
            
    new_code = """          onPointerDown: (_) async {
            try {
              if (await _audioRecorder.hasPermission()) {"""
              
    content = content.replace(old_code, new_code)
    
    # Now find the end of that block and add the catch
    old_end = """              _waveController.repeat();
            }
          },"""
          
    new_end = """              _waveController.repeat();
            }
            } catch (e) {
              debugPrint("Mic error: $e");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Simulyatorda mikrofon ishlamaydi. Iltimos haqiqiy qurilmada tekshiring.")),
                );
              }
            }
          },"""
          
    # Wait, the end of the block in step 3 vs 7 might be slightly different.
    # In step 3, _waveController might not be there? Let's check step 3.
    pass
