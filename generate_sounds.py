import wave, struct, math
import os

os.makedirs('assets/audio', exist_ok=True)

def make_sound(filename, notes):
    wave_file = wave.open(filename, 'w')
    wave_file.setnchannels(1)
    wave_file.setsampwidth(2)
    rate = 44100
    wave_file.setframerate(rate)
    
    for (freq, duration) in notes:
        n_frames = int(duration * rate)
        for i in range(n_frames):
            env = 1.0
            if i < rate * 0.02: env = i / (rate * 0.02)
            elif i > n_frames - rate * 0.02: env = (n_frames - i) / (rate * 0.02)
            # Mix a sine and square wave for a slightly richer sound
            sine = math.sin(2.0 * math.pi * freq * i / rate)
            value = int(env * 16000.0 * sine)
            wave_file.writeframes(struct.pack('<h', value))
    
    wave_file.close()

# Correct: C5, E5, G5 (quick ascending arpeggio)
make_sound('assets/audio/correct.wav', [(523.25, 0.08), (659.25, 0.08), (783.99, 0.2)])
# Wrong: Low C followed by lower G
make_sound('assets/audio/wrong.wav', [(196.00, 0.15), (164.81, 0.25)])

print("Sounds generated.")
