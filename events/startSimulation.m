function startSimulation(src)
    fig = ancestor(src, 'figure');
    sim_state = getappdata(fig, 'sim_state');
    
    sim_state.is_running = true;
    set(sim_state.buttons.start, 'Enable', 'off');
    set(sim_state.buttons.pause, 'Enable', 'on');
    
    setappdata(fig, 'sim_state', sim_state);
    
    if sim_state.time == 0
        fprintf('\n▶ Bắt đầu mô phỏng...\n');
    else
        fprintf('\n▶ Tiếp tục từ t=%.1fs...\n', sim_state.time);
    end
    
    runMainLoop(sim_state);
end