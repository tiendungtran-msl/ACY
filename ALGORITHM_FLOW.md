# THUẬT TOÁN 11 KHỐI - ĐÁNH GIÁ THAM SỐ THTK
# Air Defense Command Automation System

## Sơ đồ thuật toán (Hình 2.6)

```
┌─────────────────────────────────────────────────────────┐
│                     BẮT ĐẦU                             │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 1: Đánh giá tọa độ và tham số chuyển động         │
│  • x, y, H (tọa độ không gian)                          │
│  • vₓ, vᵧ, vₕ (vận tốc)                                 │
│  • Q (hướng bay)                                        │
│  File: Block1_EvaluateMotion.m                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 2: Kiểm tra vùng phân phối                        │
│  • Điều kiện: Dб < Dⱼ < Dд                              │
│  • Dб = 300m (cự ly gần)                                │
│  • Dд = 50km (cự ly xa)                                 │
│  File: Block2_CheckZone.m                               │
└────────────────────┬────────────────────────────────────┘
                     │
                     ├─── KHÔNG ──► Bⱼ = 0 ──► KHỐI 11
                     │
                     │ CÓ
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 3: Xác định chỉ thị từ cấp trên                   │
│  • Kiểm tra Cⱼᴷᵖ = 1?                                   │
│  File: Tích hợp trong Block6p_CalculateBj.m            │
└────────────────────┬────────────────────────────────────┘
                     │
                     ├─── CÓ ──► Bⱼ = 10 ──► KHỐI 11
                     │
                     │ KHÔNG
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 4: Nhận dạng dạng mục tiêu                        │
│  • So sánh với Bảng 2 (Database)                        │
│  • Các loại: Tiêm kích, B52, TLHT, etc.                │
│  File: Block4_RecognizeType.m                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 5: Đánh giá số lượng thành phần nhóm              │
│  • Nhóm lớn (≥4)                                        │
│  • Nhóm nhỏ (2-3)                                       │
│  • Đơn độc (1)                                          │
│  File: Tích hợp trong calculateThreatLevel.m           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 6: Xác định dấu hiệu chiến đấu                    │
│  • Loại gây nhiễu (Chủ động/Thụ động/Được che phủ)     │
│  • Khả năng cơ động (n_max)                             │
│  File: Tích hợp trong calculateThreatLevel.m           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 7: Xác định hành động/nhiệm vụ                    │
│  • Tiêu diệt hậu phương                                 │
│  • Chế áp phòng không                                   │
│  • Yểm trợ tác chiến                                    │
│  • Trinh sát                                            │
│  File: Tích hợp trong calculateThreatLevel.m           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 4'-5': Tính tham số không-thời gian               │
│  • pᵢⱼ = |(xᵢ-xⱼ)·sin(Qⱼ) - (yᵢ-yⱼ)·cos(Qⱼ)|          │
│  • τᵢⱼ = (√[(xᵢ*-xⱼ)²+(yᵢ*-yⱼ)²] - √[rᵢ²-pᵢⱼ²])/vⱼ    │
│  File: CalculateCourseParams.m                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 6': Tính mức độ quan trọng Bⱼ theo 8 quy tắc     │
│                                                         │
│  QUY TẮC 1: Chỉ thị từ cấp trên                        │
│    → Bⱼ = 10 (ưu tiên tuyệt đối)                       │
│                                                         │
│  QUY TẮC 2: Dạng mục tiêu                              │
│    • WMD/B52: 100 điểm                                 │
│    • Tên lửa hành trình: 90 điểm                       │
│    • Ném bom: 85 điểm                                  │
│    • Tiêm kích: 70 điểm                                │
│                                                         │
│  QUY TẮC 3: Dạng tác chiến                             │
│    • Gây nhiễu chủ động: +95 điểm                      │
│    • Cơ động cao (>7G): +70 điểm                       │
│    • Tấn công SCH: +85 điểm                            │
│                                                         │
│  QUY TẮC 4: Số lượng                                   │
│    • Nhóm lớn (≥4): +75 điểm                           │
│    • Nhóm nhỏ (2-3): +55 điểm                          │
│    • Đơn độc (1): +25 điểm                             │
│                                                         │
│  QUY TẮC 5: Nhiệm vụ                                   │
│    • Tiêu diệt hậu phương: +80 điểm                    │
│    • Chế áp hỏa lực: +75 điểm                          │
│    • Yểm trợ: +55 điểm                                 │
│                                                         │
│  QUY TẮC 6: Hướng bay đến MTBV                         │
│    • Bay thẳng (<18°): +85 điểm                        │
│    • Góc nhỏ (18-30°): +70 điểm                        │
│    • Hệ số khoảng cách: x1.5 nếu <5km                  │
│                                                         │
│  QUY TẮC 7: Thời gian tiếp cận                         │
│    • Đã trong vùng tối ưu: +95 điểm                    │
│    • Sắp vào (<20s): +90 điểm                          │
│    • Thời gian càng ngắn → điểm càng cao               │
│                                                         │
│  QUY TẮC 8: Vị trí so với ĐVHL                         │
│    • Gần phân giác (<15°): +80 điểm                    │
│    • Xa phân giác dần → điểm giảm                      │
│                                                         │
│  CHUẨN HÓA: Bⱼ = min(score/75, 10)                     │
│  File: Block6p_CalculateBj.m, calculateThreatLevel.m   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KHỐI 11: Kiểm tra đã xét hết mục tiêu chưa?           │
│  File: AirSituation.evaluateAllTargets()               │
└────────────────────┬────────────────────────────────────┘
                     │
                     ├─── CHƯA ──► Quay lại KHỐI 1 (mục tiêu tiếp)
                     │
                     │ RỒI
                     ▼
┌─────────────────────────────────────────────────────────┐
│  KẾT THÚC: Có danh sách ưu tiên Bⱼ cho tất cả MT       │
│  • Sắp xếp theo Bⱼ giảm dần                             │
│  • Phân công ĐVHL                                       │
│  • Hiển thị với gradient màu                            │
└─────────────────────────────────────────────────────────┘
```

## Gradient màu sắc theo Bⱼ

```
Bⱼ/10   Priority   Màu           RGB          Mức độ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
≥0.8      ≥80%     🔴 Đỏ tươi    (1.0, 0.0, 0.0)   CỰC NGUY HIỂM
0.6-0.8   60-80%   🟠 Đỏ cam     (1.0, 0.3, 0.0)   NGUY HIỂM CAO
0.4-0.6   40-60%   🟠 Cam        (1.0, 0.6, 0.0)   NGUY HIỂM TB
0.2-0.4   20-40%   🟡 Vàng       (1.0, 1.0, 0.0)   NGUY HIỂM THẤP
<0.2      <20%     🟢 Xanh lá    (0.0, 1.0, 0.0)   ÍT NGUY HIỂM
```

## Ví dụ tính toán

### Mục tiêu: B52 có chỉ thị cấp trên

```
KHỐI 1: x=0, y=50000, H=18000, v=500m/s, Q=180°
KHỐI 2: D=50km → TRONG VÙNG ✓
KHỐI 3: Có chỉ thị cấp trên ✓
        → Bⱼ = 10 (bỏ qua các khối tiếp)
KHỐI 11: Chuyển mục tiêu tiếp

KẾT QUẢ: Bⱼ = 10/10 = Priority 100% → ĐỎ TƯƠI
```

### Mục tiêu: Fighter cơ động cao tấn công SCH

```
KHỐI 1: x=-15000, y=30000, H=10000, v=700m/s
KHỐI 2: D=33.5km → TRONG VÙNG ✓
KHỐI 3: Không có chỉ thị ✗
KHỐI 4: Tiêm kích chiến thuật → 70 điểm
KHỐI 5: Đơn độc → +25 điểm
KHỐI 6: Cơ động 8.5G → +70 điểm, Không gây nhiễu → +0
KHỐI 7: Tấn công SCH → +85 điểm
KHỐI 4'-5': pᵢⱼ, τᵢⱼ (tính toán)
KHỐI 6': 
  QT2: 70 (tiêm kích)
  QT3: 70 (cơ động) + 85 (tấn công SCH) = 155
  QT4: 25 (đơn độc)
  QT5-8: ~250 điểm
  TỔNG: ~570 điểm
  Bⱼ = 570/75 = 7.6 → min(7.6, 10) = 7.6
KHỐI 11: Tiếp tục

KẾT QUẢ: Bⱼ = 7.6/10 = Priority 76% → ĐỎ CAM
```

## Files liên quan

| Khối | File chính | File phụ |
|------|------------|----------|
| 1 | Block1_EvaluateMotion.m | - |
| 2 | Block2_CheckZone.m | - |
| 3 | Block6p_CalculateBj.m | - |
| 4 | Block4_RecognizeType.m | createTargetDatabase.m |
| 5-7 | calculateThreatLevel.m | - |
| 4'-5' | CalculateCourseParams.m | - |
| 6' | Block6p_CalculateBj.m | calculateThreatLevel.m |
| 11 | AirSituation.m | - |

---

**Tham khảo:** Hình 2.6 - Thuật toán đánh giá tham số THTK  
**Cập nhật:** 2025-11-12
