function target = moveTargetAlongPath(target, dt)
    % Di chuyển mục tiêu dọc theo đường cong
    
    smooth_path = target.smooth_path;
    current_idx = target.path_index;
    
    if current_idx >= size(smooth_path, 1)
        target.status = 'Hoàn thành';
        target.vel = [0, 0, 0];
        return;
    end
    
    % Tính quãng đường cần di chuyển
    distance_to_move = target.speed * dt;
    accumulated_dist = 0;
    new_idx = current_idx;
    
    % Di chuyển dọc path
    while new_idx < size(smooth_path, 1) && accumulated_dist < distance_to_move
        segment_dist = norm(smooth_path(new_idx+1,:) - smooth_path(new_idx,:));
        
        if accumulated_dist + segment_dist <= distance_to_move
            accumulated_dist = accumulated_dist + segment_dist;
            new_idx = new_idx + 1;
        else
            % Nội suy vị trí
            remaining_dist = distance_to_move - accumulated_dist;
            ratio = remaining_dist / segment_dist;
            target.pos(1:2) = smooth_path(new_idx,:) + ...
                ratio * (smooth_path(new_idx+1,:) - smooth_path(new_idx,:));
            new_idx = new_idx + 1;
            break;
        end
    end
    
    % Cập nhật trạng thái
    if new_idx >= size(smooth_path, 1)
        target.pos(1:2) = smooth_path(end,:);
        target.status = 'Hoàn thành';
        target.vel = [0, 0, 0];
    else
        target.path_index = new_idx;
        target.pos(1:2) = smooth_path(new_idx,:);
        
        % Tính vector vận tốc
        if new_idx < size(smooth_path, 1)
            direction = smooth_path(new_idx+1,:) - smooth_path(new_idx,:);
            if norm(direction) > 0
                target.vel(1:2) = target.speed * direction / norm(direction);
            end
        end
    end
end