;================================================;
;  conwomap_4.ncl
;
; Concepts illustrated:
;   - Drawing a simple contour plot
;   - Generating dummy data using "random_normal"
;   - Masking mirrored contour data
;   - Turning off the bottom and right borders of a contour plot
;   - Changing the labels and tickmarks on a contour plot
;   - Adding a complex Greek character to a contour plot
;   - Moving the contour informational label into the plot
;   - Forcing tickmarks and labels to be drawn on the top X axis in a contour plot
;   - Paneling six plots on a page
;   - Adding a common title to paneled plots
;   - Naming dimensions of an array
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
;--------------------------------------------------------------------------
begin
; -------------------------------------------------
; Bogus Data
; -------------------------------------------------
  kz  = 6
  mx = 31
  ny  = mx 
	
  u   = random_normal (0.0, 3.0, (/kz,ny,mx/))  
  u!0 = "z"
  u!1 = "y"
  u!2 = "x"
  u&x = ispan(0,mx-1,1)
  u&y = ispan(0,ny-1,1)
  u@_FillValue = -999.
; -------------------------------------------------
; set lower half to missing
; -------------------------------------------------
  do n=0,ny-1
     do m=n+1,mx-1
        u(:,n,m:) = u@_FillValue
     end do
  end do
; -------------------------------------------------
; plot
; -------------------------------------------------
  plot  = new (kz, graphic)
  label = new (kz, string)

  label = (/ "J(~F8~a~N~)" \
           , "~F8~F~N~(~F8~a~N~)" \
           , "~F8~L~N~(~F8~a~N~)" \
           , "~F8~c~N~(~F8~a~N~)" \
           , "~F8~l~N~(~F8~a~N~)" \
           , "~F8~q~N~(~F8~a~N~)" /)

  wks  = gsn_open_wks("png","conwomap") ; send graphics to PNG file

  res = True
  res@gsnDraw  = False                  ; don't draw
  res@gsnFrame = False                  ; don't advance frame

  do k = 0,kz-1                         ; generate objects
     plot(k) = upperTriCntr(wks,u(k,:,:),label(k),res)
  end do

  resP = True                          ; panel resources
  resP@gsnMaximize = True              ; make as large as possible
  resP@txString    = "Sample Title"    ; (optional) common title 
  gsn_panel(wks,plot,(/3,2/),resP)
end
