function score = tacticalTypeRule(target, all_targets)
    %% QUY TAC 3: DANH GIA THEO DANG TAC CHIEN
    % Uu tien:
    % 1. May bay gay nhieu chu dong (10)
    % 2. May bay duoc nhieu che phu (8)
    % 3. May bay gay nhieu thu dong (7)
    % 4. May bay co dong cao (6)
    % 5. May bay tan cong SCH/Hoa luc (9)
    %
    % Output: score thuoc [0, 10]
    
    score = 5.0;
    
    % 1. Kiem tra gay nhieu chu dong
    if strcmp(target.jam_type, 'Chủ động')
        score = 10.0;
        return;
    end

    % 2. Kiem tra duoc che phu boi nhieu
    is_covered = false;

    for i = 1:length(all_targets)
        other = all_targets(i);

        if other.id ~= target.id && strcmp(other.jam_type, 'Chủ động')
            % Khoang cach den may bay gay nhieu
            dist = norm(target.pos - other.pos);
            
            % Neu trong ban kinh che phu (15km)
            if dist < 15000
                is_covered = true;
                break;
            end
        end
    end
    
    if is_covered
        score = 8.0;
        return;
    end
    
    % 3. Kiem tra gay nhieu thu dong
    if strcmp(target.jam_type, 'Thụ động')
        score = 7.0;
        return;
    end

    % 4. Kiem tra nhiem vu tan cong SCH/Hoa luc
    if contains(target.task, 'Tấn công SCH') || ...
       contains(target.task, 'Tiêu diệt hỏa lực') || ...
       contains(target.task, 'Chế áp phòng không')
        score = 9.0;
        return;
    end

    % 5. Kiem tra kha nang co dong cao
    n_max = target.maneuver_ability;

    if n_max >= 7.0
        score = 6.5;
    elseif n_max >= 5.0
        score = 5.5;
    else
        score = 4.0;
    end
    
    % Dam bao trong khoang [0, 10]
    score = max(0, min(10, score));
end