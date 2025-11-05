function resetSimulation(src)
    % Reset mô phỏng về trạng thái ban đầu
    fig = ancestor(src, 'figure');
    sim_state = getappdata(fig, 'sim_state');
    
    sim_state.is_running = false;
    sim_state.time = 0;
    
    % Reset vị trí mục tiêu
    for i = 1:length(sim_state.targets)
        sim_state.targets(i).path_index = 1;
        sim_state.targets(i).pos(1:2) = sim_state.targets(i).smooth_path(1,:);
        sim_state.targets(i).status = 'Đang bay';
        sim_state.trajectories{i} = sim_state.targets(i).pos;
    end
    
    set(sim_state.buttons.start, 'Enable', 'on');
    set(sim_state.buttons.pause, 'Enable', 'off');
    
    setappdata(fig, 'sim_state', sim_state);
    updateAllTargetTables(sim_state);
    
    fprintf('🔄 Đã reset hệ thống\n');
end