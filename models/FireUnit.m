classdef FireUnit < handle
    %% FIREUNIT - Đơn vị hỏa lực phòng không (handle class)
    %
    % Handle class: không copy khi truyền vào function.

    properties
        name              % Tên đơn vị
        type              % Loại vũ khí
        pos               % Vị trí [x, y, z] (m)

        % Tham số tầm bắn
        range_min         % Tầm bắn gần (m)
        range_max         % Tầm bắn xa (m)
        H_min             % Độ cao tối thiểu (m)
        H_max             % Độ cao tối đa (m)
        channels          % Số kênh hỏa lực đồng thời

        % Trạng thái
        assigned_targets  % ID mục tiêu đã phân công
        status            % 'Sẵn sàng' | 'Bận'
    end

    methods

        function obj = FireUnit(name, type, pos, range_min, range_max, H_min, H_max, channels)
            %% CONSTRUCTOR
            if nargin > 0
                obj.name     = name;
                obj.type     = type;
                obj.pos      = pos;
                obj.range_min = range_min;
                obj.range_max = range_max;
                obj.H_min    = H_min;
                obj.H_max    = H_max;
                obj.channels = channels;
                obj.assigned_targets = [];
                obj.status   = 'Sẵn sàng';
            end
        end

        function can_engage = canEngage(obj, target)
            %% Kiểm tra mục tiêu có trong vùng tiêu diệt không
            dist   = norm(target.pos(1:2) - obj.pos(1:2));
            height = target.pos(3);
            can_engage = (dist   >= obj.range_min) && (dist   <= obj.range_max) && ...
                         (height >= obj.H_min)      && (height <= obj.H_max)     && ...
                         (length(obj.assigned_targets) < obj.channels);
        end

        function assignTarget(obj, target_id)
            %% Phân công mục tiêu
            if length(obj.assigned_targets) < obj.channels
                obj.assigned_targets = [obj.assigned_targets, target_id];
            end
        end

        function releaseTarget(obj, target_id)
            %% Giải phóng mục tiêu
            obj.assigned_targets(obj.assigned_targets == target_id) = [];
        end

    end % methods
end % classdef
