function in_zone = isTargetInObservationZone(target, SCH, observation_radius)
    %% KIỂM TRA MỤC TIÊU CÓ TRONG VÙNG QUAN SÁT HAY KHÔNG
    % Input:
    %   target - struct mục tiêu
    %   SCH - struct SCH
    %   observation_radius - bán kính vùng quan sát (m)
    % Output:
    %   in_zone - true/false
    
    % Tính khoảng cách 2D (bỏ qua độ cao)
    dist_2d = norm(target.pos(1:2) - SCH.pos(1:2));
    
    % Kiểm tra
    in_zone = (dist_2d <= observation_radius);
end