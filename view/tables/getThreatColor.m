function color = getThreatColor(Bj)
    % Ánh xạ điểm nguy hiểm sang màu sắc
    if Bj >= 0.9
        color = [0.9, 0, 0];       % Đỏ đậm
    elseif Bj >= 0.8
        color = [1, 0.2, 0];       % Đỏ
    elseif Bj >= 0.7
        color = [1, 0.4, 0];       % Cam đỏ
    elseif Bj >= 0.6
        color = [1, 0.6, 0];       % Cam
    elseif Bj >= 0.5
        color = [1, 0.8, 0];       % Cam vàng
    elseif Bj >= 0.4
        color = [1, 1, 0];         % Vàng
    elseif Bj >= 0.3
        color = [0.8, 1, 0.2];     % Vàng xanh
    elseif Bj >= 0.2
        color = [0.5, 1, 0.5];     % Xanh nhạt
    else
        color = [0.3, 0.8, 0.3];   % Xanh lá
    end
end