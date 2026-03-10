function play_note_marimba(frequencies, noteIdx, how_long)
%PLAY_NOTE Play a given note. Give a little marimba flavour.
fs = 44100;
t = 0:1/fs:1.5;
f= frequencies(noteIdx);  % Frequency

% 1. Fundamental: The "body" of the wood (slow decay)
fund = 1.0 * sin(2*pi*f*t) .* exp(-5 * t);

% 2. 4th Harmonic: The "ring" (fast decay)
% Marimbas are tuned so the 1st overtone is 2 octaves up
h4 = 0.4 * sin(2*pi*(f*4.01)*t) .* exp(-15 * t); % 4.01 adds a tiny 'natural' detune

% 3. 10th Harmonic: The "strike" (instant decay)
% This provides the percussive hit without ringing like a bell
h10 = 0.15 * sin(2*pi*(f*10)*t) .* exp(-50 * t);

% 4. The "Thud": A tiny burst of modulated noise for the mallet impact
% We create a quick burst and fade it out in 0.01 seconds
thud = 0.1 * rand(1, length(t)) .* exp(-100 * t);

% Combine everything
marimba = fund + h4 + h10 + thud;

% 5. Smooth the "Attack" (Fade-in)
% This removes the electronic "click" at the start
attack_time = 0.005; % 5ms
samples_attack = round(attack_time * fs);
envelope = ones(size(t));
envelope(1:samples_attack) = linspace(0, 1, samples_attack);

final_signal = marimba .* envelope;

% Normalize and Play
final_signal = final_signal / max(abs(final_signal));
sound(final_signal, fs);
end