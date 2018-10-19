;================================================;
;  conwomap_3.ncl
;
; Concepts illustrated:
;   - Drawing a simple contour plot
;   - Generating dummy data using "random_normal"
;   - Masking mirrored contour data
;   - Drawing a perimeter around areas on a contour plot with missing data
;   - Turning off the bottom and right borders of a contour plot
;   - Using "getvalues" to retrieve resource values
;   - Changing the labels and tickmarks on a contour plot
;   - Adding a complex Greek character to a contour plot
;   - Moving the contour informational label into the plot
;   - Forcing tickmarks and labels to be drawn on the top X axis in a contour plot
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
begin
; -------------------------------------------------
; Bogus 2D Data
; -------------------------------------------------
  mx  = 31
  ny  = 31 
	
  u   = random_normal(0.0, 3.0, (/ny,mx/))  
  u!0 = "y"
  u!1 = "x"
  u&x = ispan(0,mx-1,1)
  u&y = ispan(0,ny-1,1)
  u@_FillValue = -999.
; -------------------------------------------------
; set lower half to missing
; -------------------------------------------------
  do n=0,ny-1
   do m=n+1,mx-1
      u(n,m:) = u@_FillValue
   end do
  end do
; -------------------------------------------------
; plot
; -------------------------------------------------
  wks  = gsn_open_wks("png","conwomap")   ; send graphics to PNG file

  res = True
  res@cnMissingValPerimOn         =  True ; perimeter around missing data 
  res@cnMissingValPerimThicknessF =  2.0  ; thickness of perimeter
  res@cnInfoLabelOrthogonalPosF   = -0.05 ; shift upward into plot


  res@tmXTLabelsOn  = True         ; Turn on top labels
  res@tmYROn        = False        ; Turn off right tick marks
  res@tmXBOn        = False        ; Turn off bottom tick marks
  res@tmXBBorderOn  = False 	   ; Turn off bottom border
  res@tmYRBorderOn  = False 	   ; Turn off right border

  res@tiYAxisString = "wave number"  ; Label the Y-axis 

  res@gsnDraw       = False          ; do not draw 
  res@gsnFrame      = False          ; do not advance

  plot = gsn_csm_contour(wks,u,res)  ; contour the variable
;*****************************************************************
; get some info from the plot object to use in constructing an
; extra plot string
;*****************************************************************
 getvalues plot                     
   "tmYLLabelFontHeightF"   : fheight
   "tmXTValues"             : tmXTValues
   "tmYLValues"             : tmYLValues
 end getvalues
 nTm  = dimsizes(tmXTValues)               ; number of major tick marks

 txres               = True                            
 txres@txFontHeightF = fheight             ; Set the font height

 label = "J(~F8~a~N~)"                     ; txFuncCode is ~ 
 text = gsn_add_text(wks,plot,label,0.75*tmXTValues(nTm-1), \
                                    0.35*tmYLValues(nTm-1) ,txres)

 draw(plot)
 frame(wks)

end
