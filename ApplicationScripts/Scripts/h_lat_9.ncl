;----------------------------------------------------------------------
; h_lat_9.ncl
;----------------------------------------------------------------------
; This script creates a "gsn_csm_pres_hgt" plot, and then shows how
; to create this plot using "gsn_csm_contour" and a "LogLin" object. 
;
; The point of creating this plot from scratch is to allow you more
; control over the look, for example, if you want to change how the
; right Y axis is labeled.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
; Function for setting resources needed for gsn_csm_contour.
;----------------------------------------------------------------------
function set_res_for_pres_hgt_plot(u)
local hgt, hnice, pnice
begin

;---Calculate "nice height values for labeling the right Y axis later.
  hgt   = gsn_geop_hgt(u&lev)
  hnice = tofloat(ispan(tointeger(floor(hgt(0))), \
          tointeger(ceil(hgt(dimsizes(hgt)-1))),4))
  pnice = ftcurv(hgt,u&lev,hnice)  ; Get pres vals at nice hgt vals.

  phres                      = True

  phres@gsnDraw              = False
  phres@gsnFrame             = False

  phres@cnFillOn             = True                 ; turn on color fill
  phres@cnFillPalette        = "BlWhRe"

  phres@tmYRMode             = "Explicit"
  phres@tmYRValues           = pnice
  phres@tmYRLabels           = hnice
  phres@tmYRMinorOn          = False
  phres@tmYRLabelsOn         = True
  phres@tmYROn               = True

  phres@tmYUseLeft           = False
  phres@tmYLMode             = "Explicit"
  phres@tmYLMinorOn          = False
  phres@tmYLValues           = (/1000, 850, 700, 500, 400, 300, 250,\
                                  200,  150, 100,  70,  50,  30,  10/)
  phres@tmYLLabels           = "" + phres@tmYLValues

  phres@tmXBLabelFontHeightF = 0.015
  phres@tmYLLabelFontHeightF = 0.015
  phres@tmYRLabelFontHeightF = 0.015

  phres@tiYAxisString        = u&lev@long_name + " (" + u&lev@units + ")"
  phres@tiMainString         = "gsn_csm_contour / LogLin"
  phres@tiMainFontColor      = "Purple"    ; just to make it stand out

  return(phres)
end

;----------------------------------------------------------------------
; Procedure to add title to right Y axis.
;----------------------------------------------------------------------
procedure add_right_title(wks,plot,title)
local txres, font_height, txid, amres
begin
;---Retrieve font height of left axis string.
  getvalues plot
    "tiXAxisFontHeightF" : font_height
  end getvalues

;---Create a right axis text string to add to plot.
  txres               = True
  txres@txAngleF      = 90.          ; Rotate string clockwise 
  txres@txFontHeightF = font_height  ; Use same font height as left axis

  txid = gsn_create_text(wks, title, txres)


;---Move text string to center/right edge of plot.
  amres                  = True
  amres@amParallelPosF   = 0.65   ; 0.5 is the right edge of the plot, so
                                  ; 0.65 is a little further to the right.
  amres@amOrthogonalPosF = 0.0    ; This is the center of the plot.
  amres@amJust           = "CenterCenter"

  annoid = gsn_add_annotation(plot, txid, amres)  ; Attach string to plot
  return(annoid)
end

;----------------------------------------------------------------------
; Function that overlays a contour plot on a "LogLin" object, which
; allows us to reverse the axis and change it to log.  You cannot
; directly force a contour plot with an "irregular" axis to have 
; a log axis, so this is the only way you can create a log axis.
;----------------------------------------------------------------------
function overlay_on_loglin_object(wks,plot,u)
begin
 loglin = create "loglin" logLinPlotClass wks
    "trYReverse"   : True
    "trYLog"       : True
    "trXMinF"      : min(u&lat)
    "trXMaxF"      : max(u&lat)
    "trYMinF"      : min(u&lev)
    "trYMaxF"      : max(u&lev)
  end create
  overlay(loglin,plot)
  return(loglin)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Open file and read data
  fili  = "mxclim.nc"
  f     = addfile (fili , "r")
  u     = f->U(0,:,:)          ; "u" is a rectilinear grid with "lev"
                               ; and "lat" coordinate arrays.
  printVarSummary(u)

;---Start the graphics
  wks = gsn_open_wks ("png", "h_lat" )       ; send graphics to PNG file

;---First create plot using gsn_csm_pres_hgt for comparison.
  res                 = True
  res@tiMainFontColor = "Purple"             ; just to make it stand out
  res@tiMainString    = "Using gsn_csm_pres_hgt"
  res@cnFillOn        = True                 ; turn on color fill
  res@cnFillPalette   = "BlWhRe"

  plot  = gsn_csm_pres_hgt(wks, u, res)

;----------------------------------------------------------------------
; Recreate the plot using gsn_csm_contour and LogLin object.
; "set_res_for_pres_hgt_plot", "add_right_title", 
; "overlay_on_lonlin_object" are all defined above in this script.
;----------------------------------------------------------------------
  res2 = set_res_for_pres_hgt_plot(u)
  plot = gsn_csm_contour(wks, u, res2)
  add_right_title(wks,plot,"Height (km)")
  ll = overlay_on_loglin_object(wks,plot,u)

  draw(ll)
  frame(wks)   
end
