function score = rule7_TimeToKill(target, fire_units)
    % QUY TAC 7: DANH GIA THEO THOI GIAN TIEP CAN
    % Output: score thuoc [0, 10]
    
    if isempty(fire_units)
        score = 5.0;
        return;
    end
    
    min_time = inf;
    
    for i = 1:length(fire_units)
        unit = fire_units(i);
        
        dist_2d = norm(target.pos(1:2) - unit.pos(1:2));
        
        if dist_2d >= unit.range_max
            distance_to_zone = dist_2d - unit.range_max;
        elseif dist_2d <= unit.range_min
            distance_to_zone = unit.range_min - dist_2d;
        else
            distance_to_zone = 0;
        end
        
        if distance_to_zone == 0
            time_to_zone = 0;
        else
            if isfield(target, 'vel') && norm(target.vel) > 0
                velocity = target.vel;
                to_unit = unit.pos - target.pos;
                vel_toward_unit = dot(velocity(1:2), to_unit(1:2)) / norm(to_unit(1:2));
                
                if vel_toward_unit > 0
                    time_to_zone = distance_to_zone / vel_toward_unit;
                else
                    time_to_zone = inf;
                end
            else
                if target.speed > 0
                    time_to_zone = distance_to_zone / target.speed;
                else
                    time_to_zone = inf;
                end
            end
        end
        
        if time_to_zone < min_time
            min_time = time_to_zone;
        end
    end
    
    % Tinh diem
    if min_time == 0
        score = 10.0;
    elseif min_time < 10
        score = 9.5;
    elseif min_time < 20
        score = 9.0;
    elseif min_time < 30
        score = 8.5;
    elseif min_time < 60
        score = 8.0;
    elseif min_time < 120
        score = 7.0;
    elseif min_time < 180
        score = 6.0;
    elseif min_time < 300
        score = 5.0;
    elseif min_time < 600
        score = 4.0;
    elseif min_time < inf
        score = 3.0;
    else
        score = 2.0;
    end
    
    score = max(0, min(10, score));
end