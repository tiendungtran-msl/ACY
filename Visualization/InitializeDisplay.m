function InitializeDisplay(ax_2d, ax_3d, cfg)
    %% KHỞI TẠO MÀN HÌNH HIỂN THỊ
    % Mô tả: Thiết lập các thông số hiển thị cho axes 2D và 3D
    % Input:
    %   - ax_2d: Axes 2D
    %   - ax_3d: Axes 3D
    %   - cfg: Cấu hình hệ thống (optional)
    
    if nargin < 3
        cfg = config();
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % THIẾT LẬP AXES 2D
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    axes(ax_2d);
    grid on;
    axis equal;
    hold on;
    
    % Giới hạn hiển thị
    xlim([-50000, 50000]);
    ylim([-20000, 80000]);
    
    % Nhãn trục
    xlabel('X (m)', 'FontSize', 10);
    ylabel('Y (m)', 'FontSize', 10);
    title('Tình huống trên không - 2D', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Lưới
    if cfg.display_grid
        grid on;
        set(ax_2d, 'GridLineStyle', ':', 'GridAlpha', 0.3);
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % THIẾT LẬP AXES 3D
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if nargin >= 2 && ~isempty(ax_3d)
        axes(ax_3d);
        grid on;
        hold on;
        
        % Giới hạn
        xlim([-50000, 50000]);
        ylim([-20000, 80000]);
        zlim([0, 25000]);
        
        % Nhãn
        xlabel('X (m)');
        ylabel('Y (m)');
        zlabel('Độ cao (m)');
        title('Tình huống trên không - 3D');
        
        % Góc nhìn
        view(45, 30);
        
        % Lưới
        if cfg.display_grid
            grid on;
        end
    end
    
end
