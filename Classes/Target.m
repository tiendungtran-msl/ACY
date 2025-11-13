classdef Target < handle
    %% CLASS MỤC TIÊU (TARGET)
    % Mô tả: Class quản lý thông tin và hành vi của mục tiêu
    
    properties
        % NHÓM 1: THÔNG TIN ĐỊNH DANH
        id                      % ID mục tiêu
        name                    % Tên mục tiêu
        type                    % Loại mục tiêu
        
        % NHÓM 2: TỌA ĐỘ VÀ THAM SỐ CHUYỂN ĐỘNG
        pos                     % Vị trí [x, y, z] (m)
        vel                     % Vận tốc [vx, vy, vz] (m/s)
        speed                   % Tốc độ hiện tại (m/s)
        speed_min               % Tốc độ tối thiểu (m/s)
        speed_max               % Tốc độ tối đa (m/s)
        speed_cruise            % Tốc độ hành trình (m/s)
        accel_max               % Gia tốc tối đa (m/s²)
        current_accel           % Gia tốc hiện tại (m/s²)
        waypoints               % Các điểm mốc [x, y, z] - Nx3 matrix
        smooth_path             % Đường đi mượt [x, y, z] - Mx3 matrix
        path_index              % Chỉ số trên đường đi
        
        % NHÓM 3: ĐẶC TRƯNG VÀ DẤU HIỆU
        RCS                     % Diện tích phản xạ radar (m²) - đây là RCS_base
        RCS_min                 % RCS tối thiểu (m²)
        RCS_max                 % RCS tối đa (m²)
        RCS_real                % RCS thực (Enemy - ground truth)
        RCS_eff                 % RCS hiệu dụng để hiển thị (ACY - đo được)
        distance_to_DVHL        % Cự ly đến ĐVHL gần nhất (m)
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
    function obj = Target(id, name, type, speed, RCS, maneuver, ...
                task, jam_type, group_size, waypoints, color, marker)
            %% CONSTRUCTOR
            % waypoints phải là ma trận Nx3 [x, y, z]
            if nargin > 0
                obj.id = id;
                obj.name = name;
                obj.type = type;
                obj.speed = speed;
                obj.RCS = RCS;
                
                % Khởi tạo RCS min/max theo loại
                switch type
                    case 'B52'
                        obj.RCS_min = 50;
                        obj.RCS_max = 200;
                    case {'Fighter', 'Tiêm kích chiến thuật', 'Tiêm kích ném bom'}
                        obj.RCS_min = 2;
                        obj.RCS_max = 15;
                    case {'Cruise_Missile', 'Tên lửa hành trình'}
                        obj.RCS_min = 0.01;
                        obj.RCS_max = 0.5;
                    otherwise
                        obj.RCS_min = RCS * 0.5;
                        obj.RCS_max = RCS * 2;
                end
                
                obj.RCS_real = RCS;
                obj.RCS_eff = RCS;
                obj.distance_to_DVHL = inf;
                
                obj.maneuver_ability = maneuver;
                obj.task = task;
                obj.jam_type = jam_type;
                obj.group_size = group_size;
                obj.waypoints = waypoints;  % Nx3 matrix
                obj.color = color;
                obj.marker = marker;
                
                % Khởi tạo vị trí ban đầu (lấy từ waypoint đầu tiên)
                obj.pos = waypoints(1, :);  % [x, y, z]
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
            s = struct( ...
                'id', obj.id, ...
                'name', obj.name, ...
                'type', obj.type, ...
                'pos', obj.pos, ...           % [x, y, z]
                'vel', obj.vel, ...           % [vx, vy, vz]
                'speed', obj.speed, ...
                'waypoints', obj.waypoints, ... % Nx3
                'smooth_path', obj.smooth_path, ... % Mx3
                'path_index', obj.path_index, ...
                'RCS', obj.RCS, ...
                'RCS_min', obj.RCS_min, ...
                'RCS_max', obj.RCS_max, ...
                'RCS_real', obj.RCS_real, ...
                'RCS_eff', obj.RCS_eff, ...
                'distance_to_DVHL', obj.distance_to_DVHL, ...
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
