function is_maneuvering = DetectManeuver(target, threshold)
    %% PHÁT HIỆN CƠ ĐỘNG MỤC TIÊU
    % Mô tả: Phát hiện mục tiêu có đang cơ động không
    % Input:
    %   - target: Cấu trúc mục tiêu
    %   - threshold: Ngưỡng phát hiện cơ động (G)
    % Output:
    %   - is_maneuvering: true nếu đang cơ động
    
    if nargin < 2
        threshold = 2.0;  % 2G
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % KIỂM TRA KHẢ NĂNG CƠ ĐỘNG
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % Nếu khả năng cơ động cao
    if target.maneuver_ability > threshold
        is_maneuvering = true;
    else
        is_maneuvering = false;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % PHÁT HIỆN QUA THAY ĐỔI VẬN TỐC (nếu có lịch sử)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if isfield(target, 'vel_history') && length(target.vel_history) >= 2
        % Tính gia tốc gần đúng
        vel_prev = target.vel_history(end-1, :);
        vel_curr = target.vel;
        dt = 1.0;  % Giả định 1 giây
        
        acc = norm(vel_curr - vel_prev) / dt;
        
        % Chuyển sang G (1G ≈ 9.81 m/s²)
        acc_g = acc / 9.81;
        
        if acc_g > threshold
            is_maneuvering = true;
        end
    end
    
end
