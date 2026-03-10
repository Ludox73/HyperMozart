%% 3D Surface Model: Genus 2 (Double Torus) with Sections y=0 and z=0
% This script generates a genus 2 surface and overlays intersection curves.
% Styles are defined in a central library for easy customization.

% --- 1. STYLE LIBRARY (Color, LineStyle, LineWidth) ---
Lib = curves_S2_styles();

% --- 2. ASSIGNMENT (Link model parts to Library indices) ---
% Plane z=0: Upper parts (y >= 0)
S.z0_U1 = Lib{1}; S.z0_U2 = Lib{2}; S.z0_U3 = Lib{3};
% Plane z=0: Lower parts (y < 0)
S.z0_L1 = Lib{4}; S.z0_L2 = Lib{5}; S.z0_L3 = Lib{6};
% Plane y=0: Three full curves
S.y0_C1 = Lib{7}; S.y0_C2 = Lib{8}; S.y0_C3 = Lib{9};

% 3. Setup 3D Grid and Implicit Equation
[x, y, z] = meshgrid(linspace(-0.6, 2.6, 150), linspace(-1.2, 1.2, 150), linspace(-1, 1, 100));
f_x = x .* (x - 1).^2 .* (x - 2); 
r = 0.15; 
V = (f_x + y.^2).^2 + z.^2 - r^2;

% 4. Render the Surface
figure('Color', 'w');
p = patch(isosurface(x, y, z, V, 0));
set(p, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.15); 
hold on;

% 5. Three Curves on Plane z = 0 (Horizontal Section)
C_z = contourc(linspace(-0.6, 2.6, 150), linspace(-1.2, 1.2, 150), V(:,:,50), [0 0]);
idx = 1; k = 1;
u_styles = {S.z0_U1, S.z0_U2, S.z0_U3};
l_styles = {S.z0_L1, S.z0_L2, S.z0_L3};

while idx < size(C_z, 2)
    n = C_z(2, idx);
    xc = C_z(1, idx+1:idx+n); yc = C_z(2, idx+1:idx+n); zc = zeros(size(xc));
    
    % Draw segment y >= 0
    st_u = u_styles{mod(k-1,3)+1};
    yp = yc; yp(yc < 0) = NaN; 
    plot3(xc, yp, zc, 'Color', st_u{1}, 'LineStyle', st_u{2}, 'LineWidth', st_u{3});
    
    % Draw segment y < 0
    st_l = l_styles{mod(k-1,3)+1};
    yn = yc; yn(yc >= 0) = NaN; 
    plot3(xc, yn, zc, 'Color', st_l{1}, 'LineStyle', st_l{2}, 'LineWidth', st_l{3});
    
    idx = idx + n + 1; k = k + 1;
end

% 6. Three Curves on Plane y = 0 (Vertical Longitudinal Section)
slice_y0 = squeeze(V(75, :, :))'; 
C_y = contourc(linspace(-0.6, 2.6, 150), linspace(-1, 1, 100), slice_y0, [0 0]);
y_styles = {S.y0_C1, S.y0_C2, S.y0_C3};
idx_y = 1; count_y = 1;

while idx_y < size(C_y, 2) && count_y <= 3
    n = C_y(2, idx_y);
    xc_y = C_y(1, idx_y+1 : idx_y+n); zc_y = C_y(2, idx_y+1 : idx_y+n);
    st_y = y_styles{mod(count_y-1,3)+1};
    plot3(xc_y, zeros(size(xc_y)), zc_y, 'Color', st_y{1}, 'LineStyle', st_y{2}, 'LineWidth', st_y{3}); 
    idx_y = idx_y + n + 1; count_y = count_y + 1;
end

% 7. Scene Refinement
daspect([1 1 1]); view(-55, 30); camlight; lighting gouraud; grid on;
title('Genus 2 Surface: no separating curve');
xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis');