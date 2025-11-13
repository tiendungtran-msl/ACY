function updateGroundTruthTables(gt_window, targets, SCH, fire_units)
    %% CẬP NHẬT BẢNG GROUND TRUTH (SIÊU NGẮN GỌN)
    
    for i = 1:length(targets)
        target = targets(i);
        
        if strcmp(target.status, 'Đang bay')
            % Tính khoảng cách
            dist_to_sch = norm(target.pos(1:2) - SCH.pos(1:2)) / 1000;
            
            % Tìm ĐVHL gần nhất
            min_dist_DVHL = inf;
            nearest_DVHL = '';
            for j = 1:length(fire_units)
                d = norm(target.pos(1:2) - fire_units(j).pos(1:2)) / 1000;
                if d < min_dist_DVHL
                    min_dist_DVHL = d;
                    nearest_DVHL = fire_units(j).name;
                end
            end
            
            % RCS thực
            if isfield(target, 'RCS_real')
                RCS_real = target.RCS_real;
            else
                RCS_real = target.RCS;
            end
            
            % ═══════════════════════════════════════════════════════
            % DỮ LIỆU GROUND TRUTH SIÊU NGẮN GỌN (12 DÒNG)
            % ═══════════════════════════════════════════════════════
            data = {
                'ID', sprintf('T-%d', target.id);
                'Tên', target.name;
                'Loại THỰC', target.type;
                'Vị trí [x,y,z]', sprintf('[%.0f, %.0f, %.0f]', target.pos(1), target.pos(2), target.pos(3));
                'Vận tốc THỰC', sprintf('%.1f m/s (%.0f km/h)', target.speed, target.speed*3.6);
                'Gia tốc THỰC', sprintf('%.2f m/s²', target.current_accel);
                'RCS THỰC', sprintf('%.4f m²', RCS_real);
                'Cơ động max', sprintf('%.1f G', target.maneuver_ability);
                'K/c SCH', sprintf('%.2f km', dist_to_sch);
                'K/c ĐVHL', sprintf('%s: %.2f km', nearest_DVHL, min_dist_DVHL);
                'Nhiệm vụ', target.task;
                'Gây nhiễu', target.jam_type
            };
            
            set(gt_window.tables{i}, 'Data', data);
            set(gt_window.tables{i}, 'ColumnWidth', {140, 220});
            
            % Điều chỉnh chiều cao dòng
            try
                jScroll = findjobj(gt_window.tables{i});
                if ~isempty(jScroll)
                    jTable = jScroll.getViewport.getView;
                    jTable.setRowHeight(18);
                end
            catch
                % Không làm gì nếu lỗi
            end
            
        else
            % Hoàn thành
            data = {
                'Trạng thái', '✓ ĐÃ HOÀN THÀNH';
                'ID', sprintf('T-%d', target.id);
                'Tên', target.name
            };
            set(gt_window.tables{i}, 'Data', data);
            set(gt_window.tables{i}, 'ColumnWidth', {140, 220});
        end
    end
end