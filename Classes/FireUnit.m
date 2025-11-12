classdef FireUnit < handle
    %% CLASS ĐƠN VỊ HỎA LỰC (FIRE UNIT)
    % Mô tả: Class quản lý đơn vị hỏa lực phòng không
    
    properties
        name                    % Tên đơn vị
        type                    % Loại vũ khí
        pos                     % Vị trí [x, y, z] (m)
        
        % Tham số chiến thuật
        range_min               % Tầm bắn gần (m)
        range_max               % Tầm bắn xa (m)
        height_min              % Độ cao tối thiểu (m)
        height_max              % Độ cao tối đa (m)
        channels                % Số kênh hỏa lực
        
        % Trạng thái
        assigned_targets        % Mục tiêu được phân công
        status                  % Trạng thái
    end
    
    methods
        function obj = FireUnit(name, type, pos, range_min, range_max, ...
                               height_min, height_max, channels)
            %% CONSTRUCTOR
            if nargin > 0
                obj.name = name;
                obj.type = type;
                obj.pos = pos;
                obj.range_min = range_min;
                obj.range_max = range_max;
                obj.height_min = height_min;
                obj.height_max = height_max;
                obj.channels = channels;
                obj.assigned_targets = [];
                obj.status = 'Sẵn sàng';
            end
        end
        
        function can_engage = canEngage(obj, target)
            %% KIỂM TRA KHẢ NĂNG BẮN
            % Kiểm tra mục tiêu có trong vùng tiêu diệt không
            
            % Khoảng cách
            dist = norm(target.pos(1:2) - obj.pos(1:2));
            
            % Độ cao
            height = target.pos(3);
            
            % Kiểm tra điều kiện
            can_engage = (dist >= obj.range_min) && ...
                        (dist <= obj.range_max) && ...
                        (height >= obj.height_min) && ...
                        (height <= obj.height_max) && ...
                        (length(obj.assigned_targets) < obj.channels);
        end
        
        function assignTarget(obj, target_id)
            %% PHÂN CÔNG MỤC TIÊU
            if length(obj.assigned_targets) < obj.channels
                obj.assigned_targets = [obj.assigned_targets, target_id];
            end
        end
        
        function releaseTarget(obj, target_id)
            %% GIẢI PHÓNG MỤC TIÊU
            obj.assigned_targets(obj.assigned_targets == target_id) = [];
        end
        
        function s = toStruct(obj)
            %% CHUYỂN ĐỔI SANG STRUCT
            s = struct( ...
                'name', obj.name, ...
                'type', obj.type, ...
                'pos', obj.pos, ...
                'range_min', obj.range_min, ...
                'range_max', obj.range_max, ...
                'height_min', obj.height_min, ...
                'height_max', obj.height_max, ...
                'channels', obj.channels, ...
                'assigned_targets', obj.assigned_targets, ...
                'status', obj.status ...
            );
        end
    end
end
