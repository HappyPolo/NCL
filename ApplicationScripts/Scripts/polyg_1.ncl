;
; polyg_1.ncl
;
; Concepts illustrated:
;   - Drawing a Lambert Conformal U.S. map color-coded by climate divisions
;   - Drawing the climate divisions of the U.S.
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Drawing filled polygons on a map
;   - Drawing a border around filled polygons
;   - Masking the ocean in a map plot
;   - Masking land in a map plot
;   - Increasing the font size of text
;   - Adding text to a plot
;
;**************************************************
; written by Mark Stevens 07/07/00
; plot polygons defined by climate divisions
; Climate division 7 in Florida (Key West) has been deleted so
; there are 343 climate divisions plotted using 344 polygons since
; climate division 1 in VA is split in two by Chesapeake Bay.
;*************************************************
; Note: this example was written before climate divisions
; were built into NCL. To use the built-in climate divisions,
; set the following resources:
;
;  res@mpDataSetName         = "Earth..3"
;  res@mpDataBaseVersion     = "MediumRes"
;  res@mpOutlineBoundarySets = "AllBoundaries"
;
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
begin
;************************************************
; get pointer to netcdf file with polygons
;************************************************
 fname = "climdiv_polygons.nc"
 ncdf = addfile(fname,"r")
;************************************************
; some parameters
;************************************************
  statenames = new((/48/),"string")
  statenames = (/"AL","AR","AZ","CA","CO","CT","DE","FL","GA","IA","ID","IL", \
               "IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT", \
               "NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA", \
               "RI","SC","SD","TN","TX","UT","VA","VT","WA","WI","WV","WY"/) 

; climate divisions in each state                   
  ncds = new((/48/),"integer")
  ncds = (/8,9,7,7,5,3,2,6,9,9,10,9,9,9,4,9,3,8,3,10,9,6,10,7, \
         8,9,8,2,3,8,4,10,10,9,9,10,1,7,9,4,10,7,7,3,10,9,6,10/)
         
  npoly = sum(ncds)   ; number of polygons to draw
;************************************************
; create the plot
;************************************************
 wks = gsn_open_wks ("png","polyg")     ; send graphics to PNG file
 
 gsn_define_colormap(wks,"default")     ; set color map

 res=True
      
; map resources for projection
 res@mpLambertParallel1F = 33.0         ; two parallels
 res@mpLambertParallel2F = 45.0
 res@mpLambertMeridianF  = -95.0        ; central meridian

 res@mpLimitMode         = "LatLon"     ; limit map via lat/lon
 res@mpMinLatF           = 24.0         ; map area
 res@mpMaxLatF           = 50.0         ; latitudes
 res@mpMinLonF           = -125.0       ; and
 res@mpMaxLonF           = -65.0        ; longitudes
 
; map resources
 res@mpDataBaseVersion   = "MediumRes"  ; change database
 res@mpFillOn            = True         ; fill continents
 res@mpPerimOn           = False        ; no box around map

 res@mpAreaMaskingOn        = True                 ; draw only parts of map 
 res@mpFillAreaSpecifiers   = (/"Water","Land"/)   ; what parts to fill
 res@mpSpecifiedFillColors  = (/0,0/)              ; fill with background color
 res@mpOutlineBoundarySets  = "USStates"           ; what outlines to use
 res@mpMaskAreaSpecifiers   = (/"Conterminous US"/); don't fill here
 res@mpGridAndLimbOn        = False                ; no lat/lon lines
   
; increase viewport size (make map bigger)
 res@vpWidthF  = 0.93
 res@vpHeightF = 0.93
 res@vpXF      = 0.05
 res@vpYF      = 0.99   
      
 res@gsnDraw  = False       ; don't draw the plots now
 res@gsnFrame = False       ; or advance the frame

 plot = gsn_map(wks,"LambertConformal",res) ; create the plot   
 
; polygon resources
  res_poly             = True
  res_poly@gsEdgesOn   = True       ; draw border around polygons
  res_poly@gsEdgeColor = "black"    

;**************************************************
; prepare to draw polygons
;**************************************************
  srand (12345)                ; set the seed for the random number generator
;*********************************************
; get the polygon data and fill polygons with 
; random colors using the default color table
;*********************************************
  do st = 1, 48
    do cd = 1, ncds(st-1)
      rand_num = (rand()/1129) + 2           ; random color value (2-31)
      if (st .eq. 43 .and. cd .eq. 1) then   ; save value
        va1_rn = rand_num                    ; VA clim div 1
      end if                                
      if (st .eq. 43 .and. cd .eq. 7) then   ; use value for
        res_poly@gsFillColor = va1_rn        ; VA clim div 1
      else        
        res_poly@gsFillColor = rand_num 
      end if
      varstr = statenames(st-1)+"_CD"+cd
      x = ncdf->$varstr$@lon                 ; lon stored in attribute
      y = ncdf->$varstr$@lat                 ; lat stored in attribute
      gsn_polygon (wks,plot,x,y,res_poly)
      delete(varstr)
      delete(x)
      delete(y)
    end do
  end do
;********************************************
; Add a title to the plot in NDC Coordinates
;********************************************
 res_txt               = True                ; text resources
 res_txt@txFontHeightF = 0.016               ; select font size 
 gsn_text_ndc (wks,"Climate Division Polygons",0.5,0.78,res_txt) ; add text
 frame(wks)    
end
