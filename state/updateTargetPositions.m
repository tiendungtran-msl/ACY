function sim_state = updateTargetPositions(sim_state, dt)
    % Cập nhật vị trí tất cả mục tiêu
    
    for i = 1:length(sim_state.targets)
        if strcmp(sim_state.targets(i).status, 'Đang bay')
            sim_state.targets(i) = moveTargetAlongPath(sim_state.targets(i), dt);
            sim_state.trajectories{i} = [sim_state.trajectories{i}; sim_state.targets(i).pos];
        end
    end
end