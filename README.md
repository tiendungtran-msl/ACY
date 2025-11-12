# Hệ thống mô phỏng АСУ ПВО - Air Defense Command Automation System

## Giới thiệu

Hệ thống mô phỏng màn hình hiển thị tình huống trên không (THTK) theo thuật toán đánh giá tham số cho hệ thống tự động hóa chỉ huy phòng không.

## Tác giả
Trần Tiến Dũng - 2025

## Tính năng chính

### 1. Mô hình chuyển động mục tiêu
- Mục tiêu di chuyển qua các điểm mốc (waypoints) được định trước
- Vẽ quỹ đạo chuyển động trên màn hình theo thời gian thực
- Hỗ trợ các loại mục tiêu:
  - Tiêm kích chiến thuật
  - Tiêm kích ném bom
  - Máy bay ném bom chiến lược (B-52)
  - Tên lửa hành trình

### 2. Thuật toán xử lý 11 khối (Hình 2.6)

Hệ thống thực hiện thuật toán đánh giá tham số THTK với 11 khối:

- **Khối 1** (`Block1_EvaluateMotion.m`): Đánh giá tọa độ và tham số chuyển động (x, y, H, vₓ, vᵧ, vₕ, Q)
- **Khối 2** (`Block2_CheckZone.m`): Kiểm tra vị trí trong vùng phân phối (Dб < Dⱼ < Dд)
- **Khối 3**: Xác định chỉ thị từ cấp trên
- **Khối 4** (`Block4_RecognizeType.m`): Nhận dạng dạng mục tiêu theo Bảng 2
- **Khối 5**: Đánh giá số lượng thành phần nhóm
- **Khối 6**: Xác định dấu hiệu chiến đấu
- **Khối 7**: Xác định hành động/nhiệm vụ mục tiêu
- **Khối 4'-5'** (`CalculateCourseParams.m`): Tính tham số không-thời gian (pᵢⱼ, τᵢⱼ)
- **Khối 6'** (`Block6p_CalculateBj.m`): Tính mức độ quan trọng Bⱼ theo 8 quy tắc
- **Khối 11**: Kiểm tra đã xét hết mục tiêu

### 3. Hiển thị phân loại mục tiêu

Với mỗi mục tiêu hiển thị:
- Dạng mục tiêu (Fighter, B52, Cruise Missile, etc.)
- Ký hiệu đặc trưng (△, ▽, ►, ■)
- Thông tin chi tiết (vận tốc, độ cao, hướng bay)
- Màu sắc gradient theo mức độ nguy hiểm

### 4. Đánh giá mức độ quan trọng (8 quy tắc)

1. **Chỉ thị từ cấp trên**: Cⱼᴷᵖ = 1 → Ưu tiên tuyệt đối
2. **Dạng mục tiêu**: WMD > B52 > Cruise Missile > Fighter
3. **Dạng tác chiến**: ECM, cơ động cao, tấn công SCH
4. **Số lượng thành phần**: Nhóm lớn > nhỏ > đơn độc
5. **Nhiệm vụ**: Tấn công chiến lược, chế áp phòng không
6. **Hướng bay**: Đến đối tượng bảo vệ
7. **Thời gian tiếp cận**: Càng gần càng nguy hiểm
8. **Vị trí**: So với ĐVHL

### 5. Gradient màu sắc

- 🔴 **Đỏ tươi** (Priority ≥ 0.8): Cực nguy hiểm
- 🟠 **Đỏ cam** (0.6 ≤ Priority < 0.8): Nguy hiểm cao
- 🟠 **Cam** (0.4 ≤ Priority < 0.6): Nguy hiểm trung bình
- 🟡 **Vàng** (0.2 ≤ Priority < 0.4): Nguy hiểm thấp
- 🟢 **Xanh lá** (Priority < 0.2): Ít nguy hiểm

## Cấu trúc dự án

```
/
├── main.m                          # Script chính
├── config.m                        # Cấu hình hệ thống
├── SimulationProcessACY.m          # Script khởi động gốc
│
├── Classes/                        # OOP Classes
│   ├── Target.m                    # Class mục tiêu
│   ├── FireUnit.m                  # Class đơn vị hỏa lực
│   ├── ProtectedObject.m           # Class đối tượng bảo vệ
│   └── AirSituation.m              # Class tình huống không chiến
│
├── Algorithms/                     # Thuật toán 11 khối
│   ├── Block1_EvaluateMotion.m     # Khối 1: Tham số chuyển động
│   ├── Block2_CheckZone.m          # Khối 2: Kiểm tra vùng
│   ├── Block4_RecognizeType.m      # Khối 4: Nhận dạng
│   ├── Block6p_CalculateBj.m       # Khối 6': Tính Bⱼ
│   ├── PredictTrajectory.m         # Dự báo quỹ đạo
│   ├── DetectManeuver.m            # Phát hiện cơ động
│   └── CalculateCourseParams.m     # Tính pᵢⱼ, τᵢⱼ
│
├── Visualization/                  # Hiển thị
│   └── ColorMapping.m              # Ánh xạ màu gradient
│
├── Data/                           # Dữ liệu
│   ├── createTargetDatabase.m      # Tạo database
│   └── SampleScenario.m            # Kịch bản mẫu
│
├── gui/                            # Giao diện
├── drawing/                        # Vẽ đồ họa
├── simulation/                     # Vòng lặp mô phỏng
├── threat/                         # Tính toán đe dọa
└── README.md                       # Tài liệu này
```

## Database mục tiêu (Bảng 2)

| Loại | Vmax (m/s) | H (m) | RCS (m²) | D_detect (km) | n_max (G) |
|------|------------|-------|----------|---------------|-----------|
| Tiêm kích chiến thuật | 350-750 | 50-22000 | 1-5 | 140 | 6.5-9 |
| Tiêm kích ném bom | 320-750 | 50-18000 | 2-5 | 170 | 5-6 |
| MB ném bom chiến lược | 250-700 | 100-19000 | 5-20 | 200 | 2-4 |
| Tên lửa hành trình | 250-1200 | 60-40000 | 0.01-2.5 | 95 | 1-2 |

## Công thức toán học

### 1. Tham số hướng bay
```matlab
pᵢⱼ = |(xᵢ - xⱼ)·sin(Qⱼ) - (yᵢ - yⱼ)·cos(Qⱼ)|
```

### 2. Thời gian tiếp cận
```matlab
τᵢⱼ = (√[(xᵢ* - xⱼ)² + (yᵢ* - yⱼ)²] - √[rᵢ² - pᵢⱼ²]) / vⱼ
```

### 3. Gradient màu sắc
```matlab
function color = ColorMapping(priority, cfg)
    if priority >= 0.8
        color = [1, 0, 0];      % Đỏ
    elseif priority >= 0.6
        color = [1, 0.3, 0];    % Đỏ cam
    elseif priority >= 0.4
        color = [1, 0.6, 0];    % Cam
    elseif priority >= 0.2
        color = [1, 1, 0];      % Vàng
    else
        color = [0, 1, 0];      % Xanh
    end
end
```

## Hướng dẫn sử dụng

### Khởi động hệ thống

**Cách 1: Sử dụng script chính mới**
```matlab
main
```

**Cách 2: Sử dụng script gốc**
```matlab
SimulationProcessACY
```

### Tạo database mục tiêu
```matlab
cd Data
createTargetDatabase
```

### Sử dụng kịch bản mẫu
```matlab
[SCH, targets_protect, fire_units, targets] = SampleScenario();
```

### Sử dụng Classes OOP

```matlab
% Tạo mục tiêu
target = Target(1, 'F-16', 'Tiêm kích', 700, 10000, 3, 8.5, ...
    'Tấn công', 'Không', 1, waypoints, [1,0,0], '^');

% Tạo đơn vị hỏa lực
fireunit = FireUnit('S-125', 'SAM', [0,0,0], 3500, 50000, 100, 18000, 2);

% Tạo đối tượng bảo vệ
protected = ProtectedObject('Căn cứ', 'Military', [0,0,0], 1.0, 5000);

% Tạo tình huống
situation = AirSituation(SCH, targets, fire_units, protected_objects);

% Đánh giá tất cả mục tiêu
situation.evaluateAllTargets();

% Lấy danh sách ưu tiên
prioritized = situation.getPrioritizedTargets();
```

### Sử dụng Algorithms

```matlab
% Khối 1: Đánh giá chuyển động
params = Block1_EvaluateMotion(target, dt);

% Khối 2: Kiểm tra vùng
in_zone = Block2_CheckZone(target.pos, SCH.pos, 300, 50000);

% Khối 4: Nhận dạng
load('Data/TargetDatabase.mat');
type_info = Block4_RecognizeType(target, targetDB);

% Khối 4'-5': Tính pᵢⱼ, τᵢⱼ
[pij, tauij] = CalculateCourseParams(target, protected_obj, fire_unit);

% Khối 6': Tính Bⱼ
Bj = Block6p_CalculateBj(target, SCH, targets_protect, fire_units, cfg);

% Dự báo quỹ đạo
future_pos = PredictTrajectory(target, 30, 'linear');

% Phát hiện cơ động
is_maneuvering = DetectManeuver(target, 2.0);

% Ánh xạ màu
color = ColorMapping(Bj/10, cfg);
```

## Điều khiển mô phỏng

- **BẮT ĐẦU**: Khởi động mô phỏng
- **TẠM DỪNG**: Tạm dừng mô phỏng
- **RESET**: Đặt lại về trạng thái ban đầu
- **Checkbox**: Đánh dấu mục tiêu có chỉ thị từ cấp trên

## Kịch bản mẫu

Hệ thống bao gồm kịch bản mẫu với:

### 4 Mục tiêu:
1. **MT1 (B52-01)**: B52 có chỉ thị cấp trên → Priority = 1.0
2. **MT2 (F-16-01)**: Fighter cơ động cao tấn công SCH → Priority ≈ 0.85
3. **MT3 (TLHT-01)**: Cruise Missile stealth → Priority ≈ 0.75
4. **MT4 (EA-18G)**: Fighter gây nhiễu ECM → Priority ≈ 0.70

### 2 Đơn vị hỏa lực:
- **OE-1**: Tầm 50km, 2 kênh
- **OE-2**: Tầm 60km, 3 kênh

### 3 Đối tượng bảo vệ:
- **Căn cứ quân sự**: importance = 1.0
- **Sở chỉ huy**: importance = 0.95
- **Nhà máy điện**: importance = 0.8

## Yêu cầu hệ thống

- MATLAB R2019b hoặc cao hơn
- Toolboxes: Control System, Optimization (optional)

## Đơn vị đo

- **Tọa độ**: Hệ tọa độ vuông góc XYH
- **Khoảng cách**: meters (m)
- **Vận tốc**: m/s
- **Thời gian**: seconds (s)
- **Độ cao**: meters (m)

## Tài liệu tham khảo

- Hình 2.6: Thuật toán đánh giá tham số THTK (11 khối)
- Bảng 2: Đặc trưng kỹ thuật bay của mục tiêu
- 8 quy tắc đánh giá mức độ quan trọng
- Lý thuyết dự báo quỹ đạo

## License

Copyright © 2025 Trần Tiến Dũng. All rights reserved.

## Liên hệ

Mọi thắc mắc và đóng góp xin liên hệ qua GitHub repository.
