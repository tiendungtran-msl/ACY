function [SCH, targets_protect, fire_units, targets] = initializeData()
    % Khởi tạo tất cả dữ liệu cơ bản
    
    % A1. Sở Chỉ Huy
    SCH = struct('name', 'SCH', 'pos', [0, 0, 0]);
    
    % A2. Mục tiêu bảo vệ
    targets_protect = [
        struct('name', 'MTBV-1', 'pos', [-5000, -5000, 0], 'type', 'Kho vật tư')
        struct('name', 'MTBV-2', 'pos', [5000, -5000, 0], 'type', 'Sân bay')
    ];
    
    % A3. Đơn vị hỏa lực
    fire_units = [
        createFireUnit('S125-d1', [0, 10000, 0])
        createFireUnit('S125-d2', [-10000, 0, 0])
        createFireUnit('S125-d3', [10000, 0, 0])
    ];
    
    % A4. Mục tiêu đối phương
    targets = [
        createTarget(1, 'TK-01', 'Tiêm kích chiến thuật', 550, 3, 7.5, ...
            'Tấn công SCH', 'Không', 1, ...
            [-40000, 60000, 12000;
             -20000, 48000, 10500;
             -10000, 30000, 9000;
             -10000, 20000, 8000;
             -20000, 10000, 7000;
             -30000, 0,     6000], ...
            [1, 0.6, 0.2], 'o')
        
        createTarget(2, 'TK-02', 'Tiêm kích ném bom', 500, 4, 5.5, ...
            'Ném bom hậu phương', 'Thụ động', 2, ...
            [30000,  50000, 15000;
             20000,  30000, 14000;
             10000,  20000, 13000;
             -10000, 10000, 11000;
             -25000, 10000, 9000;
             -40000, 20000, 8000], ...
            [1, 0.4, 0], 'o')
        
        createTarget(3, 'B52-01', 'MB ném bom chiến lược', 475, 12, 3, ...
            'Ném bom chiến lược', 'Chủ động', 4, ...
            [0, 70000, 18000;
             0, 60000, 18000;
             0, 50000, 17500;
             0, 40000, 17000;
             0, 30000, 16500;
             0, 20000, 16000], ...
            [1, 0.2, 0.2], 'o')
        
        createTarget(4, 'TLHT-01', 'Tên lửa hành trình', 600, 0.5, 1.5, ...
            'Tiêu diệt hậu phương', 'Không', 1, ...
            [-40000, 60000, 5000;
             -20000, 48000, 4500;
             -10000, 40000, 4000;
             0,      30000, 3500;
             5000,   20000, 3000;
             5000,   10000, 2500], ...
            [1, 0.3, 1], 'o')
    ];
end