; *************************************************************************
; veceff_2.ncl
;
; Concepts illustrated:
;   - Drawing vector plots
;   - Changing the length of the vectors
;   - Changing the length of the smallest vector as a fraction of the reference vector
;   - Coloring vectors based on magnitude
;   - Spanning the full color map for colored vectors
;   - Creating a main title
;   - Controlling the size of the vector arrow heads
;   - Transposing an array
;   - Naming dimensions of an array
;   - Generating dummy data
;
; *************************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Generate dummy vector data arrays
;
  M  = 30
  N  = 25
  PI = 3.14159

  V = 10.0 * cos(onedtond((2.0 * PI / M) * ispan(0,M-1,1),(/N,M/)))
  U = 10.0 * cos(onedtond((2.0 * PI / N) * ispan(0,N-1,1),(/M,N/)))
 
  U!0 = "x"   ; Name U's dimensions so we can transpose it
  U!1 = "y"
  Ut  = U(y|:,x|:)

  wks   = gsn_open_wks ("png", "veceff")       ; send graphics to PNG file

  res                      = True

  res@gsnMaximize          = True    ; Maximize plot in frame

  res@vcMonoLineArrowColor = False   ; color arrows based on magnitude
  res@vcRefLengthF         = 0.03313608
  res@vcMinFracLengthF     = 0.3
  res@vcLevelPalette       = "temp1" ; set color map
; 
; Setting the reference magnitude also affects the length
; of the arrows. In this case it is an inverse relationship.
;
  res@vcRefMagnitudeF = 20.0
;
; Line-drawn arrowheads are sized proportionally to the arrow length 
; unless the resulting size would be outside the limits defined by 
; the arrowhead minimum and maximum size resources. Setting the 
; minimum and maximum sizes to the same value causes all the
;
  res@tiMainString            = "Uniformly-sized Arrow Heads"
  res@vcLineArrowHeadMinSizeF = 0.01
  res@vcLineArrowHeadMaxSizeF = 0.01

  vector = gsn_vector(wks,Ut,V,res)
end
