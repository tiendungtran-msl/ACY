function score = targetTypeRule(target)
    % QUY TAC 2: DANH GIA THEO LOAI MUC TIEU
    % Muc tieu nguy hiem nhat: Mang vu khi sat thuong hang loat
    % Output: score thuoc [0, 10]
    
    % Nhan dang loai muc tieu
    [target_type, confidence, ~] = classifyTarget(target);
    
    % Bang diem theo loai
    if contains(target_type, 'MB ném bom')
        base_score = 10.0;
    elseif contains(target_type, 'Tiêm kích ném bom')
        base_score = 8.5;
    elseif contains(target_type, 'Tiêm kích chiến thuật')
        base_score = 7.0;
    elseif contains(target_type, 'Tên lửa hành trình')
        base_score = 9.0;
    else
        base_score = 5.0;
    end
    
    % Dieu chinh theo do tin cay
    confidence_factor = confidence / 100;
    score = base_score * (0.7 + 0.3 * confidence_factor);
    
    score = max(0, min(10, score));
end