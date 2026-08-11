function mission_text = predictMission(target, SCH, targets_protect, fire_units)
    %% DỰ ĐOÁN NHIỆM VỤ CỦA MỤC TIÊU
    % Dựa trên đặc trưng chiến thuật thực tế
    %
    % Output: Chuỗi mô tả nhiệm vụ
    
    % =======================================================
    % BƯỚC 1: THU THẬP DỮ LIỆU MỤC TIÊU
    % =======================================================
    
    % Nhận dạng loại
    [target_type, ~, ~] = classifyTarget(target);
    
    % Thông số bay
    current_speed = target.speed;
    speed_cruise = target.speed_cruise;
    altitude = target.pos(3);
    
    % Vector hướng bay
    if norm(target.vel) > 0
        direction = target.vel / norm(target.vel);
    else
        direction = [1, 0, 0];
    end

    % Khả năng cơ động
    n_max = target.maneuver_ability;
    
    % Gây nhiễu
    has_jamming = strcmp(target.jam_type, 'Chủ động') || strcmp(target.jam_type, 'Thụ động');
    
    % =======================================================
    % BƯỚC 2: TÍNH KHOẢNG CÁCH VÀ GÓC ĐẾN CÁC ĐỐI TƯỢNG
    % =======================================================
    
    % Đến SCH
    dir_to_sch = SCH.pos - target.pos;
    dist_to_sch = norm(dir_to_sch(1:2));
    if dist_to_sch > 0
        angle_to_sch = acosd(dot(direction, dir_to_sch / norm(dir_to_sch)));
    else
        angle_to_sch = 180;
    end
    
    % Đến mục tiêu bảo vệ gần nhất
    min_angle_to_protect = 180;
    min_dist_to_protect = inf;
    for i = 1:length(targets_protect)
        dir = targets_protect(i).pos - target.pos;
        dist = norm(dir(1:2));
        if dist > 0
            angle = acosd(dot(direction, dir / norm(dir)));
            if angle < min_angle_to_protect
                min_angle_to_protect = angle;
                min_dist_to_protect = dist;
            end
        end
    end
    
    % Đến đơn vị hỏa lực gần nhất
    min_angle_to_fire = 180;
    min_dist_to_fire = inf;
    for i = 1:length(fire_units)
        dir = fire_units(i).pos - target.pos;
        dist = norm(dir(1:2));
        if dist > 0
            angle = acosd(dot(direction, dir / norm(dir)));
            if angle < min_angle_to_fire
                min_angle_to_fire = angle;
                min_dist_to_fire = dist;
            end
        end
    end
    
    % =======================================================
    % BƯỚC 3: DỰ ĐOÁN NHIỆM VỤ THEO ĐẶC TRƯNG CHIẾN THUẬT
    % =======================================================
    
    % -------------------------------------------------------
    % NHIỆM VỤ 1: CHẾ ÁP HỎA LỰC/SCH (Đội hình đầu)
    % Đặc trưng:
    %   - Tiêm kích chiến thuật
    %   - Bay THẤP (< 5000m) - Tránh radar
    %   - Có gây nhiễu hoặc cơ động cao
    %   - Hướng thẳng vào SCH/ĐVHL
    %   - Khoảng cách gần
    % -------------------------------------------------------
    if (contains(target_type, 'Tiêm kích') || contains(target_type, 'Tên lửa'))
        % Điều kiện: Bay thấp + hướng vào SCH/hỏa lực
        if altitude < 5000 && (angle_to_sch < 45 || min_angle_to_fire < 45)
            if has_jamming
                mission_text = 'Chế áp PK (có nhiễu)';
            elseif n_max >= 7
                mission_text = 'Chế áp PK (cơ động cao)';
            else
                mission_text = 'Chế áp phòng không';
            end
            return;
        end
        
        % Điều kiện: Bay thẳng vào (bất kể độ cao)
        if angle_to_sch < 30 || min_angle_to_fire < 30
            mission_text = 'Chế áp phòng không';
            return;
        end
        
        % Điều kiện: Gần SCH/hỏa lực (< 15km) và đang tiến gần
        if (dist_to_sch < 15000 || min_dist_to_fire < 15000) && ...
           (angle_to_sch < 60 || min_angle_to_fire < 60)
            mission_text = 'Chế áp PK (dự kiến)';
            return;
        end
    end
    
    % -------------------------------------------------------
    % NHIỆM VỤ 2: TIÊU DIỆT HẬU PHƯƠNG (Đội hình sau)
    % Đặc trưng:
    %   - Máy bay ném bom
    %   - Bay cao/trung bình
    %   - Hướng đến mục tiêu bảo vệ
    %   - Vận tốc ổn định
    % -------------------------------------------------------
    if contains(target_type, 'MB ném bom') || contains(target_type, 'ném bom')
        % Điều kiện: Hướng thẳng vào MTBV
        if min_angle_to_protect < 30
            mission_text = 'Tiêu diệt hậu phương';
            return;
        end
        
        % Điều kiện: Gần MTBV và đang tiến gần
        if min_angle_to_protect < 60 && min_dist_to_protect < 30000
            mission_text = 'Tiêu diệt hậu phương (dự kiến)';
            return;
        end
        
        % Mặc định cho MB ném bom
        mission_text = 'Ném bom chiến lược';
        return;
    end
    
    % -------------------------------------------------------
    % NHIỆM VỤ 3: TRINH SÁT MẶT ĐẤT
    % Đặc trưng:
    %   - Bay CAO (> 15km)
    %   - Vận tốc ổn định (90-110% cruise)
    %   - Không hướng cụ thể
    % -------------------------------------------------------
    if altitude > 15000
        speed_ratio = current_speed / speed_cruise;
        if speed_ratio > 0.9 && speed_ratio < 1.1
            mission_text = 'Trinh sát mặt đất';
            return;
        end
    end
    
    % -------------------------------------------------------
    % NHIỆM VỤ 4: YỂM TRỢ TÁC CHIẾN
    % Đặc trưng:
    %   - Vận tốc THẤP (< 80% cruise)
    %   - Đang chờ đợi hoặc tuần tra
    % -------------------------------------------------------
    if current_speed < speed_cruise * 0.8
        mission_text = 'Yểm trợ tác chiến';
        return;
    end
    
    % -------------------------------------------------------
    % NHIỆM VỤ 5: GÂY NHIỄU / PHÂN TÁN
    % Đặc trưng:
    %   - Có gây nhiễu chủ động
    %   - Bay quanh vùng
    % -------------------------------------------------------
    if strcmp(target.jam_type, 'Chủ động')
        mission_text = 'Gây nhiễu/Phân tán';
        return;
    end
    
    % -------------------------------------------------------
    % NHIỆM VỤ MẶC ĐỊNH: TẤN CÔNG
    % -------------------------------------------------------
    if contains(target_type, 'Tiêm kích') || contains(target_type, 'Tên lửa')
        mission_text = 'Tấn công';
    else
        mission_text = 'Khác';
    end
end