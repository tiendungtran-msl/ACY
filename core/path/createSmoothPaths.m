function targets = createSmoothPaths(targets)
    %% TẠO ĐƯỜNG CONG MƯỢT 3D VỚI GIỚI HẠN PHÙ HỢP KHẢ NĂNG CƠ ĐỘNG
    
    for i = 1:length(targets)
        wp = targets(i).waypoints;  % Nx3 matrix
        n_wp = size(wp, 1);
        
        if size(wp, 2) ~= 3
            error('Waypoints phải là ma trận Nx3 [x, y, z]');
        end
        
        % Lấy thông số cơ động
        min_radius = targets(i).min_turn_radius;
        n_max = targets(i).maneuver_ability;
        
        % ═══════════════════════════════════════════════════════
        % THÊM TÍNH NGẪU NHIÊN VỚI GIỚI HẠN PHÙ HỢP
        % ═══════════════════════════════════════════════════════
        wp_modified = wp;
        
        % Xác suất thay đổi waypoint dựa trên khả năng cơ động
        if n_max >= 6
            random_prob = 0.5;  % Tiêm kích: 50% (cơ động cao)
        elseif n_max >= 4
            random_prob = 0.35; % Tiêm kích ném bom: 35%
        else
            random_prob = 0.15; % B52, Tên lửa: 15% (ít thay đổi)
        end
        
        for j = 2:n_wp-1
            if rand() < random_prob
                % Tính khoảng cách giữa waypoint trước và sau
                segment_length = norm(wp(j+1, :) - wp(j-1, :));
                
                % ══════════════════════════════════════════════
                % ĐỘ LỆCH TỐI ĐA PHỤ THUỘC VÀO min_turn_radius
                % ══════════════════════════════════════════════
                % Công thức: max_deviation ≈ min_turn_radius * 0.5
                % (đảm bảo đường cong không quá gấp)
                
                max_lateral_deviation = min(min_radius * 0.4, segment_length * 0.3);
                
                % Tạo độ lệch ngẫu nhiên
                offset_x = (rand() - 0.5) * 2 * max_lateral_deviation;
                offset_y = (rand() - 0.5) * 2 * max_lateral_deviation;
                offset_z = (rand() - 0.5) * max_lateral_deviation * 0.2;
                
                % Kiểm tra xem điểm mới có tạo góc quẹo quá gấp không
                new_point = wp(j, :) + [offset_x, offset_y, offset_z];
                
                % Tính bán kính cong ước lượng
                v1 = wp(j, :) - wp(j-1, :);
                v2 = new_point - wp(j, :);
                v3 = wp(j+1, :) - new_point;
                
                % Nếu các vector hợp lý, chấp nhận điểm mới
                if norm(v2) > min_radius * 0.1  % Không quá gần
                    wp_modified(j, :) = new_point;
                    
                    fprintf('    [%s] WP %d/%d lệch: %.0fm (max: %.0fm)\n', ...
                        targets(i).name, j, n_wp, norm([offset_x, offset_y]), max_lateral_deviation);
                end
            end
        end
        
        % ═══════════════════════════════════════════════════════
        % KHÔNG THÊM ĐIỂM PHỤ CHO MÁY BAY KÉM CƠ ĐỘNG
        % ═══════════════════════════════════════════════════════
        if n_max >= 6 && rand() < 0.2  % Chỉ tiêm kích mới thêm điểm
            insert_idx = randi([2, n_wp-1]);
            midpoint = (wp_modified(insert_idx, :) + wp_modified(insert_idx+1, :)) / 2;
            
            % Thêm nhiễu nhỏ
            segment_len = norm(wp_modified(insert_idx+1, :) - wp_modified(insert_idx, :));
            max_offset = min(min_radius * 0.2, segment_len * 0.2);
            offset = [(rand()-0.5)*max_offset, (rand()-0.5)*max_offset, (rand()-0.5)*max_offset*0.3];
            midpoint = midpoint + offset;
            
            % Chèn điểm mới
            wp_modified = [wp_modified(1:insert_idx, :); 
                          midpoint; 
                          wp_modified(insert_idx+1:end, :)];
            n_wp = n_wp + 1;
            
            fprintf('    [%s] Thêm điểm phụ tại đoạn %d\n', targets(i).name, insert_idx);
        end
        
        % ═══════════════════════════════════════════════════════
        % TÍNH THAM SỐ t (CUMULATIVE DISTANCE 3D)
        % ═══════════════════════════════════════════════════════
        t_wp = zeros(n_wp, 1);
        for j = 2:n_wp
            t_wp(j) = t_wp(j-1) + norm(wp_modified(j,:) - wp_modified(j-1,:));
        end
        
        if t_wp(end) > 0
            t_wp = t_wp / t_wp(end);
        end
        
        % ═══════════════════════════════════════════════════════
        % TÍNH SỐ ĐIỂM NỘI SUY
        % ═══════════════════════════════════════════════════════
        total_dist = 0;
        for j = 2:n_wp
            total_dist = total_dist + norm(wp_modified(j,:) - wp_modified(j-1,:));
        end
        
        % Điểm nội suy dày hơn cho máy bay cơ động cao
        if n_max >= 6
            point_spacing = 80;   % 80m/điểm (tiêm kích)
        elseif n_max >= 4
            point_spacing = 100;  % 100m/điểm
        else
            point_spacing = 150;  % 150m/điểm (B52, tên lửa)
        end
        
        n_points = max(100, ceil(total_dist / point_spacing));
        t_smooth = linspace(0, 1, n_points);
        
        % ═══════════════════════════════════════════════════════
        % SPLINE INTERPOLATION (PCHIP cho smooth, tránh overshoot)
        % ═══════════════════════════════════════════════════════
        if n_wp >= 3
            smooth_x = pchip(t_wp, wp_modified(:,1), t_smooth);
            smooth_y = pchip(t_wp, wp_modified(:,2), t_smooth);
            smooth_z = pchip(t_wp, wp_modified(:,3), t_smooth);
        else
            smooth_x = interp1(t_wp, wp_modified(:,1), t_smooth, 'linear');
            smooth_y = interp1(t_wp, wp_modified(:,2), t_smooth, 'linear');
            smooth_z = interp1(t_wp, wp_modified(:,3), t_smooth, 'linear');
        end
        
        % ═══════════════════════════════════════════════════════
        % KIỂM TRA VÀ ĐIỀU CHỈNH ĐỘ CONG (POST-PROCESSING)
        % ═══════════════════════════════════════════════════════
        smooth_path_raw = [smooth_x', smooth_y', smooth_z'];
        smooth_path_adjusted = adjustCurvatureConstraints(smooth_path_raw, min_radius, n_max);
        
        % Lưu đường cong 3D
        targets(i).smooth_path = smooth_path_adjusted;
        targets(i).pos = targets(i).smooth_path(1,:);
        targets(i).trajectory_history = targets(i).pos(1:2);
        
        fprintf('  ✓ %s: %d WP → %d điểm, R_min=%.1fkm, n_max=%.1fG\n', ...
                targets(i).name, n_wp, n_points, min_radius/1000, n_max);
    end
end

function path_out = adjustCurvatureConstraints(path_in, min_radius, n_max)
    %% ĐIỀU CHỈNH ĐƯỜNG BAY ĐỂ KHÔNG VI PHẠM GIỚI HẠN CƠ ĐỘNG
    % Làm mịn các đoạn có độ cong quá lớn
    
    path_out = path_in;
    n_points = size(path_in, 1);
    g = 9.81;
    
    % Duyệt qua từng điểm
    for i = 2:n_points-1
        v1 = path_in(i, :) - path_in(i-1, :);
        v2 = path_in(i+1, :) - path_in(i, :);
        
        d1 = norm(v1);
        d2 = norm(v2);
        
        if d1 > 0 && d2 > 0
            % Tính góc giữa 2 vector
            cos_angle = dot(v1, v2) / (d1 * d2);
            cos_angle = max(-1, min(1, cos_angle));
            angle = acos(cos_angle);
            
            % Ước lượng bán kính cong
            avg_dist = (d1 + d2) / 2;
            if angle > 0.01  % Tránh chia cho 0
                estimated_radius = avg_dist / (2 * sin(angle/2));
                
                % Nếu bán kính nhỏ hơn min_radius → làm mịn
                if estimated_radius < min_radius
                    % Tính điểm trung gian mới (làm mịn góc)
                    smooth_factor = min_radius / estimated_radius;
                    smooth_factor = min(smooth_factor, 2);  % Không làm mịn quá
                    
                    % Điều chỉnh điểm i về phía trung điểm
                    midpoint = (path_in(i-1, :) + path_in(i+1, :)) / 2;
                    path_out(i, :) = path_in(i, :) * (2 - smooth_factor) / 2 + ...
                                     midpoint * smooth_factor / 2;
                end
            end
        end
    end
end