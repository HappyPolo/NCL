load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;******
table_color="temp_diff_18lev"
missing=-1.

;************************************************
; read in netCDF file 
;************************************************
fic_2D="RHO_2D_moyenne_03-10_1979_1992.nc"
fic_1D="RHO_obs_moyenne_interannuelle_03-10_1979_1992.txt"
; 
fic_out="density_comparison" 
;
;  2D field from model outputs 
a = addfile(fic_2D,"r")
val_2D = a->RHO_moyenne(:,:) 
val_2D@_FillValue=missing
;printVarSummary(val_2D)

;************************************************
; polymarkers from observations at local stations 
;************************************************
;
; 

data = readAsciiTable(fic_1D,3,"float",0)
n    = dimsizes(data)

;************************************************
; Plot 2D field (color fills) 
;************************************************
wks = gsn_open_wks("pdf",fic_out)
;wks = gsn_open_wks("x11","polyg")     ; Open a workstation
gsn_define_colormap(wks, table_color) ; 18 colors

res = True 
res@gsnMaximize          = True
res@cnFillOn             = True               ; turns on the color
res@mpFillOn             = True              
res@cnLinesOn            = False             ; turn off contour lines

; labelbar resources
 res@pmLabelBarWidthF         = 0.60
 res@txFontHeightF            = 0.012
 res@lbTitleFontHeightF       = 0.012
 res@lbLabelFontHeightF       = 0.008
 res@lbTitleString            = "Snowpack density (kg/m3)"
 res@lbTitleOffsetF           = -0.27
 res@lbBoxMinorExtentF        = 0.25
 res@pmLabelBarOrthogonalPosF = 0.12


res@gsnSpreadColors      = True                  ; use full range of colors
res@gsnRightString       = "" ; pour ne pas afficher l'unité en haut
res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res@cnMaxLevelValF       = 350.         ; set max contour level
res@cnMinLevelValF       = 150.           ; set min contour level
res@cnLevelSpacingF      = 25.   ; set contour spacing 
res@lbLabelAutoStride    = True                 ; optimal labels
res@gsnDraw              = False 
res@gsnFrame             = False 
res@cnFillMode           = "RasterFill"  ; indispensable pour mettre 
                                         ; missing values a couleur prescrite
res@mpMinLatF                   = 36                 ; specify min lat
res@mpMaxLatF                   = 72
res@mpMinLonF                   = 31 
res@mpMaxLonF                   = 179
res@gsnAddCyclic                = False                 
res@cnFillDrawOrder             = "Predraw"     
res@mpFillBoundarySets          = "NoBoundaries"
res@mpFillAreaSpecifiers        = "water"       
res@mpSpecifiedFillColors       = "blue"
;res@mpOutlineOn                = True
;res@mpOutlineSpecifiers        = "USSR"        
res@mpAreaMaskingOn             = 1     
res@mpMaskAreaSpecifiers        = "land"
res@cnMissingValFillColor       = "grey"


 plot=gsn_csm_contour_map(wks,val_2D(:,:),res)
 getvalues plot@contour                  ; get information on labelbars 
                                         ; colors and values for polymarkers 
    "cnLevels"               : cn_levels
    "cnFillColors"           : cn_colors
    "cnInfoLabelFontHeightF" : font_height
  end getvalues


  labels = new(dimsizes(cn_levels)+1,string)    ; Labels for legend.
  tic_histo = new(dimsizes(cn_levels)+1,string) ; Labels for histogram gnuplot 

;*******************************
;affecte les couleurs des marquers apres lecteure des donnees
;********************************
        ;---------------------------
        npts    = n(0)                  ; Number of points.
        lat             = data(:,1)
        lon             = data(:,0)
        R               = data(:,2)
        num_distinct_markers = dimsizes(cn_levels) +1        ; number of distinct markers 
        lat_new = new((/num_distinct_markers,dimsizes(R)/),float,-999)
        lon_new = new((/num_distinct_markers,dimsizes(R)/),float,-999)

   
        do i = 0, num_distinct_markers-1
                if (i.eq.0) then
                        indexes         = ind(R.lt.cn_levels(0))
                        labels(i)       = "x < " + cn_levels(0)
                        tic_histo(i)    = "<" + cn_levels(0)
                end if
                if (i.eq.num_distinct_markers-1) then
                        indexes         = ind(R.ge.max(cn_levels))
                        labels(i)       = "x >= " + max(cn_levels)
                        tic_histo(i)    = ">=" + max(cn_levels)
                end if
                if (i.gt.0.and.i.lt.num_distinct_markers-1) then       
                        indexes         = ind(R.ge.cn_levels(i-1).and.R.lt.cn_levels(i))
                        labels(i)       = cn_levels(i-1) + " <= x < " + cn_levels(i)
                        tic_histo(i)    = "["+cn_levels(i-1)+"," + cn_levels(i)+"]"
                end if
                
                if (.not.any(ismissing(indexes))) then 
                npts_range = dimsizes(indexes)          ; 
                lat_new(i,0:npts_range-1)       = lat(indexes)
                lon_new(i,0:npts_range-1)       = lon(indexes)
                print("Number of points in range: " + tic_histo(i) + \
                      " = " + npts_range)
              else
                print("Number of points in range: " + tic_histo(i)+" = 0")
                
                end if
                delete(indexes)         
        end do

;
;*************************************************
; POLYMARKERS
;************************************************

;
; Set up some map resources.
;
  mpres              = True
  mpres@gsnFrame     = False            ; Don't advance the frame
  mpres@gsnDraw     = False            ; 
;
;
  mpres@mpMinLatF    = res@mpMinLatF
  mpres@mpMaxLatF    = res@mpMaxLatF 
  mpres@mpMinLonF    = res@mpMinLonF  
  mpres@mpMaxLonF    = res@mpMaxLonF 

  mpres@mpFillOn       = False

  gsres                = True
  gsres@gsMarkerIndex  = 16          ; Use filled dots for markers.
  gsres@gsMarkerSizeF  = 0.008

  ggsres               = True
  ggsres@gsMarkerIndex = 4          ; Use hollow circles
  ggsres@gsMarkerSizeF = 0.009

  bid=True
  do i = 0, num_distinct_markers-1
    if (.not.ismissing(lat_new(i,0)))
      gsres@gsMarkerColor     = cn_colors(i)
      bid@$unique_string("")$ = gsn_add_polymarker(wks,plot,lon_new(i,:),lat_new(i,:),gsres)
      bid@$unique_string("")$ = gsn_add_polymarker(wks,plot,lon_new(i,:),lat_new(i,:),ggsres)
    end if
    
    xleg= 0.05 + mod(i,3)/3.
    yleg= 0.25+0.025*(i/3) 
    xtxt = xleg + 0.15
    ytxt = yleg
    ; decommenter ci-dessous pour tracer les plages des polymarkers
    gsres@gsMarkerColor      = cn_colors(i)
    txres               = True
    txres@txFontHeightF = 0.015
    gsn_polymarker_ndc(wks,          xleg,yleg,gsres)
    gsn_polymarker_ndc(wks,          xleg,yleg,ggsres)
    gsn_text_ndc      (wks,labels(i),xtxt,ytxt,txres)
                                ;
  end do


   pres                  = True
   pres@gsnMaximize      = True              ; Maximize paneled plots
   pres@gsnPanelLabelBar = True              ; Turn on panel labelbar
   pres@txString = "Contour levels 'fixed' for all plots"

;  gsn_panel(wks,plots,(/2,1/),pres)     ; Draw 2 rows x 2 columns

draw(plot)
frame(wks)    ; Advance the frame.

end     

