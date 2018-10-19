;======================================================
; MOPITT_MOP02T_1.ncl
;======================================================
; Concepts illustrated
;   - Reading MOPITT v6, level 2, he5 files
;   - Extracting CO tcol
;   - Using "ind" to extract day values
;   - Color-coding markers based on CO tcol
;   - Drawing a custom labelbar
;======================================================
; Script contributed by Rebecca Buchholz of NCAR.
;
; To use type on the command line:
;          > ncl MOPITT_MOP02T_1.ncl
;                            RRB Oct 14, 2014
;======================================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;--------------------------------------------
; user input
;--------------------------------------------
;infile = "/MOPITT/V6T/Archive/L2/201004/0414/MOP02T-20100414-L2V16.2.1.he5"
  infile = "./MOP02T-20100907-L2V16.2.1.he5"
  
  tcol_min = 1.0e18
  tcol_max = 2.0e18

  ;------------
  ; Select region
  ;------------
   WORLD         = True
   AUSTRALASIA   = False

  ;------------
  ; toggles
  ;------------
  PLOT           = True

  if (PLOT) then
    pltdir       = "./"
    pltname      = "MOPITT_MOP02T"
    plttype      = "png"      ; send graphics to PNG file
  end if
  
;--------------------------------------------
; end user input
;--------------------------------------------
;
;--------------------------------------------
; set up
;--------------------------------------------

   if (WORLD) then
     topboundary    = 85
     bottomboundary = -85
     rightboundary  = 180
     leftboundary   = -180
   end if

   if (AUSTRALASIA) then
     topboundary     = -5
     bottomboundary  = -50
     rightboundary   = 180
     leftboundary    = 110
   end if

;--------------------------------------------
; load file and extract
;--------------------------------------------
; names of data structures
; determined from an ncl_filedump
suff           = "_MOP02"
tracer         = "RetrievedCOTotalColumn"+suff
longitude      = "Longitude"+suff
latitude       = "Latitude"+suff
solarza        = "SolarZenithAngle"+suff

; read data
fin = addfile(infile, "r")
  tgas         = fin->$tracer$
  tcol         = tgas(:,0)
  tcol_err     = tgas(:,1)
  lon          = fin->$longitude$
  lat          = fin->$latitude$
  sza          = fin->$solarza$

printVarSummary(tcol)

;--------------------------------------------
; select daytime retrievals
;--------------------------------------------
; For SZA < 80

day_tcol = tcol(ind(sza.le.80))
day_lat  = lat(ind(sza.le.80))
day_lon  = lon(ind(sza.le.80))

;--------------------------------------------
; select spatial sub-section as per user section
;--------------------------------------------
region = ind(day_lat.le.topboundary.and.\
             day_lat.ge.bottomboundary.and.\
             day_lon.ge.leftboundary.and.\
             day_lon.le.rightboundary)

region_tcol = day_tcol(region)
region_lat  = day_lat(region)
region_lon  = day_lon(region)

;--------------------------------------------
; define tcol colour levels
;--------------------------------------------
levels = fspan(tcol_min,tcol_max,7)
nlevels = dimsizes(levels)
;print(levels)

;--------------------------------------------
; plot
;--------------------------------------------
if (PLOT) then
  wks = gsn_open_wks(plttype,pltname)        
   
  res                  = True                      ; plot mods desired
    res@gsnDraw		    = False	           ; don't draw it yet
    res@gsnFrame            = False                ; don't advance frame
    res@gsnMaximize         = True
    res@mpFillOn            = False                ; don't use gray over land
    res@gsnRightString      = infile
    res@gsnRightStringFontHeightF = 0.012

    ;res@gsnMajorLatSpacing  = 10
    ;res@gsnMajorLonSpacing  = 10

    res@mpMaxLatF           = topboundary
    res@mpMinLatF           = bottomboundary
    res@mpMaxLonF           = rightboundary
    res@mpMinLonF           = leftboundary
  
  ; draw background map
  map1=gsn_csm_map(wks, res)
  draw(map1)

  ;------------
  ; add polymarkers
  ; coloured by tcol
  ;------------
  colour_arr = (/"purple","navy","blue","seagreen","green","yellow","orange","red","red"/)
  pmres = True
     pmres@gsMarkerIndex = 16
     pmres@gsMarkerSizeF = 0.002
     markerid = new(nlevels+1,graphic)

  ; group tcol indices into colour groups
  do i=0,nlevels
    if (i.eq.0) then
      ii := ind(region_tcol.lt.levels(0))                                  ; bottom limit
    else if (i.eq.nlevels) then
      ii := ind(region_tcol.ge.levels(nlevels-1))                          ; top limit
    else
      ii := ind(region_tcol.ge.levels(i-1).and.region_tcol.lt.levels(i))   ; middle levels
    end if
    end if
    
    if (.not.any(ismissing(ii))) then
      pmres@gsMarkerColor = colour_arr(i)
      ; add polymarkers for MOPITT level 2 pixels
      markerid(i) = gsn_add_polymarker(wks,map1,region_lon(ii),region_lat(ii),pmres)
    end if
  end do
  draw(map1)

  ;------------
  ; add labelbarl
  ;------------
  lbres = True
     lbres@vpWidthF                  = 0.8
     lbres@vpHeightF                 = 0.1
     lbres@lbPerimOn                 = False
     lbres@lbOrientation             = "Horizontal"
     lbres@vpYF                      = 0.2          ; y-location of label bar
     lbres@lbLabelAlignment          = "InteriorEdges"
     lbres@lbFillColors              = colour_arr
     lbres@lbMonoFillPattern         = True
     lbres@lbLabelFontHeightF        = 0.018

     lbres@lbTitleOn                 = True
     lbres@lbTitleString             = "CO total column (molec cm^-2)"
     lbres@lbTitleFontHeightF        = 0.018
     lbres@lbTitlePosition           = "Bottom"

  labels = sprintf("%4.2e",levels)
  gsn_labelbar_ndc(wks, nlevels+1, labels, 0.1, 0.23, lbres)

  frame(wks)   ;keeps the image up when using X11

end if

end

