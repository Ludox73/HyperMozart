
function f = isometry_H2_two_points_upper_half(p1, p2, q1, q2, varargin)
%ISOMETRY_H2_TWO_POINTS Compute the unique orientation-preserving hyperbolic
% isometry of the upper half-plane H that maps p1->q1 and p2->q2.
%
% Inputs:
%   p1, p2, q1, q2 : complex numbers with imag(.) > 0
%   Optional: 'Swap', true/false (default false) 
%       If true, map p1->q2 and p2->q1 (unordered pair mapping).
%
% Output:
%   f : struct with fields
%       a,b,c,d  - real coefficients of the Möbius map (determinant = 1)
%       apply    - function handle: w = f.apply(z) = (a*z + b) / (c*z + d)
%
% Method:
%   Solve the homogeneous real-linear system for [a;b;c;d] from
%       a*p + b = q*(c*p + d)   for p in {p1,p2}, q in {q1,q2}
%   which yields 4 real equations. The solution space is 1D (up to scale).
%   Normalize so that det = a*d - b*c = +1.

% WRITTEN BY AI

    pSwap = false;
    if ~isempty(varargin)
        for k = 1:2:numel(varargin)
            if strcmpi(varargin{k}, 'Swap'), pSwap = varargin{k+1}; end
        end
    end
    if pSwap
        % Map p1->q2 and p2->q1 if Swap requested
        tmp = q1; q1 = q2; q2 = tmp;
    end

    % Basic checks
    if ~(imag(p1)>0 && imag(p2)>0 && imag(q1)>0 && imag(q2)>0)
        error('All points must lie in the upper half-plane (imag(z) > 0).');
    end
    if abs(p1 - p2) == 0 || abs(q1 - q2) == 0
        error('Points in each pair must be distinct.');
    end

    % Build the 4x4 real linear system A*[a;b;c;d] = 0
    A = zeros(4,4);
    P = [p1, p2]; Q = [q1, q2];
    for j = 1:2
        pj = P(j); qj = Q(j);
        qp = qj * pj; % complex product
        % Real part equation: Re(a*pj + b - qj*c*pj - qj*d) = 0
        A(2*j-1,:) = [real(pj), 1, -real(qp), -real(qj)];
        % Imag part equation: Im(a*pj + b - qj*c*pj - qj*d) = 0
        A(2*j,  :) = [imag(pj), 0, -imag(qp), -imag(qj)];
    end

    % Solve for the (1D) nullspace; robust to scaling
    N = null(A, 'r'); % real nullspace basis
    if isempty(N) || size(N,2) ~= 1
        error('No unique real Möbius transform found; input may be degenerate.');
    end
    v = N(:,1);
    a = v(1); b = v(2); c = v(3); d = v(4);

    % Normalize to determinant +1 (orientation-preserving)
    detM = a*d - b*c;
    if detM == 0
        error('Degenerate transform (det=0). Check input points.');
    end
    if detM < 0
        v = -v; % flip sign to make det positive
        a = v(1); b = v(2); c = v(3); d = v(4);
        detM = -detM;
    end
    s = 1 / sqrt(detM);
    a = a * s; b = b * s; c = c * s; d = d * s;

    % Package result
    f.a = a; f.b = b; f.c = c; f.d = d;
    f.apply = @(z) (a .* z + b) ./ (c .* z + d);
end
