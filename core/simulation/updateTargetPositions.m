function updateTargetPositions(state, dt)
    % Cập nhật vị trí tất cả mục tiêu và lưu lịch sử quỹ đạo
    % state là SimulationState handle → sửa trực tiếp, không cần return

    for i = 1:length(state.targets)
        if strcmp(state.targets(i).status, 'Đang bay')
            moveTargetAlongPath(state.targets(i), dt);   % sửa target in-place

            % Ghi quỹ đạo 3D vào state
            traj = state.trajectories;
            traj{i} = [traj{i}; state.targets(i).pos];
            state.trajectories = traj;
        end
    end
end