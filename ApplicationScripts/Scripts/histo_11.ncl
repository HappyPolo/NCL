;*************************************************
; histo_11.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "random_uniform"
;   - Changing the width of the bars in a histogram
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;************************************************
begin
;************************************************
; Generate some random data.
;************************************************
  z = new((/2,1000/),float)
  z(0,:) = random_uniform(0,320.,1000)
  z(1,:) = random_uniform(0,320.,1000)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","histo")              ; send graphics to PNG file
  gsn_define_colormap(wks,"temp1")               ; choose colormap

  res                             = True        ; plot mods desired
  res@gsnHistogramBarWidthPercent = 80.
  res@tiMainString                = "Bar width is 80% of bin width"
  plot=gsn_histogram(wks,z(0,:),res)                  ; create histogram

  res@gsnHistogramBarWidthPercent = 100.
  res@tiMainString                = "Bar width is 100% of bin width"
  plot=gsn_histogram(wks,z(0,:),res)                  ; create histogram

  res@gsnHistogramBarWidthPercent = 70.
  res@tiMainString                = "Bar width is 70% of bin width"
  plot=gsn_histogram(wks,z,res)                  ; create histogram
end
