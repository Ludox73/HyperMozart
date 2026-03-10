%% 3D Surface Model: Genus 2 (Double Torus) with Characteristic Curves
% This script generates a genus 2 surface and overlays intersection curves.
% Styles are defined in a central library and assigned by index.

% --- 1. STYLE LIBRARY (Define your reusable styles here) ---
% Format: {Color, LineStyle, LineWidth}
Lib = curves_S2_styles();

% --- 2. ASSIGNMENT (Link the model parts to the Library indices) ---
S.z0_Q1 = Lib{4}; % x > 1, y > 0
S.z0_Q2 = Lib{6}; % x > 1, y < 0
S.z0_H2 = Lib{5}; % Hole 2
S.z0_Q4 = Lib{1}; % x < 1, y < 0
S.z0_H1 = Lib{3}; % Hole 1
S.z0_Q3 = Lib{2}; % x < 1, y > 0
S.y0_C1 = Lib{7}; % Vertical 1
S.y0_C2 = Lib{8}; % Vertical 2
S.x1_C  = Lib{9}; % Separating curve

% --- 3. Setup 3D Grid and Implicit Equation ---
[x, y, z] = meshgrid(linspace(-0.6, 2.6, 150), linspace(-1.2, 1.2, 150), linspace(-1, 1, 100));
f_x = x .* (x - 1).^2 .* (x - 2); 
r = 0.15; 
V = (f_x + y.^2).^2 + z.^2 - r^2;

% --- 4. Render Surface ---
figure('Color', 'w');
p = patch(isosurface(x, y, z, V, 0));
set(p, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.2); 
hold on;

% --- 5. Curves on Plane z = 0 ---
C_z = contourc(linspace(-0.6, 2.6, 150), linspace(-1.2, 1.2, 150), V(:,:,50), [0 0]);
idx = 1; hole_styles = {S.z0_H1, S.z0_H2}; k_h = 1;
while idx < size(C_z, 2)
    n = C_z(2, idx);
    xc = C_z(1, idx+1:idx+n); yc = C_z(2, idx+1:idx+n); zc = zeros(size(xc));
    if any(xc < 1) && any(xc > 1)
        q1 = xc; q1(xc<1 | yc<0) = NaN; plot3(q1, yc, zc, 'Color', S.z0_Q1{1}, 'LineStyle', S.z0_Q1{2}, 'LineWidth', S.z0_Q1{3}); 
        q2 = xc; q2(xc<1 | yc>=0) = NaN; plot3(q2, yc, zc, 'Color', S.z0_Q2{1}, 'LineStyle', S.z0_Q2{2}, 'LineWidth', S.z0_Q2{3}); 
        q3 = xc; q3(xc>=1 | yc<0) = NaN; plot3(q3, yc, zc, 'Color', S.z0_Q3{1}, 'LineStyle', S.z0_Q3{2}, 'LineWidth', S.z0_Q3{3}); 
        q4 = xc; q4(xc>=1 | yc>=0) = NaN; plot3(q4, yc, zc, 'Color', S.z0_Q4{1}, 'LineStyle', S.z0_Q4{2}, 'LineWidth', S.z0_Q4{3}); 
    else
        st = hole_styles{mod(k_h-1,2)+1};
        plot3(xc, yc, zc, 'Color', st{1}, 'LineStyle', st{2}, 'LineWidth', st{3});
        k_h = k_h + 1;
    end
    idx = idx + n + 1;
end

% --- 6. Curves on Plane y = 0 ---
slice_y0 = squeeze(V(75, :, :))'; 
C_y = contourc(linspace(-0.6, 2.6, 150), linspace(-1, 1, 100), slice_y0, [0 0]);
y_st = {S.y0_C1, S.y0_C2}; i_y = 1; c_y = 0;
while i_y < size(C_y, 2) && c_y < 2
    n = C_y(2, i_y); xc_y = C_y(1, i_y+1:i_y+n); zc_y = C_y(2, i_y+1:i_y+n);
    st = y_st{c_y+1}; plot3(xc_y, zeros(size(xc_y)), zc_y, 'Color', st{1}, 'LineStyle', st{2}, 'LineWidth', st{3}); 
    i_y = i_y + n + 1; c_y = c_y + 1;
end

% --- 7. Curve on Plane x = 1 ---
c_x1 = contourslice(x, y, z, V, 1, [], [], [0 0]);
set(c_x1, 'EdgeColor', S.x1_C{1}, 'LineStyle', S.x1_C{2}, 'LineWidth', S.x1_C{3});

daspect([1 1 1]); view(-55, 30); camlight; lighting gouraud; grid on;
title('Genus 2 Surface: with separating curve');