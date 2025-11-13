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
    
    % *** THÊM MỚI: Tìm min/max RCS_eff ***
    all_RCS_eff = [];
    for i = 1:length(sim_state.targets)
        target = sim_state.targets(i);
        if isfield(target, 'RCS_eff')
            all_RCS_eff(end+1) = target.RCS_eff;
        else
            all_RCS_eff(end+1) = target.RCS;
        end
    end
    
    if isempty(all_RCS_eff)
        RCS_range = [0.01, 100];
    else
        RCS_range = [min(all_RCS_eff), max(all_RCS_eff)];
        if RCS_range(1) == RCS_range(2)
            RCS_range = [RCS_range(1)*0.5, RCS_range(2)*2];
        end
    end
    
    MarkerSize_range_2D = [8, 38];
    MarkerSize_range_3D = [30, 150];
    
    for i = 1:length(sim_state.targets)
        target = sim_state.targets(i);
        
        % Lấy mức độ ưu tiên
        if isfield(target, 'Bj')
            Bj = target.Bj;
        else
            Bj = 0;
        end
        
        % Lấy RCS_eff
        if isfield(target, 'RCS_eff')
            RCS_eff = target.RCS_eff;
        else
            RCS_eff = target.RCS;
        end
        
        % Tính màu
        color = ColorMapping(Bj/10, cfg);
        
        % *** THÊM MỚI: Tính marker size ***
        markerSize2D = interp1(RCS_range, MarkerSize_range_2D, RCS_eff, 'linear', 'extrap');
        markerSize2D = max(MarkerSize_range_2D(1), min(MarkerSize_range_2D(2), markerSize2D));
        
        markerSize3D = interp1(RCS_range, MarkerSize_range_3D, RCS_eff, 'linear', 'extrap');
        markerSize3D = max(MarkerSize_range_3D(1), min(MarkerSize_range_3D(2), markerSize3D));
        
        % Cập nhật 2D
        if ishandle(sim_state.h_targets_2d(i))
            set(sim_state.h_targets_2d(i), ...
                'XData', target.pos(1), ...
                'YData', target.pos(2), ...
                'MarkerFaceColor', color, ...
                'MarkerSize', markerSize2D);  % *** THÊM MỚI ***
        end
        
        % Cập nhật 3D
        if ishandle(sim_state.h_targets_3d(i))
            set(sim_state.h_targets_3d(i), ...
                'XData', target.pos(1), ...
                'YData', target.pos(2), ...
                'ZData', target.pos(3), ...
                'MarkerFaceColor', color, ...
                'MarkerSize', markerSize3D);  % *** THÊM MỚI ***
        end
        
        % Cập nhật nhãn (giữ nguyên)
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
