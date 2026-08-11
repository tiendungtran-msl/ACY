function future_pos = PredictTrajectory(target, time_ahead, model)
    %% DỰ BÁO QUỸ ĐẠO MỤC TIÊU
    % Mô tả: Dự báo vị trí tương lai của mục tiêu
    % Input:
    %   - target: Cấu trúc mục tiêu
    %   - time_ahead: Thời gian dự báo (s)
    %   - model: Mô hình dự báo ('linear', 'polynomial', 'uniform')
    % Output:
    %   - future_pos: Vị trí dự báo [x, y, z]
    
    if nargin < 3
        model = 'linear';
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % MÔ HÌNH TUYẾN TÍNH (ĐƠN GIẢN)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if strcmp(model, 'linear')
        % Giả định vận tốc không đổi
        future_pos = target.pos + target.vel * time_ahead;
        return;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % MÔ HÌNH ĐA THỨC (POLYNOMIAL)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if strcmp(model, 'polynomial')
        % Sử dụng waypoints để fit polynomial
        if isfield(target, 'smooth_path') && ~isempty(target.smooth_path)
            % Có smooth path, dự báo theo đường cong
            path_len = size(target.smooth_path, 1);
            current_idx = target.path_index;
            
            if current_idx < path_len
                % Ước lượng vận tốc trung bình
                avg_speed = norm(target.vel);
                if avg_speed > 0
                    points_ahead = round(time_ahead * avg_speed / 1000);
                    next_idx = min(current_idx + points_ahead, path_len);
                    future_pos = target.smooth_path(next_idx, :);
                else
                    future_pos = target.pos;
                end
            else
                future_pos = target.pos;
            end
        else
            % Fallback to linear
            future_pos = target.pos + target.vel * time_ahead;
        end
        return;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % MÔ HÌNH PHÂN BỐ ĐỀU/CHUẨN
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if strcmp(model, 'uniform')
        % Thêm nhiễu phân bố đều
        noise_range = 100;  % ±100m
        noise = (rand(1, 3) - 0.5) * 2 * noise_range;
        future_pos = target.pos + target.vel * time_ahead + noise;
        return;
    end
    
    % Default: linear model
    future_pos = target.pos + target.vel * time_ahead;
    
end
