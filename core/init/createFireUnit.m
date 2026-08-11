function fu = createFireUnit(name, pos)
    %% TẠO FIREUNIT OBJECT (thin wrapper → FireUnit class)
    % Tham số mặc định S-125 Neva:
    %   range_min = 3500m, range_max = 35000m, H_min = 100m, H_max = 25000m, channels = 2
    fu = FireUnit(name, 'S-125', pos, 3500, 35000, 100, 25000, 2);
end