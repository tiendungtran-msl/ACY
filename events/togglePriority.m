function togglePriority(src, target_id)
    % Bật/tắt ưu tiên cho mục tiêu
    fig = ancestor(src, 'figure');
    sim_state = getappdata(fig, 'sim_state');
    
    sim_state.targets(target_id).priority_from_command = get(src, 'Value');
    
    setappdata(fig, 'sim_state', sim_state);
    updateAllTargetTables(sim_state);
    
    if sim_state.targets(target_id).priority_from_command
        fprintf('⚡ %s được đánh dấu ƯU TIÊN từ cấp trên\n', ...
                sim_state.targets(target_id).name);
    else
        fprintf('○ Bỏ ưu tiên %s\n', sim_state.targets(target_id).name);
    end
end