;*************************************************
; panel_19.ncl
;
; Concepts illustrated:
;   - Paneling four plots on a page
;   - Adjusting the X,Y positions of plots in a panel
;   - Using a blue-white-red color map
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

function conv_date(date:integer)
begin
print(date)
  months = (/"","January","February","March","April","May","June","July", \
             "August","September","October","November","December"/)
  year      = str_get_cols(date,0,3)
  imnth     = toint(str_get_cols(date,4,5))
  month     = months(imnth)
  return(month + " " + year)
end

begin
  a = addfile("sst8292a.nc","r")
;************************************************
; Read in Sea Surface Temperature Anomalies
; Determine the subscripts corresponding to Dec 82
;************************************************
  sst      = a->SSTA
  date_sst = a->date

  ind_sst  = ind(date_sst.eq.198212)

;************************************************
; create plots
;************************************************
  plots = new(4,graphic)
  
  wks = gsn_open_wks("png","panel")             ; send graphics to PNG file

  res                      = True
  res@gsnMaximize          = True
  res@gsnDraw              = False              ; don't draw
  res@gsnFrame             = False              ; don't advance frame

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -5.                ; set min contour level
  res@cnMaxLevelValF       =  5.                ; set max contour level
  res@cnLevelSpacingF      =  0.5               ; set contour spacing

  res@cnFillOn         = True
  res@cnLinesOn        = False
  res@cnLineLabelsOn   = False
  res@cnFillDrawOrder  = "Predraw"             ; fill and lines before map
  res@lbLabelBarOn     = False
  res@cnFillPalette    = "BlueRed"             ; Blue-Red colormap

  res@mpCenterLonF     = 180.                   ; center plot at 180
  res@mpMinLonF        = 100.                   ; select a subregion
  res@mpMaxLonF        = 300.
  res@mpMinLatF        = -60. 
  res@mpMaxLatF        =  60.

  res@gsnLeftString    = "degC" 
  res@gsnRightString   = "(W m s~S~-2~N~)"     ; "~" is txFuncCode
  res@tiMainString     = ""

  res@tmYROn           = False     ; Turn off right and top tick marks
  res@tmXTOn           = False     ; Turn off right and top tick marks

  dates = (/198212,199008,198705,198411/)
  do i=0,3
    res@gsnCenterString = conv_date(dates(i))
    ind_sst = ind(date_sst.eq.dates(i))
    plots(i) = gsn_csm_contour_map(wks,sst(ind_sst,:,:),res)
    delete(ind_sst)
  end do

  pnlres = True
  pnlres@gsnPanelMainString   = "Default X and Y positions of all plots"
; pnlres@txString   = "Default X and Y positions of all plots"
  pnlres@gsnPanelLabelBar  = True
  pnlres@lbLabelAutoStride = True
  pnlres@gsnPanelDebug     = True     ; To get information from panel
  gsn_panel(wks,plots,(/2,2/),pnlres)

  pnlres@gsnPanelMainString   = "Adjust X position of rightmost plots"
; pnlres@txString   = "Adjust X position of rightmost plots"
  pnlres@gsnPanelXF = (/-1,.53,-1,.53/)    ; Adjust rightmost plots
  gsn_panel(wks,plots,(/2,2/),pnlres)

  pnlres@gsnPanelMainString   = "Adjust Y position of bottommost plots"
; pnlres@txString   = "Adjust Y position of bottommost plots"
  pnlres@gsnPanelYF = (/-1,-1,.48,.48/)      ; Adjust bottommost plots.

  gsn_panel(wks,plots,(/2,2/),pnlres)

end
