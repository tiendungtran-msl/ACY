function [pij, tauij] = CalculateCourseParams(target, protected_obj, fire_unit)
    %% KHỐI 4'-5': TÍNH THAM SỐ KHÔNG-THỜI GIAN
    % Mô tả: Tính pᵢⱼ (tham số hướng bay) và τᵢⱼ (thời gian tiếp cận)
    % Input:
    %   - target: Cấu trúc mục tiêu j
    %   - protected_obj: Đối tượng bảo vệ i (hoặc SCH)
    %   - fire_unit: Đơn vị hỏa lực (optional, cho tính toán τᵢⱼ)
    % Output:
    %   - pij: Tham số hướng bay (m)
    %   - tauij: Thời gian tiếp cận (s)
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % TRÍCH XUẤT TỌA ĐỘ
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    xj = target.pos(1);
    yj = target.pos(2);
    
    xi = protected_obj.pos(1);
    yi = protected_obj.pos(2);
    
    % Hướng bay Qⱼ (course angle)
    vx = target.vel(1);
    vy = target.vel(2);
    vj = norm([vx, vy]);
    
    if vj > 0
        Qj = atan2(vx, vy);  % Góc từ trục Y (North)
    else
        Qj = 0;
        pij = norm([xi - xj, yi - yj]);
        tauij = inf;
        return;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CÔNG THỨC 1: TÍNH pᵢⱼ (Tham số hướng bay)
    % pᵢⱼ = |(xᵢ - xⱼ)·sin(Qⱼ) - (yᵢ - yⱼ)·cos(Qⱼ)|
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    pij = abs((xi - xj) * sin(Qj) - (yi - yj) * cos(Qj));
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CÔNG THỨC 2: TÍNH τᵢⱼ (Thời gian tiếp cận)
    % τᵢⱼ = (√[(xᵢ* - xⱼ)² + (yᵢ* - yⱼ)²] - √[rᵢ² - pᵢⱼ²]) / vⱼ
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % Khoảng cách hiện tại đến đối tượng bảo vệ
    dist_to_obj = norm([xi - xj, yi - yj]);
    
    % Bán kính bảo vệ (nếu có fire_unit)
    if nargin >= 3 && ~isempty(fire_unit)
        ri = fire_unit.range_max;  % Vùng tiêu diệt
    else
        ri = 0;  % Không có vùng bảo vệ
    end
    
    % Dự báo điểm giao cắt (xᵢ*, yᵢ*)
    % Giả định đối tượng bảo vệ đứng yên
    xi_star = xi;
    yi_star = yi;
    
    dist_to_predicted = norm([xi_star - xj, yi_star - yj]);
    
    % Tính thời gian tiếp cận
    if pij <= ri
        % Mục tiêu sẽ đi vào vùng bảo vệ
        term1 = dist_to_predicted;
        term2_squared = ri^2 - pij^2;
        
        if term2_squared >= 0
            term2 = sqrt(term2_squared);
            tauij = (term1 - term2) / vj;
        else
            % Không giao với vùng bảo vệ
            tauij = inf;
        end
    else
        % Mục tiêu không đi qua vùng bảo vệ
        % Tính thời gian đến điểm gần nhất
        
        % Vector từ mục tiêu đến đối tượng
        dx = xi - xj;
        dy = yi - yj;
        
        % Chiếu lên hướng vận tốc
        dot_product = dx * vx + dy * vy;
        
        if dot_product > 0
            % Đang tiến lại gần
            tauij = pij / vj;  % Thời gian đến điểm gần nhất
        else
            % Đang bay ra xa
            tauij = inf;
        end
    end
    
    % Đảm bảo τᵢⱼ không âm
    if tauij < 0
        tauij = 0;
    end
    
end
