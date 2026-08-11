classdef Target < handle
    %% TARGET - Mục tiêu trên không (handle class)
    %
    % Handle class: không copy khi truyền vào function.
    % Mọi thay đổi bên trong function đều phản ánh trực tiếp lên object gốc.
    %
    % Sử dụng:
    %   t = Target(id, name, type, speed_cruise, RCS, maneuver, ...
    %              task, jam_type, group_size, waypoints, color, marker)

    properties
        % --- Định danh ---
        id
        name
        type

        % --- Chuyển động ---
        pos              % [x, y, z] (m)
        vel              % [vx, vy, vz] (m/s)
        speed            % Tốc độ hiện tại (m/s)
        speed_cruise     % Tốc độ hành trình (m/s)
        speed_min        % Tốc độ tối thiểu (m/s)
        speed_max        % Tốc độ tối đa (m/s)
        accel_max        % Gia tốc tối đa (m/s²)
        current_accel    % Gia tốc hiện tại (m/s²)
        waypoints        % Nx3 ma trận điểm mốc
        smooth_path      % Mx3 đường đi mượt
        path_index       % Chỉ số hiện tại trên smooth_path
        min_turn_radius  % Bán kính quẹo tối thiểu (m)
        trajectory_history  % Kx2 lịch sử quỹ đạo [x, y]

        % --- Đặc trưng radar ---
        RCS              % RCS cơ sở (m²)
        RCS_min          % RCS tối thiểu (m²)
        RCS_max          % RCS tối đa (m²)
        RCS_real         % RCS thực (ground truth)
        RCS_eff          % RCS đo được (có nhiễu)
        distance_to_DVHL % Cự ly đến ĐVHL gần nhất (m)

        % --- Chiến thuật ---
        maneuver_ability % Khả năng cơ động (G)
        jam_type         % 'Không' | 'Thụ động' | 'Chủ động'
        task             % Nhiệm vụ
        group_size       % Số lượng trong nhóm

        % --- Đánh giá ---
        priority_from_command  % logical
        status                 % 'Đang bay' | 'Hoàn thành'
        Bj                     % Mức độ quan trọng [0, 1]
        in_observation_zone    % logical

        % --- Hiển thị ---
        color
        marker
    end

    methods

        function obj = Target(id, name, type, speed_cruise, RCS, maneuver, ...
                              task, jam_type, group_size, waypoints, color, marker)
            %% CONSTRUCTOR
            % waypoints: ma trận Nx3 [x, y, z]
            if nargin > 0
                obj.id            = id;
                obj.name          = name;
                obj.type          = type;
                obj.speed_cruise  = speed_cruise;
                obj.speed         = speed_cruise;
                obj.RCS           = RCS;
                obj.maneuver_ability = maneuver;
                obj.task          = task;
                obj.jam_type      = jam_type;
                obj.group_size    = group_size;
                obj.waypoints     = waypoints;
                obj.color         = color;
                obj.marker        = marker;

                % Tham số phụ thuộc loại mục tiêu (Bảng 2)
                obj.initTypeParams();

                % Trạng thái ban đầu
                obj.pos                = waypoints(1, :);
                obj.vel                = [0, 0, 0];
                obj.smooth_path        = [];
                obj.path_index         = 1;
                obj.current_accel      = 0;
                obj.trajectory_history = waypoints(1, 1:2);
                obj.RCS_real           = RCS;
                obj.RCS_eff            = RCS;
                obj.distance_to_DVHL   = inf;
                obj.priority_from_command = false;
                obj.status             = 'Đang bay';
                obj.Bj                 = 0;
                obj.in_observation_zone = false;
            end
        end

    end % methods public

    methods (Access = private)

        function initTypeParams(obj)
            %% Khởi tạo RCS, tốc độ, gia tốc theo loại mục tiêu (Bảng 2)
            t = obj.type;
            v = obj.speed_cruise;

            if contains(t, 'B52') || contains(t, 'chiến lược') || contains(t, 'MB ném bom')
                obj.RCS_min = 5;    obj.RCS_max = 20;
                obj.speed_min = 250; obj.speed_max = 700;
                obj.accel_max = 1.0; obj.min_turn_radius = 8000;

            elseif contains(t, 'Tiêm kích ném bom') || contains(t, 'ném bom')
                obj.RCS_min = 2;    obj.RCS_max = 5;
                obj.speed_min = 320; obj.speed_max = 750;
                obj.accel_max = 3.0; obj.min_turn_radius = 3000;

            elseif contains(t, 'Tiêm kích') || contains(t, 'chiến thuật')
                obj.RCS_min = 1;    obj.RCS_max = 5;
                obj.speed_min = 350; obj.speed_max = 750;
                obj.accel_max = 5.0; obj.min_turn_radius = 2000;

            elseif contains(t, 'Tên lửa') || contains(t, 'hành trình')
                obj.RCS_min = 0.01; obj.RCS_max = 2.5;
                obj.speed_min = 250; obj.speed_max = 1200;
                obj.accel_max = 2.0; obj.min_turn_radius = 5000;

            else
                obj.RCS_min = obj.RCS * 0.5; obj.RCS_max = obj.RCS * 2;
                obj.speed_min = v * 0.7;      obj.speed_max = v * 1.3;
                obj.accel_max = 2.0;          obj.min_turn_radius = 4000;
            end
        end

    end % methods private
end % classdef
