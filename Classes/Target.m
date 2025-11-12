classdef Target < handle
    %% CLASS MỤC TIÊU (TARGET)
    % Mô tả: Class quản lý thông tin và hành vi của mục tiêu
    
    properties
        % NHÓM 1: THÔNG TIN ĐỊNH DANH
        id                      % ID mục tiêu
        name                    % Tên mục tiêu
        type                    % Loại mục tiêu
        
        % NHÓM 2: TỌA ĐỘ VÀ THAM SỐ CHUYỂN ĐỘNG
        pos                     % Vị trí [x, y, H] (m)
        vel                     % Vận tốc [vx, vy, vh] (m/s)
        speed                   % Tốc độ (m/s)
        H                       % Độ cao (m)
        waypoints               % Các điểm mốc
        smooth_path             % Đường đi mượt
        path_index              % Chỉ số trên đường đi
        
        % NHÓM 3: ĐẶC TRƯNG VÀ DẤU HIỆU
        RCS                     % Diện tích phản xạ radar (m²)
        maneuver_ability        % Khả năng cơ động (G)
        jam_type                % Loại gây nhiễu
        task                    % Nhiệm vụ
        group_size              % Số lượng thành phần nhóm
        
        % NHÓM 4: THAM SỐ ĐÁNH GIÁ
        priority_from_command   % Có chỉ thị cấp trên không
        status                  % Trạng thái
        Bj                      % Mức độ quan trọng
        
        % NHÓM 5: VISUALIZATION
        color                   % Màu sắc
        marker                  % Ký hiệu
    end
    
    methods
        function obj = Target(id, name, type, speed, H, RCS, maneuver, ...
                            task, jam_type, group_size, waypoints, color, marker)
            %% CONSTRUCTOR
            if nargin > 0
                obj.id = id;
                obj.name = name;
                obj.type = type;
                obj.speed = speed;
                obj.H = H;
                obj.RCS = RCS;
                obj.maneuver_ability = maneuver;
                obj.task = task;
                obj.jam_type = jam_type;
                obj.group_size = group_size;
                obj.waypoints = waypoints;
                obj.color = color;
                obj.marker = marker;
                
                % Khởi tạo vị trí ban đầu
                obj.pos = [waypoints(1,:), H];
                obj.vel = [0, 0, 0];
                obj.smooth_path = [];
                obj.path_index = 1;
                obj.priority_from_command = false;
                obj.status = 'Đang bay';
                obj.Bj = 0;
            end
        end
        
        function updateMotion(obj, dt)
            %% CẬP NHẬT CHUYỂN ĐỘNG
            % Cập nhật vị trí theo vận tốc
            obj.pos = obj.pos + obj.vel * dt;
        end
        
        function params = getMotionParams(obj)
            %% LẤY THAM SỐ CHUYỂN ĐỘNG (KHỐI 1)
            params = Block1_EvaluateMotion(struct(obj), 1);
        end
        
        function category = recognizeType(obj, targetDB)
            %% NHẬN DẠNG LOẠI (KHỐI 4)
            result = Block4_RecognizeType(struct(obj), targetDB);
            category = result.category;
        end
        
        function s = toStruct(obj)
            %% CHUYỂN ĐỔI SANG STRUCT
            % Để tương thích với code hiện có
            s = struct( ...
                'id', obj.id, ...
                'name', obj.name, ...
                'type', obj.type, ...
                'pos', obj.pos, ...
                'vel', obj.vel, ...
                'speed', obj.speed, ...
                'H', obj.H, ...
                'waypoints', obj.waypoints, ...
                'smooth_path', obj.smooth_path, ...
                'path_index', obj.path_index, ...
                'RCS', obj.RCS, ...
                'maneuver_ability', obj.maneuver_ability, ...
                'jam_type', obj.jam_type, ...
                'task', obj.task, ...
                'group_size', obj.group_size, ...
                'priority_from_command', obj.priority_from_command, ...
                'status', obj.status, ...
                'color', obj.color, ...
                'marker', obj.marker ...
            );
        end
    end
end
