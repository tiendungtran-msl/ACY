function pauseSimulation(src, ~)
    fig = ancestor(src, 'figure');
    sim_state = getappdata(fig, 'sim_state');
    
    sim_state.is_running = false;
    
    set(sim_state.buttons.start, 'Enable', 'on');
    set(sim_state.buttons.pause, 'Enable', 'off');
    
    setappdata(fig, 'sim_state', sim_state);
    
    fprintf('⏸ Đã tạm dừng\n');
end