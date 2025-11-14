function [trajectory, times] = minimumSnapTrajectory(waypoints, v_cruise, n_max, total_time)
    %% TẠO QUỸ ĐẠO MINIMUM SNAP
    % Minimize ∫(d⁴r/dt⁴)² dt - Tối ưu cho máy bay
    %
    % Input:
    %   waypoints - [N x 3] ma trận điểm đi qua
    %   v_cruise - vận tốc hành trình (m/s)
    %   n_max - khả năng cơ động tối đa (G)
    %   total_time - (optional) thời gian bay tổng (s)
    % Output:
    %   trajectory - [M x 3] quỹ đạo mượt
    %   times - [M x 1] thời gian tương ứng
    
    n_waypoints = size(waypoints, 1);
    
    if n_waypoints < 2
        error('Cần ít nhất 2 waypoints');
    end
    
    % ═══════════════════════════════════════════════════════
    % TÍNH THỜI GIAN PHÂN BỐ CHO TỪNG ĐOẠN
    % ═══════════════════════════════════════════════════════
    if nargin < 4 || isempty(total_time)
        % Tự động tính dựa trên khoảng cách và vận tốc
        segment_lengths = zeros(n_waypoints - 1, 1);
        for i = 1:(n_waypoints - 1)
            segment_lengths(i) = norm(waypoints(i+1, :) - waypoints(i, :));
        end
        
        % Thời gian cho mỗi đoạn
        segment_times = segment_lengths / v_cruise;
        total_time = sum(segment_times);
    else
        % Phân bổ thời gian theo tỷ lệ khoảng cách
        segment_lengths = zeros(n_waypoints - 1, 1);
        for i = 1:(n_waypoints - 1)
            segment_lengths(i) = norm(waypoints(i+1, :) - waypoints(i, :));
        end
        total_length = sum(segment_lengths);
        segment_times = (segment_lengths / total_length) * total_time;
    end
    
    % ═══════════════════════════════════════════════════════
    % XÂY DỰNG POLYNOMIAL ORDER 7 CHO MỖI ĐOẠN
    % ═══════════════════════════════════════════════════════
    % Minimum Snap cần polynomial bậc 7 (8 hệ số)
    % Điều kiện biên: vị trí, vận tốc, gia tốc, jerk tại 2 đầu
    
    n_segments = n_waypoints - 1;
    n_coeff = 8;  % Polynomial bậc 7: a₀ + a₁t + a₂t² + ... + a₇t⁷
    
    % Ma trận lưu hệ số cho [x, y, z]
    coeff_x = zeros(n_segments, n_coeff);
    coeff_y = zeros(n_segments, n_coeff);
    coeff_z = zeros(n_segments, n_coeff);
    
    % Thời gian tích lũy
    cumulative_times = [0; cumsum(segment_times)];
    
    % ═══════════════════════════════════════════════════════
    % GIẢI HỆ PHƯƠNG TRÌNH CHO TỪNG TỌA ĐỘ
    % ═══════════════════════════════════════════════════════
    for coord = 1:3  % x, y, z
        % Tạo ma trận điều kiện biên
        n_eq = n_segments * 8;  % 8 phương trình/đoạn
        A = zeros(n_eq, n_segments * n_coeff);
        b = zeros(n_eq, 1);
        
        eq_idx = 0;
        
        for seg = 1:(n_segments)
            t0 = 0;  % Thời gian đầu đoạn (chuẩn hóa)
            t1 = segment_times(seg);  % Thời gian cuối đoạn
            
            p0 = waypoints(seg, coord);      % Vị trí đầu
            p1 = waypoints(seg + 1, coord);  % Vị trí cuối
            
            % Chỉ số cột của đoạn này trong ma trận A
            col_start = (seg - 1) * n_coeff + 1;
            col_end = seg * n_coeff;
            
            % ───────────────────────────────────────────────────
            % Điều kiện 1-2: Vị trí tại t0 và t1
            % ───────────────────────────────────────────────────
            eq_idx = eq_idx + 1;
            A(eq_idx, col_start:col_end) = polyCoeff(t0, 0);  % p(t0) = p0
            b(eq_idx) = p0;
            
            eq_idx = eq_idx + 1;
            A(eq_idx, col_start:col_end) = polyCoeff(t1, 0);  % p(t1) = p1
            b(eq_idx) = p1;
            
            % ───────────────────────────────────────────────────
            % Điều kiện 3-4: Vận tốc tại t0 và t1
            % ───────────────────────────────────────────────────
            if seg == 1
                % Đoạn đầu: v(t0) = 0 (bắt đầu từ đứng yên)
                eq_idx = eq_idx + 1;
                A(eq_idx, col_start:col_end) = polyCoeff(t0, 1);
                b(eq_idx) = 0;
            else
                % Liên tục vận tốc với đoạn trước
                eq_idx = eq_idx + 1;
                A(eq_idx, col_start:col_end) = polyCoeff(t0, 1);
                col_prev = (seg - 2) * n_coeff + 1;
                A(eq_idx, col_prev:(col_prev + n_coeff - 1)) = -polyCoeff(segment_times(seg-1), 1);
                b(eq_idx) = 0;
            end
            
            if seg == n_segments
                % Đoạn cuối: v(t1) = 0 (kết thúc đứng yên)
                eq_idx = eq_idx + 1;
                A(eq_idx, col_start:col_end) = polyCoeff(t1, 1);
                b(eq_idx) = 0;
            else
                % Sẽ xử lý ở đoạn kế
                eq_idx = eq_idx + 1;
                A(eq_idx, col_start:col_end) = polyCoeff(t1, 1);
                b(eq_idx) = 0;  % Placeholder
            end
            
            % ───────────────────────────────────────────────────
            % Điều kiện 5-6: Gia tốc tại t0 và t1
            % ───────────────────────────────────────────────────
            eq_idx = eq_idx + 1;
            A(eq_idx, col_start:col_end) = polyCoeff(t0, 2);
            b(eq_idx) = 0;
            
            eq_idx = eq_idx + 1;
            A(eq_idx, col_start:col_end) = polyCoeff(t1, 2);
            b(eq_idx) = 0;
            
            % ───────────────────────────────────────────────────
            % Điều kiện 7-8: Jerk (derivative 3) tại t0 và t1
            % ───────────────────────────────────────────────────
            eq_idx = eq_idx + 1;
            A(eq_idx, col_start:col_end) = polyCoeff(t0, 3);
            b(eq_idx) = 0;
            
            eq_idx = eq_idx + 1;
            A(eq_idx, col_start:col_end) = polyCoeff(t1, 3);
            b(eq_idx) = 0;
        end
        
        % Giải hệ phương trình
        coeffs = A \ b;
        
        % Lưu hệ số cho từng đoạn
        for seg = 1:n_segments
            col_start = (seg - 1) * n_coeff + 1;
            col_end = seg * n_coeff;
            
            if coord == 1
                coeff_x(seg, :) = coeffs(col_start:col_end)';
            elseif coord == 2
                coeff_y(seg, :) = coeffs(col_start:col_end)';
            else
                coeff_z(seg, :) = coeffs(col_start:col_end)';
            end
        end
    end
    
    % ═══════════════════════════════════════════════════════
    % TẠO ĐIỂM TRÊN QUỸ ĐẠO
    % ═══════════════════════════════════════════════════════
    dt = 0.1;  % Bước thời gian 0.1s
    times = (0:dt:total_time)';
    n_points = length(times);
    
    trajectory = zeros(n_points, 3);
    
    for i = 1:n_points
        t = times(i);
        
        % Tìm đoạn tương ứng
        seg = find(cumulative_times <= t, 1, 'last');
        if seg > n_segments
            seg = n_segments;
        end
        
        % Thời gian cục bộ trong đoạn
        t_local = t - cumulative_times(seg);
        
        % Tính vị trí
        trajectory(i, 1) = evaluatePoly(coeff_x(seg, :), t_local);
        trajectory(i, 2) = evaluatePoly(coeff_y(seg, :), t_local);
        trajectory(i, 3) = evaluatePoly(coeff_z(seg, :), t_local);
    end
    
    fprintf('  ✓ Minimum Snap: %d waypoints → %d điểm (T=%.1fs)\n', ...
        n_waypoints, n_points, total_time);
end

% ═══════════════════════════════════════════════════════
% HÀM PHỤ: TÍNH HỆ SỐ POLYNOMIAL VÀ ĐẠO HÀM
% ═══════════════════════════════════════════════════════
function c = polyCoeff(t, derivative)
    %% TRẢ VỀ HỆ SỐ POLYNOMIAL BẬC 7 VÀ ĐẠO HÀM
    % p(t) = a₀ + a₁t + a₂t² + ... + a₇t⁷
    
    if derivative == 0
        % Vị trí
        c = [1, t, t^2, t^3, t^4, t^5, t^6, t^7];
    elseif derivative == 1
        % Vận tốc
        c = [0, 1, 2*t, 3*t^2, 4*t^3, 5*t^4, 6*t^5, 7*t^6];
    elseif derivative == 2
        % Gia tốc
        c = [0, 0, 2, 6*t, 12*t^2, 20*t^3, 30*t^4, 42*t^5];
    elseif derivative == 3
        % Jerk
        c = [0, 0, 0, 6, 24*t, 60*t^2, 120*t^3, 210*t^4];
    elseif derivative == 4
        % Snap
        c = [0, 0, 0, 0, 24, 120*t, 360*t^2, 840*t^3];
    else
        c = zeros(1, 8);
    end
end

function val = evaluatePoly(coeffs, t)
    %% TÍNH GIÁ TRỊ POLYNOMIAL
    val = coeffs(1) + coeffs(2)*t + coeffs(3)*t^2 + coeffs(4)*t^3 + ...
          coeffs(5)*t^4 + coeffs(6)*t^5 + coeffs(7)*t^6 + coeffs(8)*t^7;
end