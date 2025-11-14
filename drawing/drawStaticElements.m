function drawStaticElements(ax_main, ax_3d, SCH, targets_protect, fire_units)
    % Vẽ SCH, MTBV và đơn vị hỏa lực
    
    % Vẽ Sở Chỉ Huy
    drawSCH(ax_main, ax_3d, SCH);
    
    % Vẽ mục tiêu bảo vệ
    for i = 1:length(targets_protect)
        drawProtectedTarget(ax_main, ax_3d, targets_protect(i));
    end
    
    % Vẽ đơn vị hỏa lực
    fire_colors = {[1, 0.3, 0.3], [1, 0.9, 0.3], [0.4, 1, 0.4]};
    for i = 1:length(fire_units)
        drawFireUnit(ax_main, ax_3d, fire_units(i), fire_colors{i});
    end

    % Vẽ đơn vị hỏa lực
    drawDistributionZone(ax_main, SCH);

    % ═══════════════════════════════════════════════════════
    % VẼ VÙNG QUAN SÁT 60KM
    % ═══════════════════════════════════════════════════════
    observation_radius = 60000;  % 60km
    [~, ~] = drawObservationZone(ax_main, ax_3d, SCH, observation_radius);
    
    legend(ax_main, 'off');
end