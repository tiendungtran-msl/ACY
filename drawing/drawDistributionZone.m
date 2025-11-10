function drawDistributionZone(ax_main, SCH)
    %% VẼ VÙNG PHÂN PHỐI MỤC TIÊU (ĐƠN GIẢN - 2 ĐƯỜNG BIÊN)
    
    % ═══════════════════════════════════════════════════════
    % THAM SỐ VÙNG PHÂN PHỐI
    % ═══════════════════════════════════════════════════════
    DISTRIBUTION_RANGE_MAX = 50000;   % Cự ly xa: 50km
    
    % Tâm vùng phân phối = vị trí SCH
    center_pos = SCH.pos(1:2);  % [x, y]
    
    % Góc để vẽ vòng tròn (360 điểm)
    theta = linspace(0, 2*pi, 360);
    
    % ═══════════════════════════════════════════════════════
    % VẼ ĐƯỜNG BIÊN NGOÀI (CỰ LY XA 50KM)
    % ═══════════════════════════════════════════════════════
    x_outer = center_pos(1) + DISTRIBUTION_RANGE_MAX * cos(theta);
    y_outer = center_pos(2) + DISTRIBUTION_RANGE_MAX * sin(theta);
    
    plot(ax_main, x_outer, y_outer, '-', ...
         'LineWidth', 1, ...
         'Color', [1, 0.7, 0.2]);
end