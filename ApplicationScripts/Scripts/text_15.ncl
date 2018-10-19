;*************************************************
; text_15.ncl
;
; Concepts illustrated:
;   - Adding text strings to a cell-filled contour plot
;   - Using "sprintf" to create nicely formatted text strings
;   - Removing trailing zeros from tickmark labels
;   - Maximizing plots after they've been created
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Function for adding data values to an existing contour plot
;----------------------------------------------------------------------
function add_data_values(wks,plot,data)
local tid, txres, i, j, dx, dy, dx10, dy10, NX, NY, xjust, yjust, xpos, ypos
begin
 dims = dimsizes(data)
 NY   = dims(0)
 NX   = dims(1)

;---Create array to hold text strings
  tid = new(dims,graphic)

;---Set some text resources
  txres               =  True
  txres@txFontHeightF = 0.007

;---Calculate some deltas for later.
  dx   = data&x(1) - data&x(0)
  dy   = data&y(1) - data&y(0)
  dx10 = dx/10.
  dy10 = dy/10.

;---Loop through each x,y point and determine location of string
  do i=0,NX-1
    xpos  = data&x(i)
    xjust = "center"         ; Default is to put text at center of box

;---Check for special cases at left or right edge of plot
    if(i.eq.0) then
      xjust = "left"         ; Left justify the text
      xpos  =  xpos + dx10
    end if
    if(i.eq.(NX-1)) then
      xjust = "right"        ; Right justify the text
      xpos  =  xpos - dx10
    end if

    do j=0,NY-1
      ypos  = data&y(j)
      yjust = "center"         ; Default is to put text at center of box
 
;---Check for special cases at top or bottom of plot
      if(j.eq.0) then
        yjust = "bottom"        ; Bottom justify the text
        ypos  =  ypos + dy10
      end if
      if(j.eq.(NY-1)) then
        yjust = "top"           ; Top justify the text
        ypos  =  ypos - dy10
      end if

;---Set the justification.
      txres@txJust = yjust + xjust

;---Format text string
      tstr         = sprintf("%6.2f",data(j,i)) 

;---By adding to plot, text will get drawn when plot gets drawn.
      tid(i,j) = gsn_add_text(wks,plot,tstr,xpos,ypos,txres)
    end do
  end do

  return(tid)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Generate some dummy data.
  nx   = 10
  ny   = 10
  data = generate_2d_array(11, 11, -14, 13, 0, (/nx,ny/))

;---Generate dummy coord arrays
  xcoord = fspan(10,19,nx)
  ycoord = fspan(25,34,ny)

  data!0 = "y"
  data!1 = "x"
  data&x = xcoord
  data&y = ycoord

;---Open PS workstation and change colormap.

  wks = gsn_open_wks("png","text")  ; send graphics to PNG file

;---Set up resources.
  res                      = True

  res@gsnDraw              = False
  res@gsnFrame             = False

  res@gsnMaximize          = True


  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF	   = -15
  res@cnMaxLevelValF	   =  16
  res@cnLevelSpacingF	   =  1.0

  res@tmYLFormat           = "f"          ; No trailing 0's
  res@lbOrientation        = "Horizontal"

  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@cnLineLabelsOn       = False

  res@cnFillOn             = True
  res@cnFillPalette        = "StepSeq25"
  res@cnFillMode           = "CellFill"

  res@lbOrientation        = "Vertical"

  res@tiMainString         = "Adding data values to cell-filled plot"

;---Create cell filled plot.
  plot  = gsn_csm_contour(wks,data,res)

;---Attach data values
  txid = add_data_values(wks,plot,data)

  draw(plot)
  frame(wks)
end
