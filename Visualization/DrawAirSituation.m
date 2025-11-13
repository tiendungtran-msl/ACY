function DrawAirSituation(ax_2d, ax_3d, situation, cfg)
    %% VẼ TÌNH HUỐNG TRÊN KHÔNG
    % Mô tả: Vẽ toàn bộ tình huống không chiến lên màn hình
    % Input:
    %   - ax_2d: Axes 2D
    %   - ax_3d: Axes 3D
    %   - situation: AirSituation object hoặc struct chứa thông tin
    %   - cfg: Cấu hình hệ thống (optional)
    
    if nargin < 4
        cfg = config();
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % VẼ SỞ CHỈ HUY
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if isa(situation, 'AirSituation')
        SCH = situation.SCH;
        targets = situation.targets;
        fire_units = situation.fire_units;
        protected_objects = situation.protected_objects;
    else
        % Giả định là struct từ code cũ
        SCH = situation.SCH;
        targets = situation.targets;
        fire_units = situation.fire_units;
        protected_objects = situation.targets_protect;
    end
    
    % Vẽ SCH
    axes(ax_2d);
    plot(SCH.pos(1), SCH.pos(2), 'p', ...
        'MarkerSize', 20, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w', ...
        'LineWidth', 2);
    text(SCH.pos(1), SCH.pos(2)+2000, 'SCH', ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', 'k');
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % VẼ ĐỐI TƯỢNG BẢO VỆ
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    for i = 1:length(protected_objects)
        obj = protected_objects(i);
        if isa(obj, 'ProtectedObject')
            pos = obj.pos;
            name = obj.name;
        else
            pos = obj.pos;
            name = obj.name;
        end
        
        plot(ax_2d, pos(1), pos(2), 'h', ...
            'MarkerSize', 15, 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k');
        text(pos(1), pos(2)-2000, name, ...
            'HorizontalAlignment', 'center', 'FontSize', 8);
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % VẼ ĐƠN VỊ HỎA LỰC VÀ VÙNG TIÊU DIỆT
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    for i = 1:length(fire_units)
        unit = fire_units(i);
        if isa(unit, 'FireUnit')
            pos = unit.pos;
            name = unit.name;
            range_max = unit.range_max;
        else
            pos = unit.pos;
            name = unit.name;
            range_max = unit.range_max;
        end
        
        % Vẽ đơn vị
        plot(ax_2d, pos(1), pos(2), 'd', ...
            'MarkerSize', 12, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
        text(pos(1), pos(2)+2000, name, ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        
        % Vẽ vùng tiêu diệt
        if cfg.display_zones
            theta = linspace(0, 2*pi, 100);
            x_circle = pos(1) + range_max * cos(theta);
            y_circle = pos(2) + range_max * sin(theta);
            plot(ax_2d, x_circle, y_circle, 'g--', 'LineWidth', 1);
        end
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % VẼ MỤC TIÊU
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    for i = 1:length(targets)
        target = targets(i);
        if isa(target, 'Target')
            pos = target.pos;
            name = target.name;
            marker = target.marker;
            Bj = target.Bj;
        else
            pos = target.pos;
            name = target.name;
            marker = target.marker;
            if isfield(target, 'Bj')
                Bj = target.Bj;
            else
                Bj = 0;
            end
        end
        
        % Màu theo mức độ ưu tiên
        color = ColorMapping(Bj/10, cfg);
        
        % Vẽ mục tiêu
        plot(ax_2d, pos(1), pos(2), marker, ...
            'MarkerSize', 12, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k', ...
            'LineWidth', 1.5);
        
        % Nhãn
        if cfg.display_labels
            text(pos(1), pos(2)+1500, name, ...
                'HorizontalAlignment', 'center', 'FontSize', 7, ...
                'Color', color, 'FontWeight', 'bold');
        end
    end
    
end