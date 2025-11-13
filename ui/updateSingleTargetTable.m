function updateSingleTargetTable(table_handle, target, SCH, targets_protect, fire_units)
    %% CẬP NHẬT BẢNG THÔNG TIN (PHIÊN BẢN ĐơN GIẢN - KHÔNG DÙNG JAVA)
    
    if strcmp(target.status, 'Đang bay')
        Bj = calculateThreatLevel(target, SCH.pos(1:2), targets_protect, fire_units);
        dist_to_sch = norm(target.pos(1:2) - SCH.pos(1:2)) / 1000;
        
        % Lấy RCS hiệu dụng
        if isfield(target, 'RCS_eff')
            RCS_display = target.RCS_eff;
        else
            RCS_display = target.RCS;
        end
        
        % Lấy khoảng cách đến ĐVHL
        if isfield(target, 'distance_to_DVHL') && ~isinf(target.distance_to_DVHL)
            dist_DVHL = target.distance_to_DVHL / 1000;
        else
            dist_DVHL = 0;
        end
        
        % Lấy gia tốc
        if isfield(target, 'current_accel')
            accel = target.current_accel;
        else
            accel = 0;
        end
        
        % Tạo dữ liệu bảng
        data = {
            'ID', sprintf('T-%d', target.id);
            'Tên', target.name;
            'Loại', target.type;
            'Vận tốc', sprintf('%d m/s (%.0f km/h)', round(target.speed), round(target.speed*3.6));
            'Độ cao', sprintf('%d m', round(target.pos(3)));
            'RCS hiệu dụng', sprintf('%.2f m²', RCS_display);
            'RCS cơ sở', sprintf('%.2f m²', target.RCS);
            'Cơ động', sprintf('%.1f G', target.maneuver_ability);
            'Gia tốc', sprintf('%.2f m/s²', accel);
            'Nhiệm vụ', target.task;
            'Nhóm', sprintf('%d MB', target.group_size);
            'Gây nhiễu', target.jam_type;
            'K/c SCH', sprintf('%.1f km', dist_to_sch);
            'K/c ĐVHL', sprintf('%.1f km', dist_DVHL);
            'Ưu tiên', char(string(target.priority_from_command));
            'NGUY HIỂM', sprintf('★ %.2f/10', Bj)
        };
        
        % Cập nhật dữ liệu
        set(table_handle, 'Data', data);
        set(table_handle, 'ColumnWidth', {120, 160});
        
        % Màu nền theo Bj
        n_rows = size(data, 1);
        bg_colors = createTableBackgroundColors(n_rows, Bj);
        set(table_handle, 'BackgroundColor', bg_colors);
        
    else
        % Mục tiêu đã hoàn thành
        data = {
            'ID', sprintf('T-%d', target.id);
            'Tên', target.name;
            'Trạng thái', '✓ HOÀN THÀNH'
        };
        set(table_handle, 'Data', data);
        set(table_handle, 'ColumnWidth', {120, 160});
        
        n_rows = size(data, 1);
        bg_colors = createTableBackgroundColors(n_rows, 0);
        set(table_handle, 'BackgroundColor', bg_colors);
    end
end