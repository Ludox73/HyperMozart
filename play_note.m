function play_note(frequencies, noteIdx, how_long)
%PLAY_NOTE Play a given note
fs = 44100;
t = 0:1/fs:how_long;
f = frequencies(noteIdx);  % Frequency
nota = sin(2*pi*f*t);    % Generazione dell'onda sinusoidale

soundsc(nota, fs);         
end