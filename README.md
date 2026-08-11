# Hệ thống mô phỏng АСУ ПВО

Mô phỏng màn hình hiển thị tình huống trên không (THTK) cho hệ thống tự
động hóa chỉ huy phòng không: theo dõi mục tiêu bay, đánh giá mức độ đe
dọa theo 8 quy tắc, và hiển thị trực quan 2D/3D theo thời gian thực.

**Tác giả:** Trần Tiến Dũng

## Yêu cầu

- MATLAB (khuyến nghị R2021a trở lên)

## Chạy chương trình

Mở `ACY_Simulation.prj` (tự thêm toàn bộ thư mục con vào path), hoặc chạy
trực tiếp:

```matlab
main
```

`main.m` khởi tạo dữ liệu, dựng giao diện, và mở bảng điều khiển. Nhấn
**BẮT ĐẦU** để chạy mô phỏng, tích checkbox để đánh dấu mục tiêu ưu tiên
từ cấp trên.

## Cấu trúc thư mục

```
config.m                   Cấu hình hệ thống
main.m                     Điểm khởi động chương trình

models/                    Các lớp OOP (handle class)
  Target.m                   Mục tiêu trên không
  FireUnit.m                  Đơn vị hỏa lực (S-125)
  SimulationState.m           Trạng thái mô phỏng trung tâm, vòng lặp chính

core/
  init/                      Khởi tạo dữ liệu ban đầu (mục tiêu, ĐVHL, SCH)
  path/                      Sinh đường bay mượt theo waypoints
  simulation/                Cập nhật vị trí, RCS theo cự ly mỗi bước thời gian
  algorithms/                Đánh giá và phân loại mục tiêu
    calculateThreatLevel.m     Tổng hợp điểm đe dọa Bj từ 8 quy tắc
    classifyTarget.m           Nhận dạng loại mục tiêu theo Bảng 2
    predictMission.m           Dự đoán nhiệm vụ mục tiêu
    isTargetInObservationZone.m  Kiểm tra mục tiêu trong vùng quan sát
    rules/                      Từng quy tắc tính điểm đe dọa (quy tắc 2-8)

view/
  gui/                       Dựng giao diện, bảng điều khiển, callbacks
  drawing/                   Vẽ mục tiêu, đường bay, vùng quan sát 2D/3D
  tables/                    Bảng thông tin mục tiêu và tô màu theo mức đe dọa
```
