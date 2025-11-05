function targets = createSmoothPaths(targets)
    % Tạo đường cong mượt bằng spline interpolation
    
    for i = 1:length(targets)
        wp = targets(i).waypoints;
        n_wp = size(wp, 1);
        
        % Tính tham số t (cumulative distance)
        t_wp = zeros(n_wp, 1);
        for j = 2:n_wp
            t_wp(j) = t_wp(j-1) + norm(wp(j,:) - wp(j-1,:));
        end
        
        % Chuẩn hóa về [0, 1]
        if t_wp(end) > 0
            t_wp = t_wp / t_wp(end);
        end
        
        % Tính số điểm nội suy (100m/điểm)
        total_dist = t_wp(end) * norm(wp(end,:) - wp(1,:));
        n_points = max(100, ceil(total_dist / 100));
        t_smooth = linspace(0, 1, n_points);
        
        % Spline interpolation
        if n_wp >= 3
            smooth_x = pchip(t_wp, wp(:,1), t_smooth);
            smooth_y = pchip(t_wp, wp(:,2), t_smooth);
        else
            smooth_x = interp1(t_wp, wp(:,1), t_smooth, 'linear');
            smooth_y = interp1(t_wp, wp(:,2), t_smooth, 'linear');
        end
        
        % Lưu đường cong
        targets(i).smooth_path = [smooth_x', smooth_y'];
        targets(i).pos(1:2) = targets(i).smooth_path(1,:);
        
        fprintf('  - %s: %d waypoints → %d điểm\n', ...
                targets(i).name, n_wp, n_points);
    end
end