function params = Block1_EvaluateMotion(target, dt)
    %% KHỐI 1: ĐÁNH GIÁ TỌA ĐỘ VÀ THAM SỐ CHUYỂN ĐỘNG
    % Mô tả: Đánh giá các tham số x, y, H, vₓ, vᵧ, vₕ, Q (hướng bay)
    % Input:
    %   - target: Cấu trúc mục tiêu
    %   - dt: Bước thời gian
    % Output:
    %   - params: Cấu trúc chứa các tham số chuyển động
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % TỌA ĐỘ KHÔNG GIAN (x, y, H)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    params.x = target.pos(1);        % Tọa độ X (m)
    params.y = target.pos(2);        % Tọa độ Y (m)
    params.H = target.pos(3);        % Độ cao H (m)
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % VẬN TỐC (vₓ, vᵧ, vₕ)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    params.vx = target.vel(1);       % Vận tốc theo X (m/s)
    params.vy = target.vel(2);       % Vận tốc theo Y (m/s)
    params.vh = target.vel(3);       % Vận tốc theo H (m/s)
    
    % Vận tốc tổng hợp
    params.v_total = norm(target.vel);
    
    % Vận tốc ngang (trong mặt phẳng XY)
    params.v_horizontal = norm(target.vel(1:2));
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % HƯỚNG BAY Q (Course angle)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % Q được tính từ hướng Bắc (Y axis), quay theo chiều kim đồng hồ
    % Q = atan2(vₓ, vᵧ) - góc từ trục Y dương
    
    if params.v_horizontal > 0
        % Góc hướng bay (rad)
        params.Q = atan2(params.vx, params.vy);
        
        % Chuyển về độ để dễ đọc
        params.Q_deg = rad2deg(params.Q);
    else
        % Mục tiêu đứng yên
        params.Q = 0;
        params.Q_deg = 0;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % GÓC NGHIÊNG (Pitch angle)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if params.v_total > 0
        params.pitch = asin(params.vh / params.v_total);
        params.pitch_deg = rad2deg(params.pitch);
    else
        params.pitch = 0;
        params.pitch_deg = 0;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CÁC THAM SỐ BỔ SUNG
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    params.RCS = target.RCS;                     % Diện tích phản xạ radar
    params.maneuver_ability = target.maneuver_ability;  % Khả năng cơ động (G)
    params.type = target.type;                   % Loại mục tiêu
    params.status = target.status;               % Trạng thái
    
end
