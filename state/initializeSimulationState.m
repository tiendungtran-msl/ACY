function sim_state = initializeSimulationState(fig, targets, SCH, ...
    targets_protect, fire_units, ax_main, ax_3d, ...
    target_tables, buttons, checkboxes)
    % Tạo cấu trúc chứa toàn bộ trạng thái mô phỏng
    
    sim_state = struct();
    
    % Dữ liệu cơ bản
    sim_state.fig = fig;
    sim_state.targets = targets;
    sim_state.SCH = SCH;
    sim_state.targets_protect = targets_protect;
    sim_state.fire_units = fire_units;
    
    % Axes
    sim_state.ax_main = ax_main;
    sim_state.ax_3d = ax_3d;
    
    % UI components
    sim_state.target_tables = target_tables;
    sim_state.buttons = buttons;
    sim_state.checkboxes = checkboxes;
    
    % Trạng thái mô phỏng
    sim_state.is_running = false;
    sim_state.time = 0;
    
    % Handles đồ họa động
    sim_state.h_targets_2d = gobjects(length(targets), 1);
    sim_state.h_targets_3d = gobjects(length(targets), 1);
    sim_state.h_labels_2d = gobjects(length(targets), 1);
    sim_state.h_labels_3d = gobjects(length(targets), 1);
    sim_state.h_traj_2d = gobjects(length(targets), 1);
    sim_state.h_traj_3d = gobjects(length(targets), 1);
    
    % Quỹ đạo
    sim_state.trajectories = cell(length(targets), 1);
    for i = 1:length(targets)
        sim_state.trajectories{i} = targets(i).pos;
    end
    
    % Lưu vào figure
    setappdata(fig, 'sim_state', sim_state);

    % Timer cho cập nhật bảng
    sim_state.last_table_update = 0;
    sim_state.last_draw = 0;  % ← THÊM DÒNG NÀY
end