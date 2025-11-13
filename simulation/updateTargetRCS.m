function targets = updateTargetRCS(targets, fire_units)
    %% CẬP NHẬT RCS THEO CỰ LY ĐẾN ĐVHL
    % Mô tả: Tính RCS hiệu dụng phụ thuộc vào khoảng cách đến ĐVHL
    % Input:
    %   - targets: Mảng các mục tiêu
    %   - fire_units: Mảng các đơn vị hỏa lực
    % Output:
    %   - targets: Mảng mục tiêu đã cập nhật RCS_eff và distance_to_DVHL
    
    D_ref = 100000;  % Khoảng cách tham chiếu: 100 km
    
    for i = 1:length(targets)
        target = targets(i);
        
        % Tìm ĐVHL gần nhất
        min_dist = inf;
        for j = 1:length(fire_units)
            unit = fire_units(j);
            if isa(unit, 'FireUnit')
                unit_pos = unit.pos;
            else
                unit_pos = unit.pos;
            end
            
            % Tính khoảng cách 2D (x, y)
            d = sqrt((target.pos(1) - unit_pos(1))^2 + ...
                     (target.pos(2) - unit_pos(2))^2);
            
            if d < min_dist
                min_dist = d;
            end
        end
        
        % Cập nhật distance_to_DVHL
        if isa(target, 'Target')
            target.distance_to_DVHL = min_dist;
        else
            targets(i).distance_to_DVHL = min_dist;
        end
        
        % Tính RCS_real (Enemy - ground truth)
        RCS_base = target.RCS;
        RCS_min = target.RCS_min;
        RCS_max = target.RCS_max;
        
        if min_dist > 0 && min_dist < inf
            RCS_real = RCS_base * sqrt(D_ref / min_dist);
        else
            RCS_real = RCS_base;
        end
        
        % Clamp vào khoảng [RCS_min, RCS_max]
        RCS_real = max(RCS_min, min(RCS_max, RCS_real));
        
        % Cập nhật RCS_real
        if isa(target, 'Target')
            target.RCS_real = RCS_real;
            
            % ACY đo được với nhiễu ±10%
            noise_factor = 1 + 0.1 * randn();
            target.RCS_eff = max(0.01, RCS_real * noise_factor);
        else
            targets(i).RCS_real = RCS_real;
            
            % ACY đo được với nhiễu ±10%
            noise_factor = 1 + 0.1 * randn();
            targets(i).RCS_eff = max(0.01, RCS_real * noise_factor);
        end
    end
end