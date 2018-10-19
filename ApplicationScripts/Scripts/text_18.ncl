;--------------------------------------------------
; text_18.ncl
;
; Concepts illustrated:
;   - Attaching text strings to the top left and right corners of a plot
;   - Setting the background color for a text box
;   - Turning on the perimeter of a text box
;   - Paneling four plots on a page
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U

  wks = gsn_open_wks("png","text")            ; send graphics to PNG file
  
  res              = True                     ; plot mods desired
  res@gsnMaximize  = True
  res@gsnDraw      = False                    ; Turn off draw and frame so
  res@gsnFrame     = False                    ; we can attach some text.

;---Array to hold plots
  plots   = new(4,graphic)

;---Arrays to hold text annotation ids
  txid_tr = new(4,graphic)
  txid_tl = new(4,graphic)
  amid_tr = new(4,graphic)
  amid_tl = new(4,graphic)

  txres                       = True
  txres@txPerimOn             = True
  txres@txFontHeightF         = 0.02

;---Top right string
  amres_tr                  = True
  amres_tr@amParallelPosF   =  0.5    ; This is the right edge of the plot.
  amres_tr@amOrthogonalPosF = -0.5    ; This is the top edge of the plot.
  amres_tr@amJust           = "TopRight"

;---Top left string
  amres_tl                  = True
  amres_tl@amParallelPosF   = -0.5    ; This is the left edge of the plot.
  amres_tl@amOrthogonalPosF = -0.5    ; This is the top edge of the plot.
  amres_tl@amJust           = "TopLeft"


;---Generate plots at four different latitudes
  lons = (/0.,20.,40, 60./)
  do i=0,3
    u_subset := u(0,:,{lons(i)})

;---Create plot
    plots(i)   = gsn_csm_xy(wks,u&lat,u_subset,res)

;---Create text strings
    tr_label = (i + 1) + ")"
    tl_label = "lon=" + sprintf("%5.2f",u_subset@lon)

    txres@txBackgroundFillColor = "Goldenrod"
    txid_tr(i) = gsn_create_text(wks, tr_label, txres)

    txres@txBackgroundFillColor = "LawnGreen"      ; just for something different
    txid_tl(i) = gsn_create_text(wks, tl_label, txres)

;---Attach text strings to plot
    amid_tr(i) = gsn_add_annotation(plots(i), txid_tr(i), amres_tr)
    amid_tl(i) = gsn_add_annotation(plots(i), txid_tl(i), amres_tl)
  end do

;---Paneling the plot will also resize the text strings appropriately.
  pres              = True
  pres@gsnMaximize  = True
  gsn_panel(wks,plots,(/2,2/),pres)
   
end
