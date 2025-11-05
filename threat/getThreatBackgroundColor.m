function bg_color = getThreatBackgroundColor(Bj)
    % Màu nền cho label (với alpha)
    base_color = getThreatColor(Bj);
    if Bj > 8
        bg_color = [base_color, 0.85];
    elseif Bj > 6
        bg_color = [base_color, 0.75];
    else
        bg_color = [0.2, 0.2, 0.2, 0.7];
    end
end