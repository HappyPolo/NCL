function hi = heatindex(t, rh)
%% This function computes the NWS heat index using the Rothfusz regression.
%  
% Input:
%   t: temperature (in degree Celsius)
%   rh: relative humidity (in percentage)
%
% Output:
%   hi: heat index (in degree Celsius)
%
%
% This script is implimented by by Dr. Ming Luo at Sun Yat-sen University
% (email: luom38@mail.sysu.edu.cn; luo.ming@hotmail.com). For those using 
% this script, your are recommended to cite the following paper in your work: 
%
%   Luo, M., & Lau, N.-C. (2018). Increasing heat stress in urban areas of 
%   eastern China: Acceleration by urbanization. Geophysical Research Letters, 
%   https://doi.org/10.1029/2018GL080306
%
%
% Reference:
%   Lans P. Rothfusz (1990): NWS Technical Attachment (SR 90-23)
%   http://www.wpc.ncep.noaa.gov/html/heatindex_equation.shtml 
%


%% Check the size of input variables
isEqualSize = isequal(size(t), size(rh)) || (isvector(t) && isvector(rh) && numel(t) == numel(rh));
if ~isEqualSize
    msgbox('Input variables must have the same size.', 'Error', 'error');
    return;
end


%% Convert temperature to Fahrenheit scale
t = convtemp(t, 'C', 'F');


%% 1. Start to calculate hi using the simple formula first
alpha = 61 + ((t - 68) * 1.2) + (rh * 0.094);
hi = 0.5 * (alpha + t);

% %% Calculate hi when t <= 40 (optional)
% idx1 = find(t <= 40);
% hi(idx1) = t(idx1); 

%% 2. Calculate hi using the full Rothfusz regression when hi >= 80
idx2 = find(hi >= 80);
hi(idx2) = -42.379 + 2.04901523 * t(idx2) + 10.14333127 * rh(idx2) ...
     - 0.22475541 * t(idx2) .* rh(idx2) - 0.00683783 * t(idx2).^2 ...
     - 0.05481717 * rh(idx2).^2 + 0.00122874 * t(idx2).^2 .* rh(idx2) ...
     + 0.00085282 * t(idx2) .* rh(idx2).^2 -  0.00000199 * t(idx2).^2 .* rh(idx2).^2;
                                                
 
%% 3. Substract adjustment from hi when rh < 13 & t >= 80 & t <= 112
idx3 = intersect(idx2, find(rh < 13 & t >= 80 & t <= 112));
 
adjustment1 = (13 - rh(idx3)) / 4;
adjustment2 = sqrt((17 - abs(t(idx3) - 95)) / 17);
total_adjustment = adjustment1 .* adjustment2;
hi(idx3) = hi(idx3) - total_adjustment;
 
 
%% 4. Add addjustment to hi when rh > 85 & t >= 80 & t <= 87
idx4 = intersect(idx2, find(rh > 85 & t >= 80 & t <= 87));

adjustment1 = (rh(idx4) - 85) / 10;
adjustment2 = (87 - t(idx4)) / 5;
total_adjustment = adjustment1 .* adjustment2;
hi(idx4) = hi(idx4) + total_adjustment;
 
                                
%% Convert hi to Celcius scale
hi = convtemp(hi, 'F', 'C');



