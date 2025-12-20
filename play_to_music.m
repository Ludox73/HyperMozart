% AI generated

A = to_music;

for ind_A = 1:size(A,1)
    if A(ind_A,1) == 3
        A(ind_A,1)=1;
    elseif A(ind_A,1) == 4
        A(ind_A,1)=2;
    elseif A(ind_A,1) == 7
        A(ind_A,1)=5;
    elseif A(ind_A,1) ==8
        A(ind_A,1)=6;
    end
end

for ind_A = 1:size(A,1)
    if A(ind_A,1) == 5
        A(ind_A,1)=3;
    elseif A(ind_A,1) == 6
        A(ind_A,1)=4;
    end
end

% We want to go 10x faster.
A(:,2) = 1/10*A(:,2);


% Parameters
fs = 44100;            % Sample rate (Hz)
gap = 0.00;            % Optional silence between notes in seconds (e.g., 0.01)
attack = 0.01;         % Attack time (s) for fade-in
release = 0.02;        % Release time (s) for fade-out

% Map 1->C4, 2->D4, 3->E4, 4->G4 using MIDI then convert to frequency
midiLUT = [60, 62, 64, 67];              % C4, D4, E4, G4
freqLUT = 440 * 2.^((midiLUT - 69)/12);  % A4=440 Hz equal temperament

y = [];                                   % output audio buffer (row vector)

for i = 1:size(A,1)
    noteId = round(A(i,1));   % ensure integer
    dur    = A(i,2);          % seconds
    
    if noteId == 0
        % Treat 0 as REST (optional — not in your data)
        nSamples = max(1, round(dur * fs));
        y = [y, zeros(1, nSamples)];
        continue;
    end
    
    if noteId < 1 || noteId > 4
        error('Note ID %d out of range. Allowed IDs: 1->C, 2->D, 3->E, 4->G.', noteId);
    end
    
    f = freqLUT(noteId);                   % frequency for this note
    nSamples = max(1, round(dur * fs));    % samples for this note
    t = (0:nSamples-1) / fs;
    
    % Envelope to avoid clicks (cap at 1/4 note length)
    a = min(attack, dur/4);
    r = min(release, dur/4);
    na = round(a * fs);
    nr = round(r * fs);
    env = ones(1, nSamples);
    if na > 0, env(1:na) = linspace(0, 1, na); end
    if nr > 0, env(end-nr+1:end) = linspace(1, 0, nr); end
    
    % Generate sine wave segment
    yseg = sin(2*pi*f*t) .* env;
    
    % Optional short gap between notes
    if gap > 0
        ygap = zeros(1, round(gap * fs));
        y = [y, yseg, ygap];
    else
        y = [y, yseg];
    end
end

% Normalize (avoid clipping)
y = y / max(abs(y) + eps);

% Play
% sound(y, fs);

% Save to mp3 (optional)
audiowrite('note_sequence.wav', y.', fs); % column vector required
disp('Saved to note_sequence.wav');
