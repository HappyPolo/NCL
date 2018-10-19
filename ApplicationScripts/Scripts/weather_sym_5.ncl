;*************************************************
; weather_sym_5.ncl
;
; Concepts illustrated:
;   - Using named colors
;   - Drawing wind barbs
;   - Setting fill colors
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;
;  The procedure tricolour produces a French flag using the
;  official colors and aspect ratio.  The lower left corner
;  of the flag is at coordinate (xll,yll) in NDC.
;
procedure tricolour(wks,xll,yll,height)
begin

  width = 1.5*height
  xx = new(5,float)
  yy = new(5,float)
;
;  Draw blue bar.
;
  xx = (/xll, xll + width/3., xll + width/3., xll, xll/)
  yy = (/yll, yll, yll+height, yll+height, yll/)
  pres = True
  pres@gsFillColor = "blue"
  gsn_polygon_ndc(wks,xx,yy,pres)
;
;  Draw white bar.
;
  xx = (/xll+width/3., xll + 2.*width/3., xll + 2.*width/3., \
           xll+width/3., xll+width/3./)
  pres@gsFillColor = "white"
  gsn_polygon_ndc(wks,xx,yy,pres)
;
;  Draw red bar.
;
  xx = (/xll+2.*width/3., xll + width, xll + width,  \
           xll+2.*width/3., xll+2.*width/3./)
  pres@gsFillColor = "red"
  gsn_polygon_ndc(wks,xx,yy,pres)
  xx = (/xll, xll + width, xll + width, xll, xll/)
;
;  Perimeter.
;
  pres@gsLineColor = 1
  gsn_polyline_ndc(wks,xx,yy,pres)
end

begin

;
;  Show how to put four plots, illustrating wind barb procedures,
;  on a single frame.
;
  wks = gsn_open_wks("png","weather_sym")  ; send graphics to PNG file
  cmap = (/(/1.,1.,1./),(/0.,0.,0./),(/1.,0.,0./) /)  ; color map
  gsn_define_colormap(wks,cmap)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                           ;
;  Lower left quadrant.     ;
;                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Use the procedure wmbarb to produce a table of the association
;  of wind barb symbols with wind speeds.  This plot simply uses
;  NDC coordinates - the three other plots show how to plot
;  wind barbs over maps and position those plots on the frame.
;
  width  = 0.42
  height = 0.42
  xl = 0.06
  xr = xl + width
  yt = 0.46
  yb = yt - height
  midx = 0.5*(xl+xr)
;
;  Perimeter
;
  gsn_polyline_ndc(wks,(/xl,xr,xr,xl,xl/),(/yb,yb,yt,yt,yb/),False)
;
;  Title
;
  txres = True
  txres@txFont = "Helvetica-Bold"
  txres@txFontHeightF = 0.042*height
  gsn_text_ndc(wks,"Wind Speeds",midx,yt+1.3*txres@txFontHeightF,txres)
;
;  Dividing lines.
;
  hline_y = yt-0.08*height
  gsn_polyline_ndc(wks,(/xl,xr/),(/hline_y, hline_y/),False)
  gsn_polyline_ndc(wks,(/midx,midx/),(/yb, yt/),False)
;
;  Row labels.
;
  txres@txFont = "Helvetica"
  txres@txFontHeightF = 0.0315*height
  gsn_text_ndc(wks,"Symbol  Knots  Miles/hr.",  \
                 0.5*(xl+midx),yt-0.04*height,txres)
  gsn_text_ndc(wks,"Symbol  Knots  Miles/hr.",  \
                 midx + 0.5*(xr-midx),yt-0.04*height,txres)
;
;  Increase the size of the barbs.
;
  wmsetp("wbs", .035)
;
;  Left column of table.
;
  speeds_u = (/ 0., -1.5, -4., -9., -14., -19., -24., -29., -34./)
  labels_k = (/"Calm","1-2","3-7","8-12","13-17","18-22",  \
               "23-27","28-32","33-37"/)
  labels_m = (/"Calm","1-2","3-8","9-14","15-20","21-25",  \
               "26-31","32-37","38-43"/)
  y_start = hline_y+0.04*height
  do i = 1,9
    xp = xl+0.25*(midx-xl)
    yp = y_start - 0.042*i
    wmbarb(wks, xp, yp, speeds_u(i-1), 0.)  ; Plot barbs.
    gsn_text_ndc(wks,labels_k(i-1),xp+0.21*(midx-xl),yp,txres) 
    gsn_text_ndc(wks,labels_m(i-1),xp+0.55*(midx-xl),yp,txres) 
  end do
;
;  Right column of table.
;
  speeds_u = (/ -39., -44., -49., -54., -59., -64., -69., -74., -104./)
  labels_k = (/"38-42","43-47","48-52","53-57","58-62",  \
               "63-67","68-72","73-77","103-107"/)
  labels_m = (/"44-49","50-54","55-60","61-66","67-71",  \
               "72-77","78-83","84-89","119-123"/)
  y_start = hline_y+0.04*height
  do i = 1,9
    xp = midx+0.25*(xr-midx)
    yp = y_start - 0.042*i
    wmbarb(wks, xp, yp, speeds_u(i-1), 0.)  ; Plot barbs.
    gsn_text_ndc(wks,labels_k(i-1),xp+0.21*(midx-xl),yp,txres) 
    gsn_text_ndc(wks,labels_m(i-1),xp+0.55*(midx-xl),yp,txres) 
  end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                           ;
;  Upper left quadrant.     ;
;                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Draw an orthographic map centered at lat/lon = (70.,-10.).
;  Don't advance the frame, since we want to add wind barbs.
;
  mpres              = True
;
; Define size of map in frame.
;
  mpres@mpShapeMode = "FreeAspect"
  mpres@vpXF        = 0.06
  mpres@vpYF        = 0.94
  mpres@vpWidthF    = 0.42
  mpres@vpHeightF   = 0.42

  mpres@gsnFrame     = False
  mpres@mpFillAreaSpecifiers  = (/"Water","Land"/)
  mpres@mpSpecifiedFillColors = (/"cyan","gray"/)

  mpres@mpLimitMode  = "LatLon"
  mpres@mpMinLonF    = -40.
  mpres@mpMaxLonF    =  20.
  mpres@mpMinLatF    =  55.
  mpres@mpMaxLatF    =  85.
  mpres@mpCenterLatF =  70.
  mpres@mpCenterLonF = -10.
  mpres@mpPerimOn    = True
  mpres@tiMainString = "Winds from the south"
  mpres@tiMainFont   = "Helvetica-Bold"

  mpres@mpFillOn = True
  map = gsn_map(wks,"Orthographic",mpres)

;
;  Draw an array of vertical wind barbs over the above map.
;
  lat = new((/3,2,5/),float)
  lon = new((/3,2,5/),float)
  u   = new((/3,2,5/),float)
  v   = new((/3,2,5/),float)

  lat(0,:,:) = 65
  lat(1,:,:) = 70
  lat(2,:,:) = 75

  lon0 = -40.+ispan(0,4,1)*5.
  lon1 = -15.+ispan(0,4,1)*5.
  lon(:,0,:) = conform(lon(:,0,:),lon0,1)
  lon(:,1,:) = conform(lon(:,1,:),lon1,1)

  u =  0.
  v = 90.

  wmsetp("col", 2)     ; Draw in red.
  wmsetp("wbs", .035)  ; Increase the size of the barb.
  wmbarbmap(wks, lat, lon,  u, v)  ; Plot barbs.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                           ;
;  Upper right quadrant.    ;
;                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Plot some station model data for some cities in 
;  Kansas and Oklahoma.
;
; Change location of map in frame. Size is the same as before.
;
  mpres@vpXF         =   0.53
  mpres@vpYF         =   0.94
  mpres@mpLimitMode  = "LatLon"
  mpres@mpMinLonF    = -103.0
  mpres@mpMaxLonF    =  -94.0
  mpres@mpMinLatF    =   32.5
  mpres@mpMaxLatF    =   41.5
  mpres@mpCenterLatF =   35.0
  mpres@mpCenterLonF =  -97.0
  mpres@mpPerimOn    = True
  mpres@mpOutlineBoundarySets   = "USStates"
  mpres@mpUSStateLineThicknessF = 1.25

  mpres@tiMainString = "Kansas and Oklahoma stations"
  mpres@tiMainFont   = "Helvetica-Bold"
  mpres@mpFillOn = False
  map = gsn_map(wks,"Satellite",mpres)
;
;  Flag the station model procedure that the wind barbs are
;  being drawn over a map.
;
  wmsetp("ezf",1)
;
;  Draw in the foreground color.
;
  wmsetp("col", 1)
;
;  Plot station model data at selected cities.
;
;  City      Lat    Lon     Station model data.
;  --------  ----- -------  ----------------------------------------------------
;  Kan City, 39.10, -94.67, "11721700181008020050300004983052026604007289086925"
;  Tulsa   , 36.13, -95.94, "11060032571033020380300004033056030610507808089258"
;  Ok City , 35.48, -97.53, "11854813511029020330300004025054016609507726087036"
;  Wichita , 37.69, -97.34, "11000022751126021360300004955054054600007757087712"
;  Woodward, 36.43, -99.40, "11515500121004020000300004975050034603017207084703"
;  Goodland, 39.35,-101.71, "11751718481027020310300004021053012609017685086925"
;  Hays    , 38.88, -99.32, "11206227031102021040300004963056046601517084081470"
;
  lats = (/  39.10,  36.13,  35.48,  37.69,  36.43,   39.35,  38.88/)
  lons = (/ -94.67, -95.94, -97.53, -97.34, -99.40, -101.71, -99.32/)
  imdat= (/ "11721700181008020050300004983052026604007289086925",  \
            "11060032571033020380300004033056030610507808089258",  \
            "11854813511029020330300004025054016609507726087036",  \
            "11000022751126021360300004955054054600007757087712",  \
            "11515500121004020000300004975050034603017207084703",  \
            "11751718481027020310300004021053012609017685086925",  \
            "11206227031102021040300004963056046601517084081470" /)
  wmstnm(wks,lats,lons,imdat)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                           ;
;  Lower right quadrant.    ;
;                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Draw some wind barbs at cities in France.  Color the
;  country with the blue color from the Franch flag and
;  the wind barbs with the red color from the French flag.
;
;  Change location of map in frame. Size is the same.
;
  mpres@vpXF         = 0.53
  mpres@vpYF         = 0.46
  mpres@mpLimitMode  = "LatLon"
  mpres@mpMinLonF    = -4.25
  mpres@mpMaxLonF    =  8.25
  mpres@mpMinLatF    =  39.5
  mpres@mpMaxLatF    =  52.0
  mpres@mpCenterLatF =  49.
  mpres@mpCenterLonF =  2.
  mpres@mpPerimOn    = True
  mpres@mpFillOn     = True

  mpres@mpOutlineBoundarySets  = "NoBoundaries"
  mpres@mpDataBaseVersion      = "MediumRes"
  mpres@tiMainString           = "Winds Of France"
  mpres@tiMainFont             = "Helvetica-Bold"
  mpres@mpAreaMaskingOn        = True                 
  mpres@mpFillBoundarySets     = "NoBoundaries"
  mpres@mpGridAndLimbOn        = False
  mpres@mpAreaMaskingOn        = 1
;
;  Mask countries bordering France.
;
  mpres@mpMaskAreaSpecifiers   = (/"Water","Ocean","Scotland","Netherlands", \
                                   "Belgium","Luxembourg","Italy","Corsica", \
                                   "United Kingdom","Germany","Spain",       \
                                   "Switzerland"/)
;
;  Delete mpres@mpFillAreaSpecifiers before re-defining it.
;
  delete(mpres@mpFillAreaSpecifiers)
  red_index  = NhlNewColor(wks,1.0,0.10,0.14)
  mpres@mpFillAreaSpecifiers = (/"Land"/)
  delete(mpres@mpSpecifiedFillColors)
  mpres@mpSpecifiedFillColors = (/"navyblue"/)
  map = gsn_map(wks,"Satellite",mpres)

  wmsetp("wbs", .04)       ; Increase the size of the barb.
  wmsetp("col", red_index) ; Color in red.  Must use old color model.

;
;  Plot wind barbs at various French cities.
;
;
;  Paris
  wmbarbmap(wks, 48.87, 2.33, -10., 2.)  ; Plot barbs.
;  LeHavre
  wmbarbmap(wks, 49.50, 0.12, -5., 0.)  ; Plot barbs.
;  Renne
  wmbarbmap(wks, 48.10, 1.67, -30., 6.)  ; Plot barbs.
;  Tour
  wmbarbmap(wks, 47.30, 0.68, -20., 4.)  ; Plot barbs.
;  Dijon
  wmbarbmap(wks, 47.30, 5.03, -15., 5.)  ; Plot barbs.
;  Clarmont-Ferrand
  wmbarbmap(wks, 45.76, 3.10, -15., 13.)  ; Plot barbs.
;  Bordeaux
  wmbarbmap(wks, 44.83, -0.57, -20., 25.)  ; Plot barbs.
;  Toulouse
  wmbarbmap(wks, 43.60, 1.45, -5., 10.)  ; Plot barbs.
;  Lyon
  wmbarbmap(wks, 45.75, 4.85, -10., 15.)  ; Plot barbs.
;  Nice
  wmbarbmap(wks, 43.70, 7.28, -5., 20.)  ; Plot barbs.
;  Nancy
  wmbarbmap(wks, 48.70, 6.15, -20., 10.)  ; Plot barbs.
;  Limoges
  wmbarbmap(wks, 45.83, 1.26, -30., 40.)  ; Plot barbs.
;  Nantes
  wmbarbmap(wks, 47.20, -1.55, -15., 5.)  ; Plot barbs.
;  Lille
  wmbarbmap(wks, 50.60, 3.10, -10., 1.)  ; Plot barbs.
;  Morlaix
  wmbarbmap(wks, 48.58,-3.83, -10., 0.)  ; Plot barbs.
;  Reims
  wmbarbmap(wks, 49.30, 4.03, -40., 8.)  ; Plot barbs.
;  La Rochelle
  wmbarbmap(wks, 46.10,-1.0, -30., 30.)  ; Plot barbs.
;  Redon
  wmbarbmap(wks, 47.67,-2.30, -30., 0.)  ; Plot barbs.
;
;  Add a French flag.
;
  tricolour(wks, 0.84, 0.07, 0.05)

;
;  Advance frame.
;
  frame(wks)
end

