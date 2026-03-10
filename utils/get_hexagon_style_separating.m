function styleIdx = get_hexagon_style_separating(val1, val2)
    % Definisce la matrice di mappatura dove le righe sono il primo indice
    % e le colonne il secondo indice. Il valore nella cella è l'indice di Styles.
    % Usiamo 0 per le combinazioni non definite (es. 1,1 o 1,2).
    
    lookup = [
        9, 2, 7, 3, 7, 1;  % RIGA 1: (1,1) a (1,6)
        9, 2, 7, 3, 7, 1;  % RIGA 2: (2,1) a (2,6)
        9, 6, 8, 5, 8, 4;  % RIGA 3: (3,1) a (3,6)
        9, 6, 8, 5, 8, 4   % RIGA 4: (4,1) a (4,6)
    ];

    % Controllo dei limiti per evitare errori di indice
    if val1 >= 1 && val1 <= size(lookup, 1) && ...
       val2 >= 1 && val2 <= size(lookup, 2)
        
        styleIdx = lookup(val1, val2);
        
        if styleIdx == 0
            error('Undefined pair (%d, %d).', val1, val2);
        end
    else
        error('Out of intervals: val1(1-4), val2(1-6).');
    end
end