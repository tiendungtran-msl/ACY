function UpdateAnimation(sim_state, cfg)
    %% CẬP NHẬT ANIMATION
    % Mô tả: Cập nhật hiển thị animation cho mỗi frame
    % Input:
    %   - sim_state: Trạng thái mô phỏng
    %   - cfg: Cấu hình hệ thống (optional)
    
    if nargin < 2
        cfg = config();
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẬP NHẬT VỊ TRÍ MỤC TIÊU
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    for i = 1:length(sim_state.targets)
        target = sim_state.targets(i);
        
        % Lấy mức độ ưu tiên
        if isfield(target, 'Bj')
            Bj = target.Bj;
        else
            Bj = 0;
        end
        
        % Tính màu
        color = ColorMapping(Bj/10, cfg);
        
        % Cập nhật 2D
        if ishandle(sim_state.h_targets_2d(i))
            set(sim_state.h_targets_2d(i), ...
                'XData', target.pos(1), ...
                'YData', target.pos(2), ...
                'MarkerFaceColor', color);
        end
        
        % Cập nhật 3D
        if ishandle(sim_state.h_targets_3d(i))
            set(sim_state.h_targets_3d(i), ...
                'XData', target.pos(1), ...
                'YData', target.pos(2), ...
                'ZData', target.pos(3), ...
                'MarkerFaceColor', color);
        end
        
        % Cập nhật nhãn
        if cfg.display_labels
            if ishandle(sim_state.h_labels_2d(i))
                set(sim_state.h_labels_2d(i), ...
                    'Position', [target.pos(1), target.pos(2)+1500], ...
                    'Color', color);
            end
            
            if ishandle(sim_state.h_labels_3d(i))
                set(sim_state.h_labels_3d(i), ...
                    'Position', [target.pos(1), target.pos(2), target.pos(3)+1000], ...
                    'Color', color);
            end
        end
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẬP NHẬT QUỸ ĐẠO
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if cfg.display_trajectory
        for i = 1:length(sim_state.targets)
            % Cập nhật quỹ đạo 2D
            if ishandle(sim_state.h_traj_2d(i))
                traj = sim_state.trajectories{i};
                set(sim_state.h_traj_2d(i), ...
                    'XData', traj(:,1), ...
                    'YData', traj(:,2));
            end
            
            % Cập nhật quỹ đạo 3D
            if ishandle(sim_state.h_traj_3d(i))
                traj = sim_state.trajectories{i};
                set(sim_state.h_traj_3d(i), ...
                    'XData', traj(:,1), ...
                    'YData', traj(:,2), ...
                    'ZData', traj(:,3));
            end
        end
    end
    
    % Làm mới màn hình
    drawnow;
    
end
