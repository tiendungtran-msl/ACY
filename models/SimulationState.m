classdef SimulationState < handle
    %% SIMULATIONSTATE - Trạng thái mô phỏng trung tâm
    %
    % Handle class: không copy khi truyền vào function.
    % Quản lý toàn bộ vòng đời mô phỏng: khởi tạo, chạy, dừng, reset.
    % Thay thế pattern getappdata/setappdata bằng reference semantics.
    %
    % Sử dụng:
    %   state = SimulationState(fig, targets, SCH, targets_protect, ...
    %                           fire_units, ax_main, ax_3d, ...
    %                           target_tables, buttons, checkboxes);
    %   updateAllTargetTables(state);

    properties
        % --- Dữ liệu cốt lõi ---
        targets          % 1×N mảng Target objects
        SCH              % struct: .name, .pos
        targets_protect  % struct array
        fire_units       % 1×M mảng FireUnit objects

        % --- Giao diện ---
        fig
        ax_main
        ax_3d
        target_tables    % cell array của uitable handles
        buttons          % struct: .start, .pause, .reset
        checkboxes       % cell array của uicontrol handles

        % --- Trạng thái mô phỏng ---
        is_running = false
        time = 0
        last_table_update = 0

        % --- Graphics handles ---
        h_targets_2d     % gobjects array
        h_targets_3d
        h_labels_2d
        h_labels_3d
        h_traj_2d
        h_traj_3d
        trajectories     % cell array quỹ đạo 3D {Kx3}
    end

    methods

        %% ════════════════════════════════════════════════════════
        %  KHỞI TẠO
        %% ════════════════════════════════════════════════════════
        function obj = SimulationState(fig, targets, SCH, targets_protect, ...
                                        fire_units, ax_main, ax_3d, ...
                                        target_tables, buttons, checkboxes)
            obj.fig             = fig;
            obj.targets         = targets;
            obj.SCH             = SCH;
            obj.targets_protect = targets_protect;
            obj.fire_units      = fire_units;
            obj.ax_main         = ax_main;
            obj.ax_3d           = ax_3d;
            obj.target_tables   = target_tables;
            obj.buttons         = buttons;
            obj.checkboxes      = checkboxes;

            n = length(targets);
            obj.h_targets_2d = gobjects(n, 1);
            obj.h_targets_3d = gobjects(n, 1);
            obj.h_labels_2d  = gobjects(n, 1);
            obj.h_labels_3d  = gobjects(n, 1);
            obj.h_traj_2d    = gobjects(n, 1);
            obj.h_traj_3d    = gobjects(n, 1);
            obj.trajectories = cell(n, 1);
            for i = 1:n
                obj.trajectories{i} = targets(i).pos;
            end

            % Lưu handle vào figure (một lần duy nhất - không cần setappdata lại)
            setappdata(fig, 'sim_state', obj);

            % Đăng ký callbacks vào các nút
            obj.bindCallbacks();
        end

        %% ════════════════════════════════════════════════════════
        %  ĐĂNG KÝ CALLBACKS
        %% ════════════════════════════════════════════════════════
        function bindCallbacks(obj)
            % Gán callbacks sau khi đã có state (tránh chicken-and-egg)
            set(obj.buttons.start, 'Callback', @(~,~) obj.start());
            set(obj.buttons.pause, 'Callback', @(~,~) obj.pause());
            set(obj.buttons.reset, 'Callback', @(~,~) obj.reset());

            for i = 1:length(obj.checkboxes)
                idx = i;  % capture by value
                set(obj.checkboxes{idx}, 'Callback', ...
                    @(s,~) obj.togglePriority(idx, get(s, 'Value')));
            end
        end

        %% ════════════════════════════════════════════════════════
        %  BẮT ĐẦU MÔ PHỎNG
        %% ════════════════════════════════════════════════════════
        function start(obj)
            obj.is_running = true;
            set(obj.buttons.start, 'Enable', 'off');
            set(obj.buttons.pause, 'Enable', 'on');

            if obj.time == 0
                fprintf('\n▶ Bắt đầu mô phỏng...\n');
            else
                fprintf('\n▶ Tiếp tục từ t=%.1fs...\n', obj.time);
            end

            obj.runLoop();
        end

        %% ════════════════════════════════════════════════════════
        %  TẠM DỪNG
        %% ════════════════════════════════════════════════════════
        function pause(obj)
            obj.is_running = false;
            set(obj.buttons.start, 'Enable', 'on');
            set(obj.buttons.pause, 'Enable', 'off');
            fprintf('⏸ Đã tạm dừng tại t=%.1fs\n', obj.time);
        end

        %% ════════════════════════════════════════════════════════
        %  RESET VỀ TRẠNG THÁI BAN ĐẦU
        %% ════════════════════════════════════════════════════════
        function reset(obj)
            obj.is_running = false;
            obj.time = 0;
            obj.last_table_update = 0;

            fprintf('🔄 Đang reset hệ thống...\n');

            if isappdata(obj.fig, 'measurement_errors')
                rmappdata(obj.fig, 'measurement_errors');
            end

            % Tạo lại đường bay ngẫu nhiên mới
            createSmoothPaths(obj.targets);

            for i = 1:length(obj.targets)
                t = obj.targets(i);
                t.path_index       = 1;
                t.pos              = t.smooth_path(1, :);
                t.status           = 'Đang bay';
                t.speed            = t.speed_cruise;
                t.current_accel    = 0;
                t.vel              = [0, 0, 0];
                t.trajectory_history = t.pos(1:2);
                obj.trajectories{i}  = t.pos;

                % Xóa đường bay cũ
                if ishandle(obj.h_traj_2d(i)) && isvalid(obj.h_traj_2d(i))
                    delete(obj.h_traj_2d(i));
                    obj.h_traj_2d(i) = gobjects(1);
                end
                if ishandle(obj.h_traj_3d(i)) && isvalid(obj.h_traj_3d(i))
                    delete(obj.h_traj_3d(i));
                    obj.h_traj_3d(i) = gobjects(1);
                end

                % Hiện lại markers và labels
                if ishandle(obj.h_targets_2d(i)) && isvalid(obj.h_targets_2d(i))
                    set(obj.h_targets_2d(i), 'Visible', 'on', ...
                        'XData', t.pos(1), 'YData', t.pos(2));
                end
                if ishandle(obj.h_labels_2d(i)) && isvalid(obj.h_labels_2d(i))
                    set(obj.h_labels_2d(i), 'Visible', 'on');
                end
                if ishandle(obj.h_targets_3d(i)) && isvalid(obj.h_targets_3d(i))
                    set(obj.h_targets_3d(i), 'Visible', 'on', ...
                        'XData', t.pos(1), 'YData', t.pos(2), 'ZData', t.pos(3));
                end
                if ishandle(obj.h_labels_3d(i)) && isvalid(obj.h_labels_3d(i))
                    set(obj.h_labels_3d(i), 'Visible', 'on');
                end

                fprintf('  ✓ %s: đường bay mới\n', t.name);
            end

            % Vẽ lại môi trường 3D
            cla(obj.ax_3d);
            drawStaticElements(obj.ax_main, obj.ax_3d, ...
                obj.SCH, obj.targets_protect, obj.fire_units);
            drawPlannedPaths(obj.ax_main, obj.ax_3d, obj.targets);

            % Cập nhật bảng
            updateAllTargetTables(obj);

            set(obj.buttons.start, 'Enable', 'on');
            set(obj.buttons.pause, 'Enable', 'off');

            fprintf('✓ Đã reset với đường bay mới!\n');
        end

        %% ════════════════════════════════════════════════════════
        %  BẬT/TẮT ƯU TIÊN TỪ CẤP TRÊN
        %% ════════════════════════════════════════════════════════
        function togglePriority(obj, target_idx, value)
            obj.targets(target_idx).priority_from_command = logical(value);
            updateAllTargetTables(obj);

            if value
                fprintf('⚡ %s được đánh dấu ƯU TIÊN\n', obj.targets(target_idx).name);
            else
                fprintf('○ Bỏ ưu tiên %s\n', obj.targets(target_idx).name);
            end
        end

        %% ════════════════════════════════════════════════════════
        %  VÒNG LẶP CHÍNH
        %% ════════════════════════════════════════════════════════
        function runLoop(obj)
            dt       = 1;    % bước thời gian (s)
            max_time = 200;  % thời gian tối đa (s)

            fprintf('▶ Bắt đầu vòng lặp (t=%.1fs)...\n', obj.time);

            while obj.is_running && obj.time < max_time

                obj.time = obj.time + dt;

                % 1. Cập nhật vị trí và quỹ đạo
                updateTargetPositions(obj, dt);

                % 2. Cập nhật RCS theo cự ly
                updateTargetRCS(obj.targets, obj.fire_units);

                % 3. Vẽ lại
                redrawTargets(obj);

                % 4. Cập nhật bảng (mỗi 0.5 giây)
                if obj.time - obj.last_table_update >= 0.5
                    updateAllTargetTables(obj);
                    obj.last_table_update = obj.time;
                end

                drawnow;
                pause(0.05);

                % Kiểm tra điều kiện kết thúc
                n_active = 0;
                for k = 1:length(obj.targets)
                    if strcmp(obj.targets(k).status, 'Đang bay')
                        n_active = n_active + 1;
                    end
                end

                if n_active == 0
                    fprintf('\n✓ Tất cả mục tiêu hoàn thành tại t=%.1fs!\n', obj.time);
                    obj.is_running = false;
                    break;
                end
            end

            if obj.time >= max_time
                fprintf('\n⏱ Đạt thời gian tối đa: %.1fs\n', max_time);
            end

            set(obj.buttons.start, 'Enable', 'on');
            set(obj.buttons.pause, 'Enable', 'off');

            fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        end

    end % methods
end % classdef
