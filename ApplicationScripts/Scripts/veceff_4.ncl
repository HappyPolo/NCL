; *************************************************************************
; veceff_4.ncl
;
; Concepts illustrated:
;   - Drawing vector plots
;   - Drawing color-filled vectors
;   - Changing the length of the vectors
;   - Coloring vectors based on magnitude
;   - Changing the length of the smallest vector as a fraction of the reference vector
;   - Outlining vectors
;   - Thinning vectors using a minimum distance resource
;   - Thinning vectors by striding the data
;   - Explicitly setting the fill colors for vectors
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
  path = ncargpath("data") + "/cdf/"
  uv   = addfile(path + "941110_UV.cdf","r")

  wks = gsn_open_wks ("png", "veceff")       ; send graphics to PNG file

  res                     = True

  res@gsnMaximize          = True    ; Maximize plot in frame

  res@vcLevelColors            = (/28,30,32,34,36,38,40,42,45,48,51,54,57,60 /)


  res@vcLevelPalette           = "temp1"
  res@vcRefMagnitudeF          = 20.0
  res@vcRefLengthF             = 0.04
  res@vcMinFracLengthF         = 0.25

  res@vcFillArrowsOn           = True
  res@vcMonoFillArrowFillColor = False     ; Color according to magnitude
  res@vcFillArrowEdgeColor     = "black"

  res@vcMinDistanceF           = 0.003

  res@tiMainString             = "vcMinDistanceF = " + res@vcMinDistanceF
  vector = gsn_vector(wks,uv->u,uv->v,res)

  res@vcMinDistanceF           = 0.01
  res@tiMainString             = "vcMinDistanceF = " + res@vcMinDistanceF

  vector = gsn_vector(wks,uv->u,uv->v,res)

  delete(res@vcMinDistanceF)
  res@tiMainString             = "Striding the data by ::2"
  vector = gsn_vector(wks,uv->u(::2,::2),uv->v(::2,::2),res)

end
