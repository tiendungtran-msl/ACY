function updateSingleTargetTable(table_handle, target, SCH, targets_protect, fire_units)
    if strcmp(target.status, 'Đang bay')
        Bj = calculateThreatLevel(target, SCH.pos(1:2), targets_protect, fire_units);
        dist_to_sch = norm(target.pos(1:2) - SCH.pos(1:2)) / 1000;
        
        % Tạo dữ liệu bảng
        data = {
            'ID', sprintf('T-%d', target.id);
            'Tên', target.name;
            'Loại', target.type;
            'Vận tốc', sprintf('%d m/s', round(target.speed));
            'Độ cao', sprintf('%d m', round(target.H));
            'RCS', sprintf('%.2f m²', target.RCS);
            'Cơ động', sprintf('%.1f G', target.maneuver_ability);
            'Nhiệm vụ', target.task;
            'Nhóm', sprintf('%d MB', target.group_size);
            'Gây nhiễu', target.jam_type;
            'K/c SCH', sprintf('%.1f km', dist_to_sch);
            'Ưu tiên', char(string(target.priority_from_command));
            'NGUY HIỂM', sprintf('★ %.2f/10', Bj)
        };
        
        set(table_handle, 'Data', data);
        set(table_handle, 'ColumnWidth', {100, 120});
        
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
        set(table_handle, 'ColumnWidth', {100, 120});
        
        n_rows = size(data, 1);
        bg_colors = createTableBackgroundColors(n_rows, 0);
        set(table_handle, 'BackgroundColor', bg_colors);
    end
end