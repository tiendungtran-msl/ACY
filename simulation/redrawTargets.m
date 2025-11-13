function sim_state = redrawTargets(sim_state)
    %% VẼ LẠI TẤT CẢ MỤC TIÊU (CẬP NHẬT VỊ TRÍ, KHÔNG XÓA/TẠO MỚI)
    
    for i = 1:length(sim_state.targets)
        target = sim_state.targets(i);
        
        if strcmp(target.status, 'Đang bay')
            % ════════════════════════════════════════════
            % CẬP NHẬT 2D
            % ════════════════════════════════════════════
            if ishandle(sim_state.h_targets_2d(i)) && isvalid(sim_state.h_targets_2d(i))
                % Cập nhật vị trí marker
                set(sim_state.h_targets_2d(i), ...
                    'XData', target.pos(1), ...
                    'YData', target.pos(2));
                
                % Cập nhật màu theo Bj
                Bj = calculateThreatLevel(target, sim_state.SCH.pos(1:2), ...
                    sim_state.targets_protect, sim_state.fire_units);
                color = getThreatColor(Bj);
                set(sim_state.h_targets_2d(i), 'MarkerFaceColor', color);
                
                % Cập nhật kích thước marker theo RCS_eff
                if isfield(target, 'RCS_eff')
                    markerSize = markerSizeFromRCS_local(target.RCS_eff, 8, 30, 0.01, 20);
                    set(sim_state.h_targets_2d(i), 'MarkerSize', markerSize);
                end
            else
                % Tạo mới nếu chưa có
                [sim_state.h_targets_2d(i), sim_state.h_labels_2d(i), sim_state.h_traj_2d(i)] = ...
                    drawTarget2D(sim_state, i);
            end
            
            % Cập nhật label 2D
            if ishandle(sim_state.h_labels_2d(i)) && isvalid(sim_state.h_labels_2d(i))
                set(sim_state.h_labels_2d(i), ...
                    'Position', [target.pos(1)+2000, target.pos(2)+2000, 0]);
            end
            
            % Cập nhật quỹ đạo 2D (CHỈ PHẦN ĐÃ ĐI QUA)
            if isfield(target, 'trajectory_history') && size(target.trajectory_history, 1) > 1
                if ishandle(sim_state.h_traj_2d(i)) && isvalid(sim_state.h_traj_2d(i))
                    set(sim_state.h_traj_2d(i), ...
                        'XData', target.trajectory_history(:,1), ...
                        'YData', target.trajectory_history(:,2));
                else
                    % Tạo mới trajectory line
                    Bj = calculateThreatLevel(target, sim_state.SCH.pos(1:2), ...
                        sim_state.targets_protect, sim_state.fire_units);
                    color = getThreatColor(Bj);
                    sim_state.h_traj_2d(i) = plot(sim_state.ax_main, ...
                        target.trajectory_history(:,1), ...
                        target.trajectory_history(:,2), '-', ...
                        'Color', color * 0.6, ...
                        'LineWidth', 1.8);
                end
            end
            
            % ════════════════════════════════════════════
            % CẬP NHẬT 3D (MARKER CỐ ĐỊNH KÍCH THƯỚC)
            % ════════════════════════════════════════════
            if ishandle(sim_state.h_targets_3d(i)) && isvalid(sim_state.h_targets_3d(i))
                % Cập nhật vị trí marker
                set(sim_state.h_targets_3d(i), ...
                    'XData', target.pos(1), ...
                    'YData', target.pos(2), ...
                    'ZData', target.pos(3));
                
                % Cập nhật màu theo Bj
                Bj = calculateThreatLevel(target, sim_state.SCH.pos(1:2), ...
                    sim_state.targets_protect, sim_state.fire_units);
                color = getThreatColor(Bj);
                set(sim_state.h_targets_3d(i), 'MarkerFaceColor', color);
                
                % KHÔNG thay đổi MarkerSize (cố định)
            else
                % Tạo mới nếu chưa có
                [sim_state.h_targets_3d(i), sim_state.h_labels_3d(i), sim_state.h_traj_3d(i)] = ...
                    drawTarget3D(sim_state, i);
            end
            
            % Cập nhật label 3D
            if ishandle(sim_state.h_labels_3d(i)) && isvalid(sim_state.h_labels_3d(i))
                set(sim_state.h_labels_3d(i), ...
                    'Position', [target.pos(1), target.pos(2), target.pos(3)+1500]);
            end
            
            % Cập nhật quỹ đạo 3D (TOÀN BỘ)
            if isfield(sim_state, 'trajectories') && length(sim_state.trajectories) >= i
                traj = sim_state.trajectories{i};
                if size(traj, 1) > 1
                    if ishandle(sim_state.h_traj_3d(i)) && isvalid(sim_state.h_traj_3d(i))
                        set(sim_state.h_traj_3d(i), ...
                            'XData', traj(:,1), ...
                            'YData', traj(:,2), ...
                            'ZData', traj(:,3));
                    end
                end
            end
            
        else
            % Mục tiêu đã hoàn thành - ẨN đi
            if ishandle(sim_state.h_targets_2d(i)) && isvalid(sim_state.h_targets_2d(i))
                set(sim_state.h_targets_2d(i), 'Visible', 'off');
            end
            if ishandle(sim_state.h_labels_2d(i)) && isvalid(sim_state.h_labels_2d(i))
                set(sim_state.h_labels_2d(i), 'Visible', 'off');
            end
            if ishandle(sim_state.h_targets_3d(i)) && isvalid(sim_state.h_targets_3d(i))
                set(sim_state.h_targets_3d(i), 'Visible', 'off');
            end
            if ishandle(sim_state.h_labels_3d(i)) && isvalid(sim_state.h_labels_3d(i))
                set(sim_state.h_labels_3d(i), 'Visible', 'off');
            end
        end
    end
end

function sz = markerSizeFromRCS_local(RCS_eff, base, span, RCS_min, RCS_max)
    if RCS_max <= RCS_min
        sz = base + span / 2;
        return;
    end
    x = (RCS_eff - RCS_min) / (RCS_max - RCS_min);
    x = max(0, min(1, x));
    sz = base + x * span;
end