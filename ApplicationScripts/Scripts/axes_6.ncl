;----------------------------------------------------------------------
; axes_6.ncl
;
; Concepts illustrated:
;   - Increasing the range of an X or Y axes when you have coordinate values
;   - Increasing the size of an array
;   - Explicitly setting tickmarks and labels on the left Y axis
;   - Paneling three plots on a page
;   - Reversing the Y axis
;----------------------------------------------------------------------
; This script shows how to increase the range of X and/or Y axis,
; when you have coordinate arrays assigned to each axis.  NCL
; won't let you do this, because it can't make any assumptions how
; to draw the extra range values.
;
; It's up to the user to increase the desired coordinate arrays 
; by whatever range they want, and also increase the data array
; being plotted, by the same size as the new coorindate arrays.
;
; The atmos.nc dataset can be found on Yellowstone in the following path:
;
; /glade/u/ncldev/test/ncargtest/nclscripts/cdf_files/atmos.nc 
;----------------------------------------------------------------------
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read data
 f     = addfile("atmos.nc","r") 
 u     = f->U(0,:,:,:)       

 hyam   = f->hyam
 hybm   = f->hybm
 ps     = f->PS 
 p0     = 1000.
 pres3d      = (/1000,950,800,700,600,500,400,300,200/)
 pres3d@units= "mb"

 nlat     = dimsizes(u&lat) 
 nlev     = dimsizes(pres3d)

;---Interpolate and take the average over longitude dimension
 u_int = (/vinth2p(u,hyam,hybm,pres3d,ps(0,:,:),2,\
                   p0,2,False)/)
 uzon = dim_avg(u_int)
 
;---Start the graphics
 wks   = gsn_open_wks ("png", "axes" ) ; send graphics to PNG file

 res                 = True

 res@gsnDraw         = False     ; Will panel later
 res@gsnFrame        = False   

 res@cnFillOn        = True 
 res@lbOrientation   = "Vertical"

 res@trYReverse      = True    ; Flip the level axis
 res@sfXArray        = u&lat
 res@sfYArray        = pres3d

;---Create first plot with original coordinates
 res@tiMainString    = "Original lev x lat array (" + nlat + "x" + nlev + ")"  
 plot1 = gsn_csm_contour(wks, uzon, res ) 

;
; Add -90 and 90 values to latitude array and
; also increase uzon by two elements in
; latitude dimension.
;
 uzon_new_lat = new((/nlev,nlat+2/),typeof(uzon))
 uzon_new_lat(:,1:nlat) = uzon
 
;---Create the new latitude array with 2 extra elements
 lat_new         = new(nlat+2,typeof(u&lat))
 lat_new(0)      = -90
 lat_new(1:nlat) = u&lat
 lat_new(nlat+1) =  90

;---Increase range of X axis to match what we added to new lat array
 res@trXMinF         = -90     ; min(lat_new)
 res@trXMaxF         = 90      ; max(lat_new)
 res@sfXArray        := lat_new     ; Assign new coordinate array

;---Create second plot with new latitude coordinates
 res@tiMainString    = "Array increased by 2 lat elements (" + (nlat+2) + "x" + nlev + ")"  
 plot2 = gsn_csm_contour(wks, uzon_new_lat, res ) 

;---Create the new level array with 1 extra element
 lev_new           = new(nlev+1,typeof(pres3d))
 lev_new(0:nlev-1) = pres3d
 lev_new(nlev)     = 150

 uzon_new_lev = new((/nlev+1,nlat+2/),typeof(uzon))
 uzon_new_lev(0:nlev-1,1:nlat) = uzon

;---Increase range of Y axis to match what we added to new lev array
 res@trYMinF         = min(lev_new)
 res@sfYArray        := lev_new     ; Assign new coordinate array

 res@tmYLMode        = "Explicit"                     ; Force labels where we want them
 res@tmYLValues      = (/150,200,400,600,800,1000/)
 res@tmYLLabels      = "" + res@tmYLValues

;---Create third plot with new level coordinates
 res@tiMainString    = "Array increased by 1 level element (" + (nlat+2) + "x" + (nlev+1) + ")"  
 plot3 = gsn_csm_contour(wks, uzon_new_lev, res ) 

;---Panel all three plots just to compare them.
 pres             = True
 pres@gsnMaximize = True
 gsn_panel(wks,(/plot1,plot2,plot3/),(/2,2/),pres)
end
