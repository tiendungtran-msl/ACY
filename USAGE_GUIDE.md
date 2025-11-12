# HƯỚNG DẪN SỬ DỤNG CHI TIẾT
# Air Defense Command Automation System (АСУ ПВО)

## Mục lục
1. [Khởi động nhanh](#khởi-động-nhanh)
2. [Sử dụng Classes OOP](#sử-dụng-classes-oop)
3. [Sử dụng Algorithms](#sử-dụng-algorithms)
4. [Kịch bản mẫu](#kịch-bản-mẫu)
5. [Tùy chỉnh hệ thống](#tùy-chỉnh-hệ-thống)
6. [Troubleshooting](#troubleshooting)

---

## Khởi động nhanh

### Cách 1: Sử dụng script main.m (Mới)
```matlab
% Khởi động hệ thống với cấu hình mới
main
```

### Cách 2: Sử dụng SimulationProcessACY.m (Gốc)
```matlab
% Khởi động hệ thống với code gốc
SimulationProcessACY
```

### Cách 3: Chạy kịch bản mẫu
```matlab
% Chạy kịch bản 4 mục tiêu
run_sample_scenario
```

### Cách 4: Demo Classes và Algorithms
```matlab
% Xem demo sử dụng OOP và thuật toán
demo_classes
```

---

## Sử dụng Classes OOP

### 1. Class Target (Mục tiêu)

```matlab
% Tạo waypoints
waypoints = [0, 70000; 0, 60000; 0, 50000; 0, 40000];

% Tạo mục tiêu
target = Target(1, 'B52-01', 'MB ném bom chiến lược', ...
    500, 18000, 15, 3, ...
    'Ném bom chiến lược', 'Chủ động', 4, ...
    waypoints, [1, 0, 0], 's');

% Đặt chỉ thị cấp trên
target.priority_from_command = true;

% Lấy tham số chuyển động
params = target.getMotionParams();

% Nhận dạng loại
category = target.recognizeType([]);

% Chuyển sang struct (để tương thích với code cũ)
target_struct = target.toStruct();
```

### 2. Class FireUnit (Đơn vị hỏa lực)

```matlab
% Tạo đơn vị hỏa lực
fireunit = FireUnit('S-125-01', 'S-125', [0, 10000, 0], ...
    3500, 50000, 100, 18000, 2);

% Kiểm tra khả năng bắn
can_engage = fireunit.canEngage(target);

% Phân công mục tiêu
fireunit.assignTarget(target.id);

% Giải phóng mục tiêu
fireunit.releaseTarget(target.id);

% Chuyển sang struct
fire_struct = fireunit.toStruct();
```

### 3. Class ProtectedObject (Đối tượng bảo vệ)

```matlab
% Tạo đối tượng bảo vệ
protected = ProtectedObject('Căn cứ quân sự', 'Military Base', ...
    [-8000, -8000, 0], 1.0, 5000);

% Đánh giá mức độ đe dọa
threat_level = protected.assessThreat(target);

% Chuyển sang struct
prot_struct = protected.toStruct();
```

### 4. Class AirSituation (Tình huống không chiến)

```matlab
% Tạo tình huống
situation = AirSituation(SCH, targets, fire_units, protected_objects);

% Đánh giá tất cả mục tiêu (Thuật toán 11 khối)
situation.evaluateAllTargets();

% Cập nhật tình huống (mỗi frame)
situation.update(dt);

% Lấy danh sách ưu tiên
prioritized = situation.getPrioritizedTargets();

% In kết quả
for i = 1:length(prioritized)
    t = prioritized(i);
    fprintf('%d. %s - Bⱼ: %.2f/10\n', i, t.name, t.Bj);
end
```

---

## Sử dụng Algorithms

### Khối 1: Đánh giá tham số chuyển động

```matlab
target = struct(...);  % Mục tiêu
dt = 1;  % Bước thời gian

params = Block1_EvaluateMotion(target, dt);

% Kết quả:
% params.x, params.y, params.H       - Tọa độ
% params.vx, params.vy, params.vh    - Vận tốc
% params.Q, params.Q_deg             - Hướng bay
% params.v_total, params.v_horizontal - Vận tốc tổng
```

### Khối 2: Kiểm tra vùng phân phối

```matlab
target_pos = [10000, 20000, 5000];
SCH_pos = [0, 0, 0];
range_min = 300;    % 300m
range_max = 50000;  % 50km

in_zone = Block2_CheckZone(target_pos, SCH_pos, range_min, range_max);

if in_zone
    fprintf('Mục tiêu trong vùng phân phối\n');
else
    fprintf('Mục tiêu ngoài vùng\n');
end
```

### Khối 4: Nhận dạng loại mục tiêu

```matlab
% Với database
load('Data/TargetDatabase.mat');
type_info = Block4_RecognizeType(target, targetDB);

% Không có database
type_info = Block4_RecognizeType(target, []);

fprintf('Loại: %s (%.0f%% tin cậy)\n', ...
    type_info.category, type_info.confidence*100);
```

### Khối 4'-5': Tính tham số không-thời gian

```matlab
% Tính pᵢⱼ và τᵢⱼ
[pij, tauij] = CalculateCourseParams(target, protected_obj, fire_unit);

fprintf('pᵢⱼ (tham số hướng bay): %.0f m\n', pij);
fprintf('τᵢⱼ (thời gian tiếp cận): %.1f s\n', tauij);
```

### Khối 6': Tính mức độ quan trọng Bⱼ

```matlab
cfg = config();
Bj = Block6p_CalculateBj(target, SCH, targets_protect, fire_units, cfg);

fprintf('Mức độ quan trọng Bⱼ: %.2f/10\n', Bj);

% Chuyển sang priority (0-1)
priority = Bj / 10;
```

### Dự báo quỹ đạo

```matlab
% Dự báo tuyến tính
future_pos_linear = PredictTrajectory(target, 30, 'linear');

% Dự báo đa thức
future_pos_poly = PredictTrajectory(target, 30, 'polynomial');

% Dự báo với nhiễu
future_pos_noise = PredictTrajectory(target, 30, 'uniform');
```

### Phát hiện cơ động

```matlab
threshold = 2.0;  % Ngưỡng 2G
is_maneuvering = DetectManeuver(target, threshold);

if is_maneuvering
    fprintf('Mục tiêu đang cơ động!\n');
end
```

### Ánh xạ màu gradient

```matlab
cfg = config();

% Priority từ 0 đến 1
priority = 0.85;

% Lấy màu RGB
color = ColorMapping(priority, cfg);

% Sử dụng màu
plot(x, y, 'o', 'MarkerFaceColor', color);
```

---

## Kịch bản mẫu

### Kịch bản 4 mục tiêu

File: `Data/SampleScenario.m`

```matlab
[SCH, targets_protect, fire_units, targets] = SampleScenario();
```

**Bao gồm:**
- **MT1 (B52-01)**: B52 có chỉ thị cấp trên
  - Priority: 1.0 (tối đa)
  - Chỉ thị từ cấp trên: Có
  
- **MT2 (F-16-01)**: Fighter cơ động cao
  - Priority: ~0.85
  - Tấn công SCH, cơ động 8.5G
  
- **MT3 (TLHT-01)**: Tên lửa hành trình
  - Priority: ~0.75
  - RCS thấp (0.5m²), stealth
  
- **MT4 (EA-18G)**: Fighter gây nhiễu
  - Priority: ~0.70
  - Gây nhiễu chủ động, nhóm 2 máy

**Đơn vị hỏa lực:**
- OE-1: Tầm 50km, 2 kênh
- OE-2: Tầm 60km, 3 kênh

**Đối tượng bảo vệ:**
- Căn cứ quân sự (importance: 1.0)
- Sở chỉ huy (importance: 0.95)
- Nhà máy điện (importance: 0.8)

---

## Tùy chỉnh hệ thống

### Thay đổi cấu hình

```matlab
% Lấy cấu hình mặc định
cfg = config();

% Thay đổi tham số
cfg.distribution_range_max = 60000;  % Tăng vùng phân phối lên 60km
cfg.simulation_dt = 0.5;              % Giảm bước thời gian
cfg.display_trajectory = false;       % Tắt hiển thị quỹ đạo

% Sử dụng cấu hình mới
Bj = Block6p_CalculateBj(target, SCH, targets_protect, fire_units, cfg);
```

### Tạo mục tiêu tùy chỉnh

```matlab
% Sử dụng struct
custom_target = createTarget(5, 'Custom-01', 'Tiêm kích', ...
    600, 12000, 3, 7, ...
    'Tuần tra', 'Không', 1, ...
    waypoints, [0, 1, 1], '^');

% Hoặc sử dụng Class
custom_target = Target(5, 'Custom-01', 'Tiêm kích', ...
    600, 12000, 3, 7, ...
    'Tuần tra', 'Không', 1, ...
    waypoints, [0, 1, 1], '^');
```

### Tạo đơn vị hỏa lực tùy chỉnh

```matlab
% Tạo S-300
s300 = FireUnit('S-300-01', 'S-300', [0, 0, 0], ...
    5000, 150000, 25, 27000, 6);
```

---

## Troubleshooting

### Lỗi: "Undefined function or variable"

**Nguyên nhân:** Đường dẫn chưa được thêm vào MATLAB path

**Giải pháp:**
```matlab
% Thêm tất cả thư mục con
addpath(genpath(pwd));
savepath;
```

### Lỗi: "Database not found"

**Nguyên nhân:** File TargetDatabase.mat chưa được tạo

**Giải pháp:**
```matlab
cd Data
createTargetDatabase
cd ..
```

### Mục tiêu không di chuyển

**Nguyên nhân:** Chưa tạo smooth path

**Giải pháp:**
```matlab
targets = createSmoothPaths(targets);
```

### Màu sắc không hiển thị đúng

**Nguyên nhân:** Bⱼ chưa được tính

**Giải pháp:**
```matlab
% Tính Bⱼ cho tất cả mục tiêu
for i = 1:length(targets)
    targets(i).Bj = calculateThreatLevel(targets(i), ...
        SCH.pos(1:2), targets_protect, fire_units);
end
```

---

## Tham khảo thêm

- Xem `README.md` cho thông tin tổng quan
- Chạy `demo_classes` để xem ví dụ đầy đủ
- Đọc comments trong từng file .m để hiểu chi tiết

---

**Cập nhật:** 2025-11-12  
**Tác giả:** Trần Tiến Dũng
