function redrawTargets(state)
    %% VẼ LẠI TẤT CẢ MỤC TIÊU
    % state là SimulationState handle → sửa trực tiếp, không cần return
    % Chỉ hiển thị khi mục tiêu trong vùng quan sát (60km)

    OBSERVATION_RADIUS = 60000;

    for i = 1:length(state.targets)
        target = state.targets(i);  % handle reference

        if strcmp(target.status, 'Đang bay')

            % ── Kiểm tra vùng quan sát ──────────────────────────
            in_zone = isTargetInObservationZone(target, state.SCH, OBSERVATION_RADIUS);
            target.in_observation_zone = in_zone;

            % ── Tính tham số hiển thị (1 lần) ───────────────────
            Bj       = calculateThreatLevel(target, state.SCH.pos(1:2), ...
                           state.targets_protect, state.fire_units);
            color    = getThreatColor(Bj);
            bg_color = getThreatBackgroundColor(Bj);
            dist_km  = norm(target.pos(1:2) - state.SCH.pos(1:2)) / 1000;
            RCS_disp = target.RCS_eff;

            % ── 2D marker ───────────────────────────────────────
            if ishandle(state.h_targets_2d(i)) && isvalid(state.h_targets_2d(i))
                sz = markerSizeFromRCS_local(RCS_disp, 8, 30, 0.01, 20);
                set(state.h_targets_2d(i), ...
                    'XData', target.pos(1), 'YData', target.pos(2), ...
                    'MarkerFaceColor', color, 'MarkerSize', sz);
            else
                [h_tgt, h_lbl, h_traj] = drawTarget2D(state, i);
                state.h_targets_2d(i) = h_tgt;
                state.h_labels_2d(i)  = h_lbl;
                state.h_traj_2d(i)    = h_traj;
            end

            % ── 2D label ────────────────────────────────────────
            if ishandle(state.h_labels_2d(i)) && isvalid(state.h_labels_2d(i))
                if in_zone
                    if target.priority_from_command
                        lbl = sprintf('⚡ %s\nBj=%.2f\nRCS=%.2f | h=%.0fm | D=%.1fkm', ...
                            target.name, Bj, RCS_disp, target.pos(3), dist_km);
                    else
                        lbl = sprintf('%s\nBj=%.2f\nRCS=%.2f | h=%.0fm | D=%.1fkm', ...
                            target.name, Bj, RCS_disp, target.pos(3), dist_km);
                    end
                    set(state.h_labels_2d(i), ...
                        'Position', [target.pos(1)+2000, target.pos(2)+2000, 0], ...
                        'String', lbl, 'BackgroundColor', bg_color, ...
                        'EdgeColor', color, 'Visible', 'on');
                else
                    set(state.h_labels_2d(i), 'Visible', 'off');
                end
            end

            % ── 2D quỹ đạo ──────────────────────────────────────
            if size(target.trajectory_history, 1) > 1
                if ishandle(state.h_traj_2d(i)) && isvalid(state.h_traj_2d(i))
                    set(state.h_traj_2d(i), ...
                        'XData', target.trajectory_history(:,1), ...
                        'YData', target.trajectory_history(:,2), ...
                        'Color', color * 0.6);
                else
                    state.h_traj_2d(i) = plot(state.ax_main, ...
                        target.trajectory_history(:,1), ...
                        target.trajectory_history(:,2), '-', ...
                        'Color', color * 0.6, 'LineWidth', 1.8);
                end
            end

            % ── 3D marker ───────────────────────────────────────
            if ishandle(state.h_targets_3d(i)) && isvalid(state.h_targets_3d(i))
                set(state.h_targets_3d(i), ...
                    'XData', target.pos(1), 'YData', target.pos(2), ...
                    'ZData', target.pos(3), 'MarkerFaceColor', color);
            else
                [h_tgt, h_lbl, h_traj] = drawTarget3D(state, i);
                state.h_targets_3d(i) = h_tgt;
                state.h_labels_3d(i)  = h_lbl;
                state.h_traj_3d(i)    = h_traj;
            end

            % ── 3D label ────────────────────────────────────────
            if ishandle(state.h_labels_3d(i)) && isvalid(state.h_labels_3d(i))
                if in_zone
                    if target.priority_from_command
                        lbl = sprintf('⚡ %s\nBj=%.2f\nRCS=%.2f | h=%.0fm', ...
                            target.name, Bj, RCS_disp, target.pos(3));
                    else
                        lbl = sprintf('%s\nBj=%.2f\nRCS=%.2f | h=%.0fm', ...
                            target.name, Bj, RCS_disp, target.pos(3));
                    end
                    set(state.h_labels_3d(i), ...
                        'Position', [target.pos(1), target.pos(2), target.pos(3)+1500], ...
                        'String', lbl, 'BackgroundColor', bg_color, ...
                        'EdgeColor', color, 'Visible', 'on');
                else
                    set(state.h_labels_3d(i), 'Visible', 'off');
                end
            end

            % ── 3D quỹ đạo ──────────────────────────────────────
            traj = state.trajectories{i};
            if size(traj, 1) > 1 && ishandle(state.h_traj_3d(i)) && isvalid(state.h_traj_3d(i))
                set(state.h_traj_3d(i), ...
                    'XData', traj(:,1), 'YData', traj(:,2), 'ZData', traj(:,3));
            end

        else
            % Ẩn mục tiêu đã hoàn thành
            handles2d = [state.h_targets_2d(i), state.h_labels_2d(i)];
            handles3d = [state.h_targets_3d(i), state.h_labels_3d(i)];
            for h = [handles2d, handles3d]
                if ishandle(h) && isvalid(h)
                    set(h, 'Visible', 'off');
                end
            end
        end
    end
end

%% ── Hàm phụ nội bộ ──────────────────────────────────────────────────────
function sz = markerSizeFromRCS_local(RCS_eff, base, span, RCS_min, RCS_max)
    if RCS_max <= RCS_min
        sz = base + span / 2;
        return;
    end
    x  = (RCS_eff - RCS_min) / (RCS_max - RCS_min);
    sz = base + max(0, min(1, x)) * span;
end
    
    % Bán kính vùng quan sát
    observation_radius = 60000;  % 60km
    
    for i = 1:length(sim_state.targets)
        target = sim_state.targets(i);
        
        if strcmp(target.status, 'Đang bay')
            % ═══════════════════════════════════════════════════════
            % KIỂM TRA MỤC TIÊU CÓ TRONG VÙNG QUAN SÁT KHÔNG
            % ═══════════════════════════════════════════════════════
            in_observation_zone = isTargetInObservationZone(target, sim_state.SCH, observation_radius);
            
            % Lưu trạng thái vào target
            sim_state.targets(i).in_observation_zone = in_observation_zone;
            
            % ═══════════════════════════════════════════════════════
            % TÍNH CÁC THAM SỐ (1 LẦN DUY NHẤT)
            % ═══════════════════════════════════════════════════════
            Bj = calculateThreatLevel(target, sim_state.SCH.pos(1:2), ...
                sim_state.targets_protect, sim_state.fire_units);
            color = getThreatColor(Bj);
            bg_color = getThreatBackgroundColor(Bj);
            
            dist_to_sch = norm(target.pos(1:2) - sim_state.SCH.pos(1:2)) / 1000;
            
            if isfield(target, 'RCS_eff')
                RCS_display = target.RCS_eff;
            else
                RCS_display = target.RCS;
            end
            
            % ════════════════════════════════════════════
            % CẬP NHẬT 2D
            % ════════════════════════════════════════════
            if ishandle(sim_state.h_targets_2d(i)) && isvalid(sim_state.h_targets_2d(i))
                set(sim_state.h_targets_2d(i), ...
                    'XData', target.pos(1), ...
                    'YData', target.pos(2), ...
                    'MarkerFaceColor', color);
                
                if isfield(target, 'RCS_eff')
                    markerSize = markerSizeFromRCS_local(target.RCS_eff, 8, 30, 0.01, 20);
                    set(sim_state.h_targets_2d(i), 'MarkerSize', markerSize);
                end
            else
                [sim_state.h_targets_2d(i), sim_state.h_labels_2d(i), sim_state.h_traj_2d(i)] = ...
                    drawTarget2D(sim_state, i);
            end
            
            % Label 2D - CHỈ HIỂN THỊ KHI TRONG VÙNG
            if ishandle(sim_state.h_labels_2d(i)) && isvalid(sim_state.h_labels_2d(i))
                if in_observation_zone
                    % TRONG VÙNG → Hiển thị label đầy đủ
                    if target.priority_from_command
                        label_text = sprintf('⚡ %s\nBj=%.2f\nRCS=%.2f | h=%.0fm | D=%.1fkm', ...
                            target.name, Bj, RCS_display, target.pos(3), dist_to_sch);
                    else
                        label_text = sprintf('%s\nBj=%.2f\nRCS=%.2f | h=%.0fm | D=%.1fkm', ...
                            target.name, Bj, RCS_display, target.pos(3), dist_to_sch);
                    end
                    
                    set(sim_state.h_labels_2d(i), ...
                        'Position', [target.pos(1)+2000, target.pos(2)+2000, 0], ...
                        'String', label_text, ...
                        'BackgroundColor', bg_color, ...
                        'EdgeColor', color, ...
                        'Visible', 'on');
                else
                    % NGOÀI VÙNG → Ẩn label
                    set(sim_state.h_labels_2d(i), 'Visible', 'off');
                end
            end
            
            % Quỹ đạo 2D
            if isfield(target, 'trajectory_history') && size(target.trajectory_history, 1) > 1
                if ishandle(sim_state.h_traj_2d(i)) && isvalid(sim_state.h_traj_2d(i))
                    set(sim_state.h_traj_2d(i), ...
                        'XData', target.trajectory_history(:,1), ...
                        'YData', target.trajectory_history(:,2), ...
                        'Color', color * 0.6);
                else
                    sim_state.h_traj_2d(i) = plot(sim_state.ax_main, ...
                        target.trajectory_history(:,1), ...
                        target.trajectory_history(:,2), '-', ...
                        'Color', color * 0.6, ...
                        'LineWidth', 1.8);
                end
            end
            
            % ════════════════════════════════════════════
            % CẬP NHẬT 3D
            % ════════════════════════════════════════════
            if ishandle(sim_state.h_targets_3d(i)) && isvalid(sim_state.h_targets_3d(i))
                set(sim_state.h_targets_3d(i), ...
                    'XData', target.pos(1), ...
                    'YData', target.pos(2), ...
                    'ZData', target.pos(3), ...
                    'MarkerFaceColor', color);
            else
                [sim_state.h_targets_3d(i), sim_state.h_labels_3d(i), sim_state.h_traj_3d(i)] = ...
                    drawTarget3D(sim_state, i);
            end
            
            % Label 3D - CHỈ HIỂN THỊ KHI TRONG VÙNG
            if ishandle(sim_state.h_labels_3d(i)) && isvalid(sim_state.h_labels_3d(i))
                if in_observation_zone
                    % TRONG VÙNG → Hiển thị label
                    if target.priority_from_command
                        label_text = sprintf('⚡ %s\nBj=%.2f\nRCS=%.2f | h=%.0fm', ...
                            target.name, Bj, RCS_display, target.pos(3));
                    else
                        label_text = sprintf('%s\nBj=%.2f\nRCS=%.2f | h=%.0fm', ...
                            target.name, Bj, RCS_display, target.pos(3));
                    end
                    
                    set(sim_state.h_labels_3d(i), ...
                        'Position', [target.pos(1), target.pos(2), target.pos(3)+1500], ...
                        'String', label_text, ...
                        'BackgroundColor', bg_color, ...
                        'EdgeColor', color, ...
                        'Visible', 'on');
                else
                    % NGOÀI VÙNG → Ẩn label
                    set(sim_state.h_labels_3d(i), 'Visible', 'off');
                end
            end
            
            % Quỹ đạo 3D
            if isfield(sim_state, 'trajectories') && length(sim_state.trajectories) >= i
                traj = sim_state.trajectories{i};
                if size(traj, 1) > 1 && ishandle(sim_state.h_traj_3d(i)) && isvalid(sim_state.h_traj_3d(i))
                    set(sim_state.h_traj_3d(i), ...
                        'XData', traj(:,1), ...
                        'YData', traj(:,2), ...
                        'ZData', traj(:,3));
                end
            end
            
        else
            % Ẩn mục tiêu đã hoàn thành
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