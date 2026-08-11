function tgt = createTarget(id, name, type, speed_cruise, RCS, maneuver, ...
                            task, jam_type, group_size, waypoints, color, marker)
    %% TẠO TARGET OBJECT (thin wrapper → Target class)
    % Toàn bộ logic khởi tạo (RCS_min/max, speed_min/max, accel_max...)
    % đã được chuyển vào Target constructor và initTypeParams().
    tgt = Target(id, name, type, speed_cruise, RCS, maneuver, ...
                 task, jam_type, group_size, waypoints, color, marker);
end