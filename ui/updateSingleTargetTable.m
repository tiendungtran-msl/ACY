function updateSingleTargetTable(table_handle, target, SCH, targets_protect, fire_units)
    %% CẬP NHẬT BẢNG DỰ ĐOÁN ACY (SIÊU NGẮN GỌN)
    
    if strcmp(target.status, 'Đang bay')
        % Đo đạc với sai số
        dist_to_sch = norm(target.pos(1:2) - SCH.pos(1:2));
        sigma_pos = min(2000, dist_to_sch * 0.02);
        pos_measured = target.pos + randn(1,3) .* [sigma_pos, sigma_pos, sigma_pos*0.5];
        
        sigma_vel = 10;
        speed_measured = max(0, target.speed + randn() * sigma_vel);
        
        % RCS đo
        if isfield(target, 'RCS_eff')
            RCS_base = target.RCS_eff;
        else
            RCS_base = target.RCS;
        end
        
        if strcmp(target.jam_type, 'Không')
            sigma_RCS = RCS_base * 0.1;
        elseif strcmp(target.jam_type, 'Thụ động')
            sigma_RCS = RCS_base * 0.2;
        else
            sigma_RCS = RCS_base * 0.3;
        end
        RCS_measured = max(0.01, RCS_base + randn() * sigma_RCS);
        
        % Nhận dạng loại
        if RCS_measured > 10
            target_type_inferred = 'MB ném bom';
            confidence = 85;
        elseif RCS_measured > 3 && speed_measured < 400
            target_type_inferred = 'TK ném bom';
            confidence = 75;
        elseif RCS_measured > 1 && speed_measured > 600
            target_type_inferred = 'TK chiến thuật';
            confidence = 80;
        elseif RCS_measured < 1
            target_type_inferred = 'TLHT';
            confidence = 70;
        else
            target_type_inferred = 'Không rõ';
            confidence = 50;
        end
        
        % Phát hiện ECM
        if sigma_RCS > RCS_base * 0.25
            jam_inferred = 'Cao (chủ động)';
        elseif sigma_RCS > RCS_base * 0.15
            jam_inferred = 'Vừa (thụ động)';
        else
            jam_inferred = 'Không';
        end
        
        % Tính Bj
        Bj = calculateThreatLevel(target, SCH.pos(1:2), targets_protect, fire_units);
        
        % K/c ĐVHL
        if isfield(target, 'distance_to_DVHL') && ~isinf(target.distance_to_DVHL)
            dist_DVHL = target.distance_to_DVHL / 1000;
        else
            dist_DVHL = 0;
        end
        
        % ═══════════════════════════════════════════════════════
        % DỮ LIỆU BẢNG SIÊU NGẮN GỌN (10 DÒNG)
        % ═══════════════════════════════════════════════════════
        data = {
            'ID', sprintf('T-%d', target.id);
            'Loại (dự đoán)', sprintf('%s (%d%%)', target_type_inferred, confidence);
            'Vị trí đo [x,y,z]', sprintf('[%.0f, %.0f, %.0f]', pos_measured(1), pos_measured(2), pos_measured(3));
            'K/c SCH', sprintf('%.2f km', norm(pos_measured(1:2) - SCH.pos(1:2))/1000);
            'K/c ĐVHL', sprintf('%.2f km', dist_DVHL);
            'Vận tốc', sprintf('%.0f m/s (±%.0f)', speed_measured, sigma_vel);
            'Gia tốc', sprintf('%.2f m/s²', target.current_accel);
            'RCS', sprintf('%.3f m² (±%.2f)', RCS_measured, sigma_RCS);
            'ECM', jam_inferred;
            'Lệnh ưu tiên', char(string(target.priority_from_command));
            'Bj', sprintf('★ %.2f/10', Bj)
        };
        
        set(table_handle, 'Data', data);
        set(table_handle, 'ColumnWidth', {85, 130});
        
        % Điều chỉnh chiều cao dòng để không có khoảng trống
        try
            jScroll = findjobj(table_handle);
            if ~isempty(jScroll)
                jTable = jScroll.getViewport.getView;
                jTable.setRowHeight(18);  % Chiều cao dòng nhỏ hơn (mặc định ~24)
            end
        catch
            % Không làm gì nếu lỗi
        end
        
        % Màu nền theo Bj
        n_rows = size(data, 1);
        bg_colors = createTableBackgroundColors(n_rows, Bj);
        set(table_handle, 'BackgroundColor', bg_colors);
        
    else
        % Hoàn thành
        data = {
            'ID', sprintf('T-%d', target.id);
            'Tên', target.name;
            'Trạng thái', '✓ HOÀN THÀNH'
        };
        set(table_handle, 'Data', data);
        set(table_handle, 'ColumnWidth', {140, 240});
    end
end