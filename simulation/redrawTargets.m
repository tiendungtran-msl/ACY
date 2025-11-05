function sim_state = redrawTargets(sim_state)
    % Vẽ lại tất cả mục tiêu
    
    for i = 1:length(sim_state.targets)
        % Xóa handles cũ
        if isvalid(sim_state.h_targets_2d(i))
            delete(sim_state.h_targets_2d(i));
        end
        if isvalid(sim_state.h_targets_3d(i))
            delete(sim_state.h_targets_3d(i));
        end
        if isvalid(sim_state.h_labels_2d(i))
            delete(sim_state.h_labels_2d(i));
        end
        if isvalid(sim_state.h_labels_3d(i))
            delete(sim_state.h_labels_3d(i));
        end
        if isvalid(sim_state.h_traj_2d(i))
            delete(sim_state.h_traj_2d(i));
        end
        if isvalid(sim_state.h_traj_3d(i))
            delete(sim_state.h_traj_3d(i));
        end
        
        % Vẽ mới nếu đang bay
        if strcmp(sim_state.targets(i).status, 'Đang bay')
            [sim_state.h_targets_2d(i), sim_state.h_labels_2d(i), sim_state.h_traj_2d(i)] = ...
                drawTarget2D(sim_state, i);
            
            [sim_state.h_targets_3d(i), sim_state.h_labels_3d(i), sim_state.h_traj_3d(i)] = ...
                drawTarget3D(sim_state, i);
        end
    end
end