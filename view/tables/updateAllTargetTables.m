function updateAllTargetTables(state)
    % Cập nhật bảng thông tin ACY cho tất cả mục tiêu.
    % state là SimulationState handle → đọc trực tiếp, không cần setappdata.

    for i = 1:length(state.targets)
        updateSingleTargetTable(state.target_tables{i}, state.targets(i), ...
            state.SCH, state.targets_protect, state.fire_units);
    end
end