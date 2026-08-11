function [h_circle_2d, h_circle_3d] = drawObservationZone(ax_2d, ax_3d, SCH, radius)
    %% VẼ VÙNG QUAN SÁT (BÁN KÍNH 60KM)
    % Input:
    %   ax_2d - axes 2D
    %   ax_3d - axes 3D
    %   SCH - struct chứa thông tin SCH
    %   radius - bán kính vùng quan sát (m)
    
    % ═══════════════════════════════════════════════════════
    % VẼ ĐƯỜNG TRÒN VÙNG QUAN SÁT 2D
    % ═══════════════════════════════════════════════════════
    theta = linspace(0, 2*pi, 100);
    x_circle = SCH.pos(1) + radius * cos(theta);
    y_circle = SCH.pos(2) + radius * sin(theta);
    
    h_circle_2d = plot(ax_2d, x_circle, y_circle, '--', ...
        'Color', [0.5, 0.5, 0.5], ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('Vùng quan sát (R=%.0fkm)', radius/1000));
    
    % Thêm text chú thích
    text(ax_2d, SCH.pos(1) + radius*0.707, SCH.pos(2) + radius*0.707, ...
        sprintf('  R=%dkm', round(radius/1000)), ...
        'Color', [0.5, 0.5, 0.5], ...
        'FontSize', 9, ...
        'FontWeight', 'bold');
    
    % ═══════════════════════════════════════════════════════
    % VẼ HÌNH TRỤ VÙNG QUAN SÁT 3D
    % ═══════════════════════════════════════════════════════
    % Tạo hình trụ (từ mặt đất đến độ cao tối đa)
    height_max = 25000;  % Độ cao tối đa 25km
    
    % Tạo lưới cho hình trụ
    [X, Y, Z] = cylinder(radius, 50);
    Z = Z * height_max;  % Scale độ cao
    
    % Dịch chuyển đến vị trí SCH
    X = X + SCH.pos(1);
    Y = Y + SCH.pos(2);
    
    % Vẽ hình trụ trong suốt
    h_circle_3d = surf(ax_3d, X, Y, Z, ...
        'FaceColor', [0.7, 0.7, 0.7], ...
        'FaceAlpha', 0.15, ...
        'EdgeColor', [0.5, 0.5, 0.5], ...
        'EdgeAlpha', 0.3, ...
        'LineStyle', '--', ...
        'DisplayName', 'Vùng quan sát');
    
    fprintf('✓ Đã vẽ vùng quan sát R=%.0fkm\n', radius/1000);
end