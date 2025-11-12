classdef AirSituation < handle
    %% CLASS TÌNH HUỐNG TRÊN KHÔNG (AIR SITUATION)
    % Mô tả: Class quản lý toàn bộ tình huống không chiến
    
    properties
        SCH                     % Sở chỉ huy
        targets                 % Danh sách mục tiêu
        fire_units              % Danh sách đơn vị hỏa lực
        protected_objects       % Danh sách đối tượng bảo vệ
        time                    % Thời gian mô phỏng
        cfg                     % Cấu hình
    end
    
    methods
        function obj = AirSituation(SCH, targets, fire_units, protected_objects)
            %% CONSTRUCTOR
            if nargin > 0
                obj.SCH = SCH;
                obj.targets = targets;
                obj.fire_units = fire_units;
                obj.protected_objects = protected_objects;
                obj.time = 0;
                obj.cfg = config();
            end
        end
        
        function update(obj, dt)
            %% CẬP NHẬT TÌNH HUỐNG
            % Cập nhật thời gian
            obj.time = obj.time + dt;
            
            % Cập nhật vị trí các mục tiêu
            for i = 1:length(obj.targets)
                if isa(obj.targets(i), 'Target')
                    obj.targets(i).updateMotion(dt);
                end
            end
        end
        
        function evaluateAllTargets(obj)
            %% ĐÁNH GIÁ TẤT CẢ MỤC TIÊU (THUẬT TOÁN 11 KHỐI)
            
            for j = 1:length(obj.targets)
                target = obj.targets(j);
                
                % Chuyển sang struct nếu là object
                if isa(target, 'Target')
                    target_struct = target.toStruct();
                else
                    target_struct = target;
                end
                
                %% KHỐI 1: Đánh giá tham số chuyển động
                params = Block1_EvaluateMotion(target_struct, obj.cfg.simulation_dt);
                
                %% KHỐI 2: Kiểm tra vùng phân phối
                in_zone = Block2_CheckZone(target_struct.pos, obj.SCH.pos, ...
                    obj.cfg.distribution_range_min, obj.cfg.distribution_range_max);
                
                if ~in_zone
                    continue;  % KHỐI 11: Chuyển sang mục tiêu tiếp theo
                end
                
                %% KHỐI 3: Kiểm tra chỉ thị cấp trên
                if target_struct.priority_from_command
                    target_struct.Bj = obj.cfg.command_priority_score;
                    if isa(target, 'Target')
                        target.Bj = target_struct.Bj;
                    else
                        obj.targets(j).Bj = target_struct.Bj;
                    end
                    continue;
                end
                
                %% KHỐI 4: Nhận dạng dạng mục tiêu
                % (Đã được xử lý trong khởi tạo)
                
                %% KHỐI 5: Đánh giá số lượng thành phần
                % (Đã có trong target_struct.group_size)
                
                %% KHỐI 6: Xác định dấu hiệu chiến đấu
                % (Đã có trong target_struct.jam_type)
                
                %% KHỐI 7: Xác định nhiệm vụ
                % (Đã có trong target_struct.task)
                
                %% KHỐI 4'-5': Tính tham số không-thời gian
                % Tính với đối tượng bảo vệ quan trọng nhất
                % (Được tính trong Block6p)
                
                %% KHỐI 6': Tính mức độ quan trọng Bⱼ
                protected_structs = obj.protected_objects;
                if isa(obj.protected_objects, 'ProtectedObject')
                    protected_structs = arrayfun(@(x) x.toStruct(), ...
                        obj.protected_objects, 'UniformOutput', false);
                    protected_structs = [protected_structs{:}];
                end
                
                fire_structs = obj.fire_units;
                if isa(obj.fire_units, 'FireUnit')
                    fire_structs = arrayfun(@(x) x.toStruct(), ...
                        obj.fire_units, 'UniformOutput', false);
                    fire_structs = [fire_structs{:}];
                end
                
                Bj = Block6p_CalculateBj(target_struct, obj.SCH, ...
                    protected_structs, fire_structs, obj.cfg);
                
                % Cập nhật Bⱼ
                if isa(target, 'Target')
                    target.Bj = Bj;
                else
                    obj.targets(j).Bj = Bj;
                end
            end
            
            %% KHỐI 11: Hoàn thành đánh giá tất cả mục tiêu
        end
        
        function prioritized = getPrioritizedTargets(obj)
            %% LẤY DANH SÁCH MỤC TIÊU ĐÃ SẮP XẾP THEO ƯU TIÊN
            
            % Trích xuất Bⱼ
            Bj_values = zeros(length(obj.targets), 1);
            for i = 1:length(obj.targets)
                if isa(obj.targets(i), 'Target')
                    Bj_values(i) = obj.targets(i).Bj;
                else
                    Bj_values(i) = obj.targets(i).Bj;
                end
            end
            
            % Sắp xếp giảm dần
            [~, idx] = sort(Bj_values, 'descend');
            prioritized = obj.targets(idx);
        end
    end
end
