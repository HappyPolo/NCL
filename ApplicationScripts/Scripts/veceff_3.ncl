; *************************************************************************
; veceff_3.ncl
;
; Concepts illustrated:
;   - Drawing vector plots
;   - Drawing color-filled vectors
;   - Changing the length of the vectors
;   - Changing the length of the smallest vector as a fraction of the reference vector
;   - Coloring vectors with a single color
;   - Outlining vectors
;   - Controlling the size and appearance of the vector arrow heads
;   - Reading data from an ASCII file
;
; *************************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
; 
; Read data from an ASCII file
;
  path = ncargpath("data") + "/asc/"
  data = asciiread(path + "uvdata0.asc",(/2,37,37/),"float")

  wks   = gsn_open_wks ("png", "veceff")       ; send graphics to PNG file

  res                     = True

  res@gsnMaximize          = True    ; Maximize plot in frame

  res@vcFillArrowsOn       = True
  res@vcRefMagnitudeF      = 20.
  res@vcRefLengthF         = 0.02
  res@vcMinFracLengthF     = 0.2
  res@vcFillArrowEdgeColor = "black"
  res@vcFillArrowFillColor = "green"

  res@vcFillArrowsOn       = True
  res@tiMainString         = "Filled arrows"

  vector = gsn_vector(wks,data(0,:,:),data(1,:,:),res)

  res@vcFillArrowWidthF         = 0.15
  res@vcFillArrowMinFracWidthF  = 1.0
  res@vcFillArrowHeadMinFracXF  = 0.0
  res@vcFillArrowWidthF         = 0.2
  res@vcFillArrowHeadXF         = 0.8
  res@vcFillArrowHeadInteriorXF = 0.7
  res@vcFillArrowHeadYF         = 0.2

  res@tiMainString              = "Filled arrows (variation #2)"

  vector = gsn_vector(wks,data(0,:,:),data(1,:,:),res)

  res@vcRefLengthF              = 0.01593447
  res@vcFillArrowWidthF         = 0.2
  res@vcFillArrowHeadXF         = 1.5
  res@vcFillArrowHeadInteriorXF = 1.0
  res@vcFillArrowHeadYF         = 0.5

  res@tiMainString              = "Filled arrows (variation #3)"

  vector = gsn_vector(wks,data(0,:,:),data(1,:,:),res)

end
