;
; polyg_2.ncl
;
; Concepts illustrated:
;   - Drawing a Lambert Conformal U.S. map color-coded by climate divisions
;   - Color-coding climate divisions based on precipitation values
;   - Drawing the climate divisions of the U.S.
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Drawing filled polygons on a map
;   - Drawing a border around filled polygons
;   - Masking the ocean in a map plot
;   - Masking land in a map plot
;   - Increasing the font size of text
;   - Adding text to a plot
;   - Drawing a custom labelbar on a map
;   - Creating a red-yellow-blue color map 
;
; plot annual average precipitation from the
; climate division dataset using polygons.
;
; Note: this example was written before climate divisions
; were built into NCL. To use the built-in climate divisions,
; set the following resources:
;
;  res@mpDataSetName         = "Earth..3"
;  res@mpDataBaseVersion     = "MediumRes"
;  res@mpOutlineBoundarySets = "AllBoundaries"
;
;****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***************************************************
begin
;***************************************************
  nyrs = 101                                           ; 1899-1999
  
; state names
  statenames = new((/48/),"string")
  statenames = (/"AL","AR","AZ","CA","CO","CT","DE","FL","GA","IA","ID","IL", \
  "IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT", \
  "NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA", \
  "RI","SC","SD","TN","TX","UT","VA","VT","WA","WI","WV","WY"/)
  
; climate divisions in each state 
; FL climate division 7 has been deleted, VA climate division 7 has been 
; added as the second part of VA climate division 1    
  ncds = new((/48/),"integer")
  ncds = (/8,9,7,7,5,3,2,6,9,9,10,9,9,9,4,9,3,8,3,10,9,6,10,7, \
  8,9,8,2,3,8,4,10,10,9,9,10,1,7,9,4,10,7,7,3,10,9,6,10/)
  
; get pointer to netcdf file  
  datafile = "climdiv_prcp_1899-1999.nc"
  ncdf = addfile (datafile,"r")
  
;-------------------------- plot stuff ---------------------------
  
  wks = gsn_open_wks ("png","polyg")     ; send graphics to PNG file
  
; resources for the plot 
  res=True
  
; map resources for projection
  res@mpLambertParallel1F = 33.0         ; two parallels
  res@mpLambertParallel2F = 45.0
  res@mpLambertMeridianF  = -95.0        ; central meridian
  res@mpLimitMode         = "LatLon"
  res@mpMinLatF           = 24.0         ; map area
  res@mpMaxLatF           = 50.0         ; latitudes
  res@mpMinLonF           = -125.0       ; and
  res@mpMaxLonF           = -65.0        ; longitudes
  
  
; map resources
  res@mpDataBaseVersion     = "MediumRes"
  res@mpFillOn              = True
  res@mpPerimOn             = False
  res@mpAreaMaskingOn       = True  
  res@mpFillAreaSpecifiers  =(/"Water","Land"/) 
  res@mpSpecifiedFillColors = (/0,0/) 
  res@mpOutlineBoundarySets = "USStates"
  res@mpMaskAreaSpecifiers  =(/"Conterminous US"/)
  res@mpGridAndLimbOn       = False
  
; polygon resources
  res_poly             = True
  res_poly@gsEdgesOn   = True       ; draw border around polygons
  res_poly@gsEdgeColor = "black"   
  res_poly@tfPolyDrawOrder = "PostDraw"
  
; increase viewport size
  res@vpWidthF  = 0.9
  res@vpHeightF = 0.9
  res@vpXF      = 0.05
  res@vpYF      = 0.90
  
  res@gsnDraw  = False        ; don't draw the plots now
  res@gsnFrame = False       ; or advance the frame
  
  res@tfPolyDrawOrder = "PostDraw"

; define colormap  
  gsn_define_colormap (wks,"amwg")
  cmap = gsn_retrieve_colormap(wks)
  
  plot = gsn_map (wks,"LambertConformal",res)      
;-------------------------------------------------------------------
; plot color coded climate division annual mean total precipitation 
; for each of the polygons
;------------------------------------------------------------------- 
; contour levels
  cnLevels = (/5,10,15,20,25,30,35,40,50,60,70,80,90/)  ; inches 
  
  do st = 1, 48
    do cd = 1, ncds(st-1)
      varstr = "PRECT_"+statenames(st-1)+"_CD"+cd 
      precip = ncdf->$varstr$
      x = ncdf->$varstr$@lon                 ; lon stored as attribute
      y = ncdf->$varstr$@lat                 ; lat stored as attribute 
      
; compute annual total
      annual = new (nyrs,typeof(precip))
      m = 0
      do yr = 0, nyrs-1
        annual(yr) = sum (precip(m:m+11))
        m = m + 12
      end do
      
; compute climatological annual mean
      clim_mean = avg (annual)  
      
; get correct color to fill polygon
      res_poly@gsFillColor = GetFillColor(cnLevels,cmap,clim_mean)    
      gsn_polygon (wks,plot,x,y,res_poly)
      gsn_polyline (wks,plot,x,y,res_poly)   ; necessary to fix bug where
                                             ; outlines don't all get drawn.
      delete(x)
      delete(y)
    end do
  end do
  
; label bar resources 
  res_lb                    = True
  res_lb@vpWidthF           = 0.50             ; location
  res_lb@vpHeightF          = 0.05             ; " " 
  res_lb@lbPerimOn          = False            ; Turn off perimeter.
  res_lb@lbOrientation      = "Horizontal"     ; Default is vertical.
  res_lb@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
  res_lb@lbFillColors       = cmap(2:,:)       ; Colors for boxes.
  res_lb@lbMonoFillPattern  = True             ; Fill them all solid.
  res_lb@lbLabelFontHeightF = 0.012            ; label font height
  res_lb@lbTitleString      = "inches"         ; title
  res_lb@lbTitlePosition    = "Bottom"         ; location of title
  res_lb@lbTitleFontHeightF = 0.01             ; title font height
  gsn_labelbar_ndc (wks,dimsizes(cnLevels)+1,""+cnLevels,0.23,0.20,res_lb)  
  
; text resources
  res_txt               = True
  
  res_txt@txFontHeightF = 0.014
  gsn_text_ndc (wks,"Average Annual Precipitation",0.5,0.745,res_txt)       
  res_txt@txFontHeightF = 0.013
  gsn_text_ndc (wks,"Computed for the period 1899-1999",0.5,0.72,res_txt)
  res_txt@txFontHeightF = 0.013   
  gsn_text_ndc (wks,"NCDC climate division data",0.5,0.70,res_txt) 
  
  
  frame(wks) 
end
