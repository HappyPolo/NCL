;**********************************************************************
; poly_16.ncl
;
; Concepts illustrated:
;   - Drawing colored polymarkers at station locations                
;   - Adding a legend                                                 
;**********************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  latN = 46.0
  latS = 24.0
  lonL  = -113.
  lonR  = -87.

  lat  = (/37.953,37.383,37.133,36.841,36.605,36.431,35.557,35.564/)
  lon  = (/-98.329,-96.18,-97.266,-96.427,-97.485,-98.284,-98.017,-96.988/)

  wks = gsn_open_wks("png","polyg")         ; send graphics to PNG file

  res                             = True
  res@gsnFrame                    = False   ; So we can draw markers
  res@gsnMaximize                 = True    ; affects ps, eps, pdf only
  res@gsnPaperOrientation         = "portrait"  ; force portrait

  res@tiMainString                = "Color Station Locations and Legend"

  res@mpMinLatF                   = latS     ; range to zoom in on
  res@mpMaxLatF                   = latN
  res@mpMinLonF                   = lonL
  res@mpMaxLonF                   = lonR
  res@mpCenterLonF                = (lonL+lonR)*0.5

  res@mpFillOn                    = False
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpFillDrawOrder             = "PreDraw"
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpUSStateLineColor          = "Gray10"
  res@mpUSStateLineDashPattern    = 2

  res@pmTickMarkDisplayMode       = "Always"
;
; Draw the map (frame won't get advanced because gsnFrame was set to False).
;
  map = gsn_csm_map(wks,res)
;
; Draw markers on the plot in the lat/lon locations.
;
  colors = (/"black","RoyalBlue","Yellow",\
             "Pink","lightseagreen","PaleGreen","Wheat","Brown"/)
  labels = (/"E4 Plevna,KS","E7 Elk Falls,KS","E9 Ashton,KS"    \
            ,"E12 Pawhuska,OK","E13 Lamont,OK","E15 Ringwood,OK"\
            ,"E19 El Reno,OK","E20 Meeker,OK"                   /)

; Manually specify location of legends
        
  xleg = (/0.15,0.15,0.35,0.35,0.56,0.56,0.80,0.80/)   ; Location of
  xtxt = (/0.22,0.225,0.42,0.44,0.65,0.66,0.88,0.88/)  ; legend markers
  yleg = (/0.26,0.20,0.26,0.20,0.26,0.20,0.26,0.20/)   ; and text
  ytxt = (/0.26,0.20,0.26,0.20,0.26,0.20,0.26,0.20/)   ; strings.

  mkres               = True
  mkres@gsMarkerIndex = 16     ; Filled circle
  mkres@gsMarkerSizeF = 0.03

  txres               = True
  txres@txFontHeightF = 0.013

; add location and text for each station

  do i = 0,7
     mkres@gsMarkerColor = colors(i)
     gsn_polymarker(wks,map,lon(i),lat(i),mkres)
     gsn_polymarker_ndc(wks,xleg(i),yleg(i),mkres)
     gsn_text_ndc      (wks,labels(i),xtxt(i),ytxt(i),txres)
  end do

  frame(wks)
end
