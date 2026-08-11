function updateSingleTargetTable(table_handle, target, SCH, targets_protect, fire_units)
    %% CẬP NHẬT BẢNG DỰ ĐOÁN ACY
    % CHỈ HIỂN THỊ KHI MỤC TIÊU TRONG VÙNG QUAN SÁT
    
    if strcmp(target.status, 'Đang bay')
        % ═══════════════════════════════════════════════════════
        % KIỂM TRA MỤC TIÊU CÓ TRONG VÙNG QUAN SÁT KHÔNG
        % ═══════════════════════════════════════════════════════
        observation_radius = 60000;  % 60km
        in_zone = isTargetInObservationZone(target, SCH, observation_radius);
        
        if ~in_zone
            % ═══════════════════════════════════════════════════
            % NGOÀI VÙNG → KHÔNG HIỂN THỊ GÌ CẢ
            % ═══════════════════════════════════════════════════
            % ACY không biết có mục tiêu này
            data = {};  % Bảng trống
            set(table_handle, 'Data', data);
            return;
        end
        
        % ═══════════════════════════════════════════════════════
        % TRONG VÙNG → HIỂN THỊ ĐẦY ĐỦ THÔNG TIN
        % ═══════════════════════════════════════════════════════
        
        % Nhận dạng loại mục tiêu
        [target_type_inferred, confidence, ~] = classifyTarget(target);
        
        % Lấy thông tin đo đạc
        pos_measured = target.pos;
        speed_measured = target.speed;
        
        if isfield(target, 'RCS_eff')
            RCS_measured = target.RCS_eff;
        else
            RCS_measured = target.RCS;
        end
        
        % Phát hiện gây nhiễu
        if strcmp(target.jam_type, 'Chủ động')
            jam_inferred = 'Có (chủ động)';
        elseif strcmp(target.jam_type, 'Thụ động')
            jam_inferred = 'Có (thụ động)';
        else
            jam_inferred = 'Không';
        end
        
        % Tính Bj
        Bj = calculateThreatLevel(target, SCH.pos(1:2), targets_protect, fire_units);
        
        % Khoảng cách
        dist_to_sch = norm(target.pos(1:2) - SCH.pos(1:2)) / 1000;
        
        if isfield(target, 'distance_to_DVHL') && ~isinf(target.distance_to_DVHL)
            dist_DVHL = target.distance_to_DVHL / 1000;
        else
            dist_DVHL = 0;
        end
        
        % Dữ liệu bảng
        data = {
            'ID', sprintf('T-%d', target.id);
            'Loại', sprintf('%s (%d%%)', target_type_inferred, confidence);
            'Vị trí [x,y,z]', sprintf('[%.0f, %.0f, %.0f]', pos_measured(1), pos_measured(2), pos_measured(3));
            'K/c SCH', sprintf('%.2f km', dist_to_sch);
            'K/c ĐVHL', sprintf('%.2f km', dist_DVHL);
            'Vận tốc', sprintf('%.0f m/s (%.0f km/h)', speed_measured, speed_measured*3.6);
            'Gia tốc', sprintf('%.2f m/s²', target.current_accel);
            'RCS', sprintf('%.3f m²', RCS_measured);
            'Nhiệm vụ', predictMission(target, SCH, targets_protect, fire_units);
            'Lệnh ưu tiên', char(string(target.priority_from_command));
            'Bj', sprintf('★ %.2f/10', Bj)
        };
        
        set(table_handle, 'Data', data);
        set(table_handle, 'ColumnWidth', {85, 130});
        
        % Màu nền theo Bj
        n_rows = size(data, 1);
        bg_colors = createTableBackgroundColors(n_rows, Bj);
        set(table_handle, 'BackgroundColor', bg_colors);
        
    else
        % ═══════════════════════════════════════════════════════
        % HOÀN THÀNH → Hiển thị (vì đã từng phát hiện)
        % ═══════════════════════════════════════════════════════
        data = {
            'ID', sprintf('T-%d', target.id);
            'Tên', target.name;
            'Trạng thái', '✓ HOÀN THÀNH'
        };
        set(table_handle, 'Data', data);
        set(table_handle, 'ColumnWidth', {85, 130});
    end
end