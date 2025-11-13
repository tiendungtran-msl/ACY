function resetSimulation(src)
    %% RESET MÔ PHỎNG VỀ TRẠNG THÁI BAN ĐẦU
    % Tạo lại đường bay ngẫu nhiên mỗi lần reset
    
    fig = ancestor(src, 'figure');
    sim_state = getappdata(fig, 'sim_state');
    
    sim_state.is_running = false;
    sim_state.time = 0;
    
    fprintf('🔄 Đang reset hệ thống và tạo lại đường bay...\n');
    
    % TẠO LẠI ĐƯỜNG BAY NGẪU NHIÊN
    sim_state.targets = createSmoothPaths(sim_state.targets);
    
    % Reset vị trí mục tiêu
    for i = 1:length(sim_state.targets)
        sim_state.targets(i).path_index = 1;
        sim_state.targets(i).pos = sim_state.targets(i).smooth_path(1, :);  % [x, y, z]
        sim_state.targets(i).status = 'Đang bay';
        sim_state.targets(i).speed = sim_state.targets(i).speed_cruise * 0.8;  % Reset tốc độ
        sim_state.targets(i).current_accel = 0;
        sim_state.targets(i).vel = [0, 0, 0];
        
        % Reset trajectory history (2D)
        sim_state.targets(i).trajectory_history = sim_state.targets(i).pos(1:2);
        
        % Reset trajectory (3D)
        sim_state.trajectories{i} = sim_state.targets(i).pos;
        
        % XÓA ĐƯỜNG BAY CŨ
        if ishandle(sim_state.h_traj_2d(i)) && isvalid(sim_state.h_traj_2d(i))
            delete(sim_state.h_traj_2d(i));
            sim_state.h_traj_2d(i) = gobjects(1);
        end
        if ishandle(sim_state.h_traj_3d(i)) && isvalid(sim_state.h_traj_3d(i))
            delete(sim_state.h_traj_3d(i));
            sim_state.h_traj_3d(i) = gobjects(1);
        end
        
        % Hiện lại marker và label
        if ishandle(sim_state.h_targets_2d(i)) && isvalid(sim_state.h_targets_2d(i))
            set(sim_state.h_targets_2d(i), 'Visible', 'on');
            set(sim_state.h_targets_2d(i), 'XData', sim_state.targets(i).pos(1), ...
                'YData', sim_state.targets(i).pos(2));
        end
        if ishandle(sim_state.h_labels_2d(i)) && isvalid(sim_state.h_labels_2d(i))
            set(sim_state.h_labels_2d(i), 'Visible', 'on');
        end
        if ishandle(sim_state.h_targets_3d(i)) && isvalid(sim_state.h_targets_3d(i))
            set(sim_state.h_targets_3d(i), 'Visible', 'on');
            set(sim_state.h_targets_3d(i), 'XData', sim_state.targets(i).pos(1), ...
                'YData', sim_state.targets(i).pos(2), ...
                'ZData', sim_state.targets(i).pos(3));
        end
        if ishandle(sim_state.h_labels_3d(i)) && isvalid(sim_state.h_labels_3d(i))
            set(sim_state.h_labels_3d(i), 'Visible', 'on');
        end
        
        fprintf('  ✓ %s: Đường bay mới được tạo\n', sim_state.targets(i).name);
    end
    
    % XÓA VÀ VẼ LẠI ĐƯỜNG BAY DỰ KIẾN 3D
    cla(sim_state.ax_3d);
    
    % Vẽ lại môi trường 3D
    drawStaticElements(sim_state.ax_main, sim_state.ax_3d, ...
        sim_state.SCH, sim_state.targets_protect, sim_state.fire_units);
    
    % Vẽ lại đường bay dự kiến 3D (mới)
    drawPlannedPaths(sim_state.ax_main, sim_state.ax_3d, sim_state.targets);
    
    set(sim_state.buttons.start, 'Enable', 'on');
    set(sim_state.buttons.pause, 'Enable', 'off');
    
    setappdata(fig, 'sim_state', sim_state);
    updateAllTargetTables(sim_state);
    
    fprintf('✓ Đã reset hệ thống với đường bay mới!\n');
end