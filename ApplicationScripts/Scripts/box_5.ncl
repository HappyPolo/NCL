;*********************************************
; box_5.ncl
;
; Concepts illustrated:
;   - Drawing box plots
;   - Using a box plot to show the the median, minimum/maximum value, and the 25th/75th percentiles of two time series
;   - Adding text to a box plot
;   - Sorting data
;   - Setting the mininum/maximum value of the Y axis in a box plot
;   - Generating dummy data using "random_normal"

;
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*********************************************
begin
  nor  = random_normal(292,15,(/125/))  ; set up data
  dimt = dimsizes(nor)
  x25  = round(.25*dimt,3)-1     ; -1 to account for NCL indexing starting
  x75  = round(.75*dimt,3)-1     ; at 0            
  nor2 = random_normal(295,14,(/125/))

  qsort(nor)         ; sort the data
  qsort(nor2)  

  iarr=new((/2,5/),float) ; fill with minimum, 25th percentile, median, 
                          ; 75th percentile, maximum of each time series
  iarr(0,:) = (/min(nor),nor(x25),dim_median(nor),nor(x75),max(nor)/)  
  iarr(1,:) = (/min(nor2),nor2(x25),dim_median(nor2),nor2(x75),max(nor2)/)

  wks = gsn_open_wks("png","box")               ; send graphics to PNG file

  res            = True                         ; plot mods desired
  res@tmXBLabels = (/"Control","Run A"/) ; labels for each box
  res@tiMainString = "Box Plot"
  res@trYMinF = 230.
  res@trYMaxF = 345.

  plot = boxplot(wks,(/0,1/),iarr,False,res,False)	
  draw(wks)                                    ; boxplot does not call these
  frame(wks)                                   ; for you
end
