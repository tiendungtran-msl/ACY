function runMainLoop(sim_state)
    %% VÒNG LẶP CHÍNH CỦA MÔ PHỎNG
    
    % ═══════════════════════════════════════════════════════
    % THIẾT LẬP THAM SỐ
    % ═══════════════════════════════════════════════════════
    dt = 1;              % Bước thời gian (giây)
    max_time = 200;      % Thời gian tối đa
    
    fprintf('▶ Bắt đầu mô phỏng (t=%.1fs)...\n', sim_state.time);
    
    % ═══════════════════════════════════════════════════════
    % VÒNG LẶP CHÍNH
    % ═══════════════════════════════════════════════════════
    while sim_state.time < max_time
        % Đọc lại trạng thái từ appdata
        sim_state = getappdata(sim_state.fig, 'sim_state');
        
        % Kiểm tra có đang chạy không
        if ~sim_state.is_running
            fprintf('⏸ Đã tạm dừng tại t=%.1fs\n', sim_state.time);
            break;
        end
        
        % Tăng thời gian
        sim_state.time = sim_state.time + dt;
        
        % 1. Cập nhật vị trí
        sim_state = updateTargetPositions(sim_state, dt);
        
        % 2. Cập nhật RCS theo cự ly
        sim_state.targets = updateTargetRCS(sim_state.targets, sim_state.fire_units);
        
        % 3. Lưu quỹ đạo
        for i = 1:length(sim_state.targets)
            if strcmp(sim_state.targets(i).status, 'Đang bay')
                if isfield(sim_state, 'trajectories') && length(sim_state.trajectories) >= i
                    sim_state.trajectories{i} = [sim_state.trajectories{i}; sim_state.targets(i).pos];
                end
            end
        end
        
        % 4. Vẽ lại
        sim_state = redrawTargets(sim_state);
        
        % 5. Cập nhật bảng (MỖI 0.5 GIÂY thay vì mỗi frame)
        if ~isfield(sim_state, 'last_table_update')
            sim_state.last_table_update = 0;
        end
        
        if sim_state.time - sim_state.last_table_update >= 0.5
            % Cập nhật bảng dự đoán ACY (cửa sổ chính)
            updateAllTargetTables(sim_state);
            
            % Cập nhật bảng Ground Truth (cửa sổ riêng)
            if isfield(sim_state, 'gt_window') && ...
               ishandle(sim_state.gt_window.fig) && ...
               isvalid(sim_state.gt_window.fig)
                updateGroundTruthTables(sim_state.gt_window, sim_state.targets, ...
                    sim_state.SCH, sim_state.fire_units);
            end
            
            sim_state.last_table_update = sim_state.time;
        end
        
        % Lưu lại sau mỗi vòng lặp
        setappdata(sim_state.fig, 'sim_state', sim_state);
        
        % Refresh UI
        drawnow;
        pause(0.05);
        
        % Kiểm tra điều kiện dừng
        n_active = sum(strcmp({sim_state.targets.status}, 'Đang bay'));
        if n_active == 0
            fprintf('\n✓ Tất cả mục tiêu đã hoàn thành tại t=%.1fs!\n', sim_state.time);
            sim_state.is_running = false;
            break;
        end
    end
    
    % ═══════════════════════════════════════════════════════
    % KẾT THÚC MÔ PHỎNG
    % ═══════════════════════════════════════════════════════
    if sim_state.time >= max_time
        fprintf('\n⏱ Đã đạt thời gian tối đa: %.1fs\n', max_time);
    end
    
    % Reset buttons
    set(sim_state.buttons.start, 'Enable', 'on');
    set(sim_state.buttons.pause, 'Enable', 'off');
    
    setappdata(sim_state.fig, 'sim_state', sim_state);
    
    fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
end