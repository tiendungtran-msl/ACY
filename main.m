%% ============================================================
%% HỆ THỐNG TỰ ĐỘNG HÓA CHỈ HUY PHÒNG KHÔNG - MAIN SCRIPT
%% Air Defense Command Automation System (АСУ ПВО)
%% ============================================================
% Tác giả: Trần Tiến Dũng
% Mô tả: Script chính khởi động hệ thống mô phỏng
%% ============================================================

clear; clc; close all;

%% PATH SETUP — thêm tất cả subfolders vào MATLAB path
% Cần thiết khi chạy ngoài MATLAB Project (ACY_Simulation.prj)
rootDir = fileparts(mfilename('fullpath'));
addpath(genpath(rootDir));

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════╗\n');
fprintf('║       HỆ THỐNG TỰ ĐỘNG HÓA CHỈ HUY PHÒNG KHÔNG       ║\n');
fprintf('║     Air Defense Command Automation System (АСУ ПВО)  ║\n');
fprintf('╚══════════════════════════════════════════════════════╝\n');
fprintf('\n');

%% BƯỚC 0: Tải cấu hình
fprintf('[0/6] Đang tải cấu hình...\n');
cfg = config();

%% BƯỚC 1: Khởi tạo dữ liệu (trả về Target / FireUnit handle objects)
fprintf('[1/6] Đang khởi tạo dữ liệu...\n');
[SCH, targets_protect, fire_units, targets] = initializeData();

%% BƯỚC 2: Tạo đường cong chuyển động (sửa trực tiếp trên Target handles)
fprintf('[2/6] Đang tạo đường cong chuyển động...\n');
createSmoothPaths(targets);

%% BƯỚC 3: Thiết lập giao diện
fprintf('[3/6] Đang thiết lập giao diện...\n');
[fig, ax_main, ax_3d] = setupGUI();

%% BƯỚC 4: Vẽ các thành phần tĩnh
fprintf('[4/6] Đang vẽ môi trường...\n');
drawStaticElements(ax_main, ax_3d, SCH, targets_protect, fire_units);
drawPlannedPaths(ax_main, ax_3d, targets);

%% BƯỚC 5: Tạo bảng điều khiển (callbacks sẽ được ghi đè ở Bước 6)
fprintf('[5/6] Đang tạo bảng điều khiển...\n');
[target_tables, buttons, checkboxes] = createControlPanel(fig, targets);

%% BƯỚC 6: Khởi tạo SimulationState (handle class trung tâm)
%   - Lưu reference vào appdata (một lần duy nhất)
%   - Đăng ký callbacks cho tất cả nút và checkbox
fprintf('[6/6] Đang khởi tạo SimulationState...\n');
state = SimulationState(fig, targets, SCH, targets_protect, fire_units, ...
    ax_main, ax_3d, target_tables, buttons, checkboxes);

%% BƯỚC 7: Cửa sổ Ground Truth và cập nhật bảng lần đầu
fprintf('[7/7] Đang tạo cửa sổ Ground Truth...\n');
state.gt_window = createGroundTruthWindow(targets);

updateAllTargetTables(state);
updateGroundTruthTables(state.gt_window, state.targets, state.SCH, state.fire_units);

fprintf('\n✓ Hệ thống đã sẵn sàng!\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('▶ Nhấn "BẮT ĐẦU" để khởi động mô phỏng\n');
fprintf('☐ Tích checkbox để đánh dấu ưu tiên từ cấp trên\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n');
