function runMainLoop(sim_state)
    % Vòng lặp chính của mô phỏng
    
    dt = 1;
    max_time = 200;
    
    while sim_state.time < max_time
        % Đọc lại trạng thái từ appdata
        sim_state = getappdata(sim_state.fig, 'sim_state');
        
        % Kiểm tra có đang chạy không
        if ~sim_state.is_running
            fprintf('⏸ Đã tạm dừng tại t=%.1fs\n', sim_state.time);
            break;
        end
        
        sim_state.time = sim_state.time + dt;
        
        % Cập nhật vị trí
        sim_state = updateTargetPositions(sim_state, dt);

        % THÊM MỚI: Cập nhật RCS theo cự ly
        sim_state.targets = updateTargetRCS(sim_state.targets, sim_state.fire_units);
        
        % Vẽ lại
        sim_state = redrawTargets(sim_state);
        
        % Cập nhật bảng
        updateAllTargetTables(sim_state);
        
        % Lưu lại sau mỗi vòng lặp
        setappdata(sim_state.fig, 'sim_state', sim_state);
        
        drawnow;
        pause(0.05);
        
        % Kiểm tra điều kiện dừng
        n_active = sum(strcmp({sim_state.targets.status}, 'Đang bay'));
        if n_active == 0
            fprintf('\n✓ Tất cả mục tiêu đã hoàn thành!\n');
            sim_state.is_running = false;
            break;
        end
    end
    
    % Reset buttons
    set(sim_state.buttons.start, 'Enable', 'on');
    set(sim_state.buttons.pause, 'Enable', 'off');
    
    setappdata(sim_state.fig, 'sim_state', sim_state);
end