function in_zone = Block2_CheckZone(target_pos, SCH_pos, range_min, range_max)
    %% KHỐI 2: KIỂM TRA VỊ TRÍ TRONG VÙNG PHÂN PHỐI
    % Mô tả: Kiểm tra mục tiêu có nằm trong vùng phân phối không (Dб < Dⱼ < Dд)
    % Input:
    %   - target_pos: Vị trí mục tiêu [x, y, z]
    %   - SCH_pos: Vị trí Sở Chỉ Huy (tâm vùng phân phối) [x, y, z]
    %   - range_min: Cự ly gần Dб (m)
    %   - range_max: Cự ly xa Dд (m)
    % Output:
    %   - in_zone: true nếu trong vùng, false nếu ngoài vùng
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % TÍNH KHOẢNG CÁCH TỪ MỤC TIÊU ĐẾN SCH
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % Khoảng cách trong mặt phẳng XY (không tính độ cao)
    dist_2d = norm(target_pos(1:2) - SCH_pos(1:2));
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % KIỂM TRA ĐIỀU KIỆN: Dб < Dⱼ < Dд
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    in_zone = (dist_2d >= range_min) && (dist_2d <= range_max);
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % THÔNG TIN BỔ SUNG (optional, for debugging)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % Trả về cấu trúc chi tiết nếu cần
    if nargout > 1
        zone_info = struct();
        zone_info.distance = dist_2d;
        zone_info.range_min = range_min;
        zone_info.range_max = range_max;
        zone_info.in_zone = in_zone;
        
        if dist_2d < range_min
            zone_info.status = 'Quá gần (< Dб)';
        elseif dist_2d > range_max
            zone_info.status = 'Quá xa (> Dд)';
        else
            zone_info.status = 'Trong vùng phân phối';
        end
        
        varargout{1} = zone_info;
    end
    
end
