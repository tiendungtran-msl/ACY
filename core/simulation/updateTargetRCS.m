function updateTargetRCS(targets, fire_units)
    %% CẬP NHẬT RCS THEO CỰ LY ĐẾN DVHL
    % targets và fire_units là mảng handle → sửa trực tiếp, không cần return
    %
    % Mô hình: RCS_real = RCS_base * sqrt(D_ref / D)
    % ACY đo được: RCS_eff = RCS_real * (1 ± 10% nhiễu)

    D_ref = 100000;  % 100 km (khoảng cách tham chiếu)

    for i = 1:length(targets)
        t = targets(i);

        % Tìm DVHL gần nhất
        min_dist = inf;
        for j = 1:length(fire_units)
            d = norm(t.pos(1:2) - fire_units(j).pos(1:2));
            if d < min_dist
                min_dist = d;
            end
        end

        t.distance_to_DVHL = min_dist;

        % RCS_real theo khoảng cách
        if min_dist > 0 && min_dist < inf
            RCS_real = t.RCS * sqrt(D_ref / min_dist);
        else
            RCS_real = t.RCS;
        end
        RCS_real = max(t.RCS_min, min(t.RCS_max, RCS_real));

        t.RCS_real = RCS_real;

        % RCS_eff (đo được bởi ACY, có nhiễu ±10%)
        noise_factor = 1 + 0.1 * randn();
        t.RCS_eff = max(0.01, RCS_real * noise_factor);
    end
end