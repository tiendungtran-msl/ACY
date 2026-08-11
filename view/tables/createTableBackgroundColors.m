function bg_colors = createTableBackgroundColors(n_rows, Bj)
    % Tạo ma trận màu nền cho bảng [n_rows × 3]
    
    % Chọn màu dựa trên Bj
    if Bj >= 0.8
        color1 = [0.3, 0.05, 0.05];
        color2 = [0.25, 0.05, 0.05];
    elseif Bj >= 0.6
        color1 = [0.3, 0.15, 0.05];
        color2 = [0.25, 0.12, 0.05];
    elseif Bj >= 0.4
        color1 = [0.2, 0.2, 0.05];
        color2 = [0.18, 0.18, 0.05];
    elseif Bj > 0
        color1 = [0.1, 0.1, 0.15];
        color2 = [0.15, 0.15, 0.2];
    else
        color1 = [0.15, 0.15, 0.15];
        color2 = [0.12, 0.12, 0.12];
    end
    
    % Tạo ma trận xen kẽ
    bg_colors = zeros(n_rows, 3);
    for row = 1:n_rows
        if mod(row, 2) == 1
            bg_colors(row, :) = color1;
        else
            bg_colors(row, :) = color2;
        end
    end
end