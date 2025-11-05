function updateAllTargetTables(sim_state)
    % Cập nhật bảng thông tin cho tất cả mục tiêu
    
    targets = sim_state.targets;
    target_tables = sim_state.target_tables;
    SCH = sim_state.SCH;
    targets_protect = sim_state.targets_protect;
    
    for i = 1:length(targets)
        updateSingleTargetTable(target_tables{i}, targets(i), SCH, targets_protect);
    end
    
    % Lưu lại
    sim_state.targets = targets;
    setappdata(sim_state.fig, 'sim_state', sim_state);
end