function score = optimalPositionRule(target, fire_units)
    % QUY TAC 8: DANH GIA THEO VI TRI TOI UU
    % Output: score thuoc [0, 10]
    
    if isempty(fire_units)
        score = 5.0;
        return;
    end
    
    best_score = 0;
    
    for i = 1:length(fire_units)
        unit = fire_units(i);
        to_target = target.pos(1:2) - unit.pos(1:2);
        
        if norm(to_target) == 0
            continue;
        end
        
        % Goc phuong vi
        azimuth = atan2d(to_target(2), to_target(1));
        if azimuth < 0
            azimuth = azimuth + 360;
        end
        
        % Phuong toi uu: 90 do
        optimal_azimuth = 90;
        deviation = abs(azimuth - optimal_azimuth);
        if deviation > 180
            deviation = 360 - deviation;
        end
        
        % Tinh diem
        if deviation <= 5
            position_score = 10.0;
        elseif deviation <= 15
            position_score = 9.0;
        elseif deviation <= 30
            position_score = 8.0;
        elseif deviation <= 45
            position_score = 7.0;
        elseif deviation <= 60
            position_score = 6.0;
        elseif deviation <= 90
            position_score = 5.0;
        elseif deviation <= 120
            position_score = 4.0;
        elseif deviation <= 150
            position_score = 3.0;
        else
            position_score = 2.0;
        end
        
        % Dieu chinh theo khoang cach
        dist = norm(to_target);
        optimal_range = unit.range_max * 0.7;
        range_deviation = abs(dist - optimal_range) / unit.range_max;
        distance_factor = 1.0 - (range_deviation * 0.2);
        distance_factor = max(0.8, min(1.0, distance_factor));
        
        final_score = position_score * distance_factor;
        
        if final_score > best_score
            best_score = final_score;
        end
    end
    
    score = best_score;
    score = max(0, min(10, score));
end