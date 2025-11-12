classdef ProtectedObject < handle
    %% CLASS ĐỐI TƯỢNG BẢO VỆ (PROTECTED OBJECT)
    % Mô tả: Class quản lý đối tượng cần bảo vệ
    
    properties
        name                    % Tên đối tượng
        type                    % Loại đối tượng
        pos                     % Vị trí [x, y, z] (m)
        importance              % Mức độ quan trọng (0-1)
        protection_radius       % Bán kính bảo vệ (m)
    end
    
    methods
        function obj = ProtectedObject(name, type, pos, importance, radius)
            %% CONSTRUCTOR
            if nargin > 0
                obj.name = name;
                obj.type = type;
                obj.pos = pos;
                obj.importance = importance;
                
                if nargin >= 5
                    obj.protection_radius = radius;
                else
                    obj.protection_radius = 5000;  % Mặc định 5km
                end
            end
        end
        
        function threat_level = assessThreat(obj, target)
            %% ĐÁNH GIÁ MỨC ĐỘ ĐE DỌA
            % Tính mức độ đe dọa của mục tiêu đối với đối tượng này
            
            % Khoảng cách
            dist = norm(target.pos(1:2) - obj.pos(1:2));
            
            % Vector hướng
            dir_to_obj = obj.pos(1:2) - target.pos(1:2);
            
            % Góc tiếp cận
            if norm(target.vel(1:2)) > 0 && norm(dir_to_obj) > 0
                cos_angle = dot(target.vel(1:2), dir_to_obj) / ...
                           (norm(target.vel(1:2)) * norm(dir_to_obj));
                
                % Hệ số góc (0-1)
                angle_factor = max(0, cos_angle);
            else
                angle_factor = 0;
            end
            
            % Hệ số khoảng cách (gần = nguy hiểm)
            if dist < obj.protection_radius
                distance_factor = 1.0;
            else
                distance_factor = obj.protection_radius / dist;
            end
            
            % Tính mức độ đe dọa
            threat_level = angle_factor * distance_factor * obj.importance;
        end
        
        function s = toStruct(obj)
            %% CHUYỂN ĐỔI SANG STRUCT
            s = struct( ...
                'name', obj.name, ...
                'type', obj.type, ...
                'pos', obj.pos, ...
                'importance', obj.importance, ...
                'protection_radius', obj.protection_radius ...
            );
        end
    end
end
