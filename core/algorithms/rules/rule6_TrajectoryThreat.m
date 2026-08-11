function score = rule6_TrajectoryThreat(target, targets_protect)
    % QUY TAC 6: DANH GIA THEO HUONG BAY
    % Output: score thuoc [0, 10]
    
    if isempty(targets_protect)
        score = 5.0;
        return;
    end
    
    % Du doan quy dao
    if isfield(target, 'vel') && norm(target.vel) > 0
        velocity = target.vel;
    else
        velocity = [target.speed, 0, 0];
    end
    
    future_positions = zeros(2, 3);
    future_positions(1, :) = target.pos + velocity * 5;
    future_positions(2, :) = target.pos + velocity * 10;
    
    % Tinh khoang cach
    min_distance = inf;
    
    for i = 1:length(targets_protect)
        protect_pos = targets_protect(i).pos;
        
        current_dist = norm(target.pos(1:2) - protect_pos(1:2));
        
        for j = 1:size(future_positions, 1)
            future_dist = norm(future_positions(j, 1:2) - protect_pos(1:2));
            if future_dist < min_distance
                min_distance = future_dist;
            end
        end
        
        if norm(velocity(1:2)) > 0
            to_protect = protect_pos(1:2) - target.pos(1:2);
            vel_2d = velocity(1:2);
            projection_length = dot(to_protect, vel_2d) / norm(vel_2d);
            
            if projection_length > 0
                closest_point = target.pos(1:2) + (projection_length / norm(vel_2d)) * vel_2d;
                cpa_distance = norm(closest_point - protect_pos(1:2));
                if cpa_distance < min_distance
                    min_distance = cpa_distance;
                end
            end
        end
    end
    
    % Tinh diem
    if min_distance < 2000
        score = 10.0;
    elseif min_distance < 5000
        score = 9.0;
    elseif min_distance < 10000
        score = 7.5;
    elseif min_distance < 20000
        score = 6.0;
    else
        score = 4.0;
    end
    
    score = max(0, min(10, score));
end