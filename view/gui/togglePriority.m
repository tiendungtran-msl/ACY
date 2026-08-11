function togglePriority(src, target_id)
    % Thin wrapper — SimulationState.bindCallbacks() đã ghi đè callback này.
    % Giữ lại để tương thích nếu có lời gọi cũ.
    state = getappdata(ancestor(src, 'figure'), 'sim_state');
    state.togglePriority(target_id, get(src, 'Value'));
end