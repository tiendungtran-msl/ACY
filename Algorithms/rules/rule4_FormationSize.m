function score = rule4_FormationSize(target, all_targets)
    % QUY TAC 4: DANH GIA THEO SO LUONG
    % Output: score thuoc [0, 10]
    
    % Uoc luong tu RCS
    if isfield(target, 'RCS_eff')
        RCS = target.RCS_eff;
    else
        RCS = target.RCS;
    end
    
    [target_type, ~, ~] = classifyTarget(target);
    
    if contains(target_type, 'MB nem bom')
        RCS_single = 12;
    elseif contains(target_type, 'Tiem kich')
        RCS_single = 3;
    elseif contains(target_type, 'Ten lua')
        RCS_single = 0.5;
    else
        RCS_single = 3;
    end
    
    estimated_count = round(RCS / RCS_single);
    estimated_count = max(1, min(6, estimated_count));
    
    % Dem formation
    formation_radius = 5000;
    nearby_count = 0;
    
    for i = 1:length(all_targets)
        other = all_targets(i);
        if other.id ~= target.id && strcmp(other.status, 'Dang bay')
            dist = norm(target.pos - other.pos);
            if dist < formation_radius
                nearby_count = nearby_count + 1;
            end
        end
    end
    
    formation_size = nearby_count + 1;
    final_count = max(estimated_count, formation_size);
    
    % Tinh diem
    if final_count >= 4
        score = 10.0;
    elseif final_count == 3
        score = 8.5;
    elseif final_count == 2
        score = 7.0;
    else
        score = 5.0;
    end
    
    score = max(0, min(10, score));
end