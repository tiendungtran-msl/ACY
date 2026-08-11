function target = moveTargetAlongPath(target, dt)
    %% DI CHUYỂN MỤC TIÊU VỚI VẬN TỐC PHỤ THUỘC ĐỘ CONG
    
    smooth_path = target.smooth_path;
    current_idx = target.path_index;
    
    if current_idx >= size(smooth_path, 1)
        target.status = 'Hoàn thành';
        target.vel = [0, 0, 0];
        target.speed = 0;
        return;
    end
    
    % ═══════════════════════════════════════════════════════
    % TÍNH ĐỘ CONG (CURVATURE) TRONG ĐOẠN TIẾP THEO
    % ═══════════════════════════════════════════════════════
    look_ahead = min(10, size(smooth_path, 1) - current_idx);  % Nhìn trước 10 điểm
    
    curvature = 0;
    total_angle = 0;
    total_dist = 0;
    
    if current_idx > 1 && current_idx + look_ahead <= size(smooth_path, 1)
        for k = 0:look_ahead-1
            if current_idx + k < size(smooth_path, 1)
                prev_dir = smooth_path(current_idx+k, :) - smooth_path(max(1, current_idx+k-1), :);
                next_dir = smooth_path(current_idx+k+1, :) - smooth_path(current_idx+k, :);
                
                prev_norm = norm(prev_dir);
                next_norm = norm(next_dir);
                
                if prev_norm > 0 && next_norm > 0
                    % Tính góc giữa 2 vector
                    cos_angle = dot(prev_dir, next_dir) / (prev_norm * next_norm);
                    cos_angle = max(-1, min(1, cos_angle));
                    angle = acos(cos_angle);
                    
                    total_angle = total_angle + angle;
                    total_dist = total_dist + next_norm;
                end
            end
        end
        
        if total_dist > 0
            curvature = total_angle / total_dist;  % rad/m
        end
    end
    
    % ═══════════════════════════════════════════════════════
    % XÁC ĐỊNH TỐC ĐỘ MỤC TIÊU DỰA TRÊN ĐỘ CONG
    % ═══════════════════════════════════════════════════════
    g = 9.81;
    n_max = target.maneuver_ability;
    v_cruise = target.speed_cruise;
    v_min = target.speed_min;
    v_max = target.speed_max;
    
    % ───────────────────────────────────────────────────────
    % NGƯỠNG ĐỘ CONG (ĐÃ ĐIỀU CHỈNH CHO RÕ RÀNG HƠN)
    % ───────────────────────────────────────────────────────
    curvature_straight = 0.00003;   % < 0.00003 rad/m: BAY THẲNG
    curvature_light = 0.0001;       % < 0.0001 rad/m: CONG NHẸ
    curvature_medium = 0.0005;      % < 0.0005 rad/m: CONG VỪA
    % >= 0.0005 rad/m: CONG GẤP
    
    target_speed = v_cruise;  % Mặc định: tốc độ hành trình
    
    if curvature < curvature_straight
        % ══════════════════════════════════════════════════
        % BAY THẲNG → TỐC ĐỘ TỐI ĐA
        % ══════════════════════════════════════════════════
        target_speed = v_max * 0.95;
        
    elseif curvature < curvature_light
        % ══════════════════════════════════════════════════
        % CONG NHẸ → TĂNG TỐC NHẸ
        % ══════════════════════════════════════════════════
        target_speed = v_cruise * 1.1;  % +10%
        
    elseif curvature < curvature_medium
        % ══════════════════════════════════════════════════
        % CONG VỪA → TỐC ĐỘ HÀNH TRÌNH
        % ══════════════════════════════════════════════════
        target_speed = v_cruise * 0.9;  % -10% (giảm nhẹ)
        
    else
        % ══════════════════════════════════════════════════
        % CONG GẤP → GIẢM TỐC MẠNH
        % ══════════════════════════════════════════════════
        % Công thức vật lý: n = v²/(r*g)
        % → v_safe = sqrt(n_max * g * r) = sqrt(n_max * g / curvature)
        
        if curvature > 0.00001  % Tránh chia cho 0
            radius = 1 / curvature;
            v_safe = sqrt(n_max * g * radius);
            
            % Giảm tốc về 60-70% tốc độ an toàn (để thoải mái hơn)
            target_speed = v_safe * 0.65;
            
            % Đảm bảo không giảm quá thấp
            target_speed = max(v_min, target_speed);
            
            % Giới hạn trên không vượt quá 70% v_cruise khi cong gấp
            target_speed = min(target_speed, v_cruise * 0.7);
        else
            target_speed = v_cruise * 0.8;
        end
    end
    
    % Đảm bảo trong giới hạn
    target_speed = max(v_min, min(v_max, target_speed));
    
    % ═══════════════════════════════════════════════════════
    % ĐIỀU CHỈNH TỐC ĐỘ MỀM MẠI (NHƯNG GIẢM TỐC NHANH)
    % ═══════════════════════════════════════════════════════
    speed_diff = target_speed - target.speed;
    max_accel_change = target.accel_max * dt * 4;  % Tăng từ 3 lên 4
    max_decel_change = target.accel_max * dt * 6;  % Giảm tốc nhanh gấp 1.5 lần
    
    if abs(speed_diff) < 3  % Đã gần đạt tốc độ mục tiêu
        target.current_accel = 0;
        target.speed = target_speed;
    else
        % Thay đổi tốc độ dần dần
        if speed_diff > 0
            % TĂNG TỐC
            if speed_diff > max_accel_change
                delta_speed = max_accel_change;
                target.current_accel = target.accel_max;
            else
                delta_speed = speed_diff;
                target.current_accel = delta_speed / dt;
            end
        else
            % GIẢM TỐC (NHANH HƠN)
            if abs(speed_diff) > max_decel_change
                delta_speed = -max_decel_change;
                target.current_accel = -target.accel_max * 2.0;  % Giảm tốc gấp đôi
            else
                delta_speed = speed_diff;
                target.current_accel = delta_speed / dt;
            end
        end
        
        target.speed = target.speed + delta_speed;
        target.speed = max(v_min, min(v_max, target.speed));
    end
    
    % ═══════════════════════════════════════════════════════
    % DI CHUYỂN THEO TỐC ĐỘ ĐÃ XÁC ĐỊNH
    % ═══════════════════════════════════════════════════════
    distance_to_move = target.speed * dt;
    accumulated_dist = 0;
    new_idx = current_idx;
    
    while new_idx < size(smooth_path, 1) && accumulated_dist < distance_to_move
        segment_dist = norm(smooth_path(new_idx+1, :) - smooth_path(new_idx, :));
        
        if accumulated_dist + segment_dist <= distance_to_move
            accumulated_dist = accumulated_dist + segment_dist;
            new_idx = new_idx + 1;
        else
            % Nội suy vị trí
            remaining_dist = distance_to_move - accumulated_dist;
            ratio = remaining_dist / segment_dist;
            
            target.pos = smooth_path(new_idx, :) + ...
                ratio * (smooth_path(new_idx+1, :) - smooth_path(new_idx, :));
            
            new_idx = new_idx + 1;
            break;
        end
    end
    
    % ═══════════════════════════════════════════════════════
    % CẬP NHẬT TRẠNG THÁI
    % ═══════════════════════════════════════════════════════
    if new_idx >= size(smooth_path, 1)
        target.pos = smooth_path(end, :);
        target.status = 'Hoàn thành';
        target.vel = [0, 0, 0];
        target.speed = 0;
    else
        target.path_index = new_idx;
        target.pos = smooth_path(new_idx, :);
        
        % Cập nhật vector vận tốc
        if new_idx < size(smooth_path, 1)
            direction = smooth_path(new_idx+1, :) - smooth_path(new_idx, :);
            direction_norm = norm(direction);
            
            if direction_norm > 0
                target.vel = target.speed * direction / direction_norm;
            else
                target.vel = [0, 0, 0];
            end
        end
    end
    
    % ═══════════════════════════════════════════════════════
    % LƯU QUỸ ĐẠO ĐÃ ĐI QUA (CHỈ 2D)
    % ═══════════════════════════════════════════════════════
    if isempty(target.trajectory_history)
        target.trajectory_history = target.pos(1:2);
    else
        % Chỉ lưu nếu di chuyển đủ xa (tránh lưu quá dày)
        last_pos = target.trajectory_history(end, :);
        if norm(target.pos(1:2) - last_pos) > 50  % Mỗi 50m
            target.trajectory_history = [target.trajectory_history; target.pos(1:2)];
        end
    end
end