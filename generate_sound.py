import wave
import struct
import math

# Audio parameters
sample_rate = 44100
duration_sec = 2.0
frequency = 800.0  # Annoying high pitch beep

# Open wav file
obj = wave.open('MyApp/alarm.wav','w')
obj.setnchannels(1) # mono
obj.setsampwidth(2) # 16-bit
obj.setframerate(sample_rate)

# Generate beep-beep-beep pattern
num_samples = int(sample_rate * duration_sec)
for i in range(num_samples):
    # Time in seconds
    t = float(i) / sample_rate
    
    # 5 beeps per second (on for 0.1s, off for 0.1s)
    beep_envelope = 1.0 if (t % 0.2) < 0.1 else 0.0
    
    # Square wave generation for harsh buzz
    period = 1.0 / frequency
    phase = t % period
    value = 32767.0 if phase < (period / 2.0) else -32767.0
    
    # Apply envelope and slight volume reduction
    final_value = int(value * beep_envelope * 0.8)
    
    # Write sample
    data = struct.pack('<h', final_value)
    obj.writeframesraw(data)

obj.close()
