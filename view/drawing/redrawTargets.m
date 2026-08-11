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