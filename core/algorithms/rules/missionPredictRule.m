function score = missionPredictRule(target, SCH, targets_protect, fire_units)
    %% QUY TAC 5: DANH GIA THEO NHIEM VU DU DOAN
    % Uu tien (cao -> thap):
    %   1. Tieu diet luc luong hau phuong (10.0)
    %   2. Che ap hoa luc/SCH phong khong (9.0)
    %   3. Yem tro tac chien (7.0)
    %   4. Trinh sat mat dat (6.0)
    %   5. Phan tan SCH (5.0)
    %
    % Output: score thuoc [0, 10]
    
    % =======================================================
    % BUOC 1: LAY THONG TIN MUC TIEU
    % =======================================================
    
    % Nhan dang loai muc tieu
    [target_type, ~, ~] = classifyTarget(target);
    
    % Vector huong bay hien tai
    if norm(target.vel) > 0
        direction = target.vel / norm(target.vel);
    else
        % Neu khong co thong tin van toc, gia dinh bay ve huong Dong
        direction = [1, 0, 0];
    end
    
    % Van toc hien tai
    current_speed = target.speed;
    speed_cruise = target.speed_cruise;
    
    % Do cao hien tai
    altitude = target.pos(3);
    
    % =======================================================
    % BUOC 2: TINH GOC HUONG DEN CAC DOI TUONG
    % =======================================================
    
    % 2.1. Goc huong den SCH
    dir_to_sch = SCH.pos - target.pos;
    if norm(dir_to_sch(1:2)) > 0
        dir_to_sch_norm = dir_to_sch / norm(dir_to_sch);
        angle_to_sch = acosd(dot(direction, dir_to_sch_norm));
    else
        angle_to_sch = 180;
    end
    
    % 2.2. Goc huong den muc tieu bao ve (MTBV) gan nhat
    min_angle_to_protect = 180;
    min_dist_to_protect = inf;
    
    for i = 1:length(targets_protect)
        dir_to_protect = targets_protect(i).pos - target.pos;
        dist_to_protect = norm(dir_to_protect(1:2));
        
        if dist_to_protect > 0
            dir_norm = dir_to_protect / norm(dir_to_protect);
            angle = acosd(dot(direction, dir_norm));
            
            if angle < min_angle_to_protect
                min_angle_to_protect = angle;
                min_dist_to_protect = dist_to_protect;
            end
        end
    end
    
    % 2.3. Goc huong den don vi hoa luc gan nhat
    min_angle_to_fire = 180;
    min_dist_to_fire = inf;
    
    for i = 1:length(fire_units)
        dir_to_fire = fire_units(i).pos - target.pos;
        dist_to_fire = norm(dir_to_fire(1:2));
        
        if dist_to_fire > 0
            dir_norm = dir_to_fire / norm(dir_to_fire);
            angle = acosd(dot(direction, dir_norm));
            
            if angle < min_angle_to_fire
                min_angle_to_fire = angle;
                min_dist_to_fire = dist_to_fire;
            end
        end
    end
    
    % =======================================================
    % BUOC 3: DU DOAN NHIEM VU DUA TREN DAU HIEU
    % =======================================================
    
    % -------------------------------------------------------
    % NHIEM VU 1: TIEU DIET LUC LUONG HAU PHUONG
    % Dac diem:
    %   - Loai: May bay nem bom
    %   - Huong: Bay thang den MTBV (goc < 30 do)
    %   - Van toc: Hon toc do hanh trinh (dang tien cong)
    % -------------------------------------------------------
    if contains(target_type, 'MB ném bom') || contains(target_type, 'ném bom')
        if min_angle_to_protect < 30
            % Bay thang den MTBV
            score = 10.0;
            return;
        elseif min_angle_to_protect < 60 && current_speed > speed_cruise * 0.85
            % Gan MTBV va van toc cao
            score = 9.5;
            return;
        end
    end
    
    % -------------------------------------------------------
    % NHIEM VU 2: CHE AP HOA LUC/SCH PHONG KHONG
    % Dac diem:
    %   - Loai: Tiem kich, ten lua hanh trinh
    %   - Huong: Bay den SCH hoac don vi hoa luc (goc < 30 do)
    %   - Van toc: Cao (dang tien cong nhanh)
    % -------------------------------------------------------
    if contains(target_type, 'Tiêm kích') || contains(target_type, 'Tên lửa')
        if angle_to_sch < 30 || min_angle_to_fire < 30
            % Bay thang den SCH hoac hoa luc
            score = 9.0;
            return;
        elseif angle_to_sch < 60 || min_angle_to_fire < 60
            % Gan SCH/hoa luc
            score = 8.5;
            return;
        end
    end
    
    % -------------------------------------------------------
    % NHIEM VU 3: YEM TRO TAC CHIEN
    % Dac diem:
    %   - Van toc: Thap hon toc do hanh trinh (cho doi)
    %   - Do cao: Trung binh
    %   - Vi tri: Song hanh voi cac muc tieu khac
    % -------------------------------------------------------
    if current_speed < speed_cruise * 0.8
        % Bay cham, co the dang yem tro
        score = 7.0;
        return;
    end
    
    % -------------------------------------------------------
    % NHIEM VU 4: TRINH SAT MAT DAT
    % Dac diem:
    %   - Do cao: Cao (> 15km)
    %   - Van toc: On dinh gan toc do hanh trinh
    %   - Huong: Khong huong truc tiep den muc tieu
    % -------------------------------------------------------
    if altitude > 15000
        if current_speed > speed_cruise * 0.9 && current_speed < speed_cruise * 1.1
            % Do cao cao, van toc on dinh
            score = 6.0;
            return;
        end
    end
    
    % -------------------------------------------------------
    % NHIEM VU 5: PHAN TAN SCH / THU HUT SU CHUYEN Y
    % Dac diem:
    %   - Khong kip voi cac tieu chi tren
    %   - Bay quanh vung, khong huong cu the
    % -------------------------------------------------------
    score = 5.0;
end