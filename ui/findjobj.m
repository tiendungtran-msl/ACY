function jObj = findjobj(hObj)
    %% TÌM JAVA OBJECT TỪ MATLAB HANDLE (ĐƠN GIẢN HÓA)
    
    jObj = [];
    
    try
        % Tắt warning
        warning('off', 'MATLAB:ui:javacomponent:FunctionToBeRemoved');
        
        % Thử lấy Java peer object
        if isprop(hObj, 'JavaPeer')
            jObj = hObj.JavaPeer;
        elseif isprop(hObj, 'JavaFrame')
            jObj = hObj.JavaFrame;
        else
            % Thử cách khác cho uitable
            drawnow;
            pause(0.01);
            
            % Lấy tất cả Java components
            allJava = findall(hObj);
            for k = 1:length(allJava)
                try
                    temp = get(allJava(k));
                    if isfield(temp, 'JavaPeer')
                        jObj = temp.JavaPeer;
                        break;
                    end
                catch
                    continue;
                end
            end
        end
    catch
        % Không làm gì nếu thất bại
    end
end