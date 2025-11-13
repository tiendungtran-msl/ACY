function runMainLoop(sim_state)
    %% VÒNG LẶP CHÍNH CỦA MÔ PHỎNG
    % Điều khiển luồng mô phỏng, cập nhật vị trí, RCS, và hiển thị
    
    % ═══════════════════════════════════════════════════════
    % THIẾT LẬP THAM SỐ
    % ═══════════════════════════════════════════════════════
    dt = 1;              % Bước thời gian (giây)
    max_time = 200;      % Thời gian tối đa (giây)
    
    % Khởi tạo timer cho cập nhật bảng (dùng biến trong sim_state)
    if ~isfield(sim_state, 'last_table_update')
        sim_state.last_table_update = 0;
    end
    
    fprintf('▶ Bắt đầu mô phỏng (t=%.1fs)...\n', sim_state.time);
    
    % ═══════════════════════════════════════════════════════
    % VÒNG LẶP CHÍNH
    % ═══════════════════════════════════════════════════════
    while sim_state.time < max_time
        % Đọc lại trạng thái từ appdata (để sync với UI)
        sim_state = getappdata(sim_state.fig, 'sim_state');
        
        % Kiểm tra có đang chạy không (pause/stop)
        if ~sim_state.is_running
            fprintf('⏸ Đã tạm dừng tại t=%.1fs\n', sim_state.time);
            break;
        end
        
        % ───────────────────────────────────────────────────
        % 1. CẬP NHẬT VỊ TRÍ MỤC TIÊU
        % ───────────────────────────────────────────────────
        sim_state = updateTargetPositions(sim_state, dt);
        
        % ───────────────────────────────────────────────────
        % 2. CẬP NHẬT RCS THEO CỰ LY ĐẾN ĐVHL
        % ───────────────────────────────────────────────────
        sim_state.targets = updateTargetRCS(sim_state.targets, sim_state.fire_units);
        
        % ───────────────────────────────────────────────────
        % 3. CẬP NHẬT TRAJECTORIES (lưu quỹ đạo)
        % ───────────────────────────────────────────────────
        for i = 1:length(sim_state.targets)
            if strcmp(sim_state.targets(i).status, 'Đang bay')
                % Thêm điểm mới vào quỹ đạo
                if isfield(sim_state, 'trajectories') && length(sim_state.trajectories) >= i
                    sim_state.trajectories{i} = [sim_state.trajectories{i}; sim_state.targets(i).pos];
                end
            end
        end
        
        % ───────────────────────────────────────────────────
        % 4. VẼ LẠI MỤC TIÊU (Cập nhật vị trí, màu, label)
        % ───────────────────────────────────────────────────
        sim_state = redrawTargets(sim_state);
        
        % ───────────────────────────────────────────────────
        % 5. CẬP NHẬT BẢNG THÔNG TIN (MỖI 0.5 GIÂY)
        % ───────────────────────────────────────────────────
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
        
        % ───────────────────────────────────────────────────
        % 6. TĂNG THỜI GIAN
        % ───────────────────────────────────────────────────
        sim_state.time = sim_state.time + dt;
        
        % ───────────────────────────────────────────────────
        % 7. LƯU TRẠNG THÁI VÀ REFRESH UI
        % ───────────────────────────────────────────────────
        setappdata(sim_state.fig, 'sim_state', sim_state);
        drawnow;
        pause(0.05);  % Giảm tải CPU
        
        % ───────────────────────────────────────────────────
        % 8. KIỂM TRA ĐIỀU KIỆN DỪNG
        % ───────────────────────────────────────────────────
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
    
    % Lưu trạng thái cuối cùng
    setappdata(sim_state.fig, 'sim_state', sim_state);
    
    fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
end