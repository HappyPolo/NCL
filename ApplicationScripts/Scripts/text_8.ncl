;----------------------------------------------------------------------;
; text_8.ncl
;
; Concepts illustrated:
;   - Reading data from an ASCII file
;   - Attaching text strings to a plot
;   - Drawing text on the frame using NDC coordinates
;   - Left and right justifying text
;   - Drawing superscripts/subscripts in a text string using function codes
;   - Changing the font of a text string
;   - Adding a time stamp to a plot
;----------------------------------------------------------------------;
;   Description:  Reads ascii data files containing zonal mean sulfate
;                 solar forcings and produces line plots.
;   Source:       Tim Schneider of the Climate Modeling Section
;----------------------------------------------------------------------;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

; --------------- Define some variables ------------start--------------;
  ncurve = 4
  nlat   = 64
; --------------- Open ascii data files ------------start--------------;
; Open a ascii files containing zonal means from different sources

  infile  = "solfrc_lngnr.dat"
  indata1 = asciiread(infile, 128, "float")

  infile  = "solfrc_ncar97.dat"
  indata2 = asciiread(infile, 256, "float")

  infile  = "solfrc_pham.dat"
  indata3 = asciiread(infile, 256, "float")

  infile  = "solfrc_pennr.dat"
  indata4 = asciiread(infile, 256, "float")

  infile  = "solfrc_cntrl.dat"
  indata5 = asciiread(infile, 256, "float")

  print("Data from ascii files successfully read")
                                                   ; f90 array syntax
  lngnr        = indata1(1:127:2)  - indata5(1:127:2)
  ncar97       = (indata2(1:127:2) - indata2(129:255:2))
  pham         = indata3(1:127:2)  - indata5(1:127:2)
  penr         = indata4(1:127:2)
  lat          = indata1(0:126:2)
  lat@long_name= "latitude"
  lat@units    = "degrees_north"
  lat!0        = "lat"                              ; name dimension  

; --------------- Create data arrays for plots------start--------------;
; Create a coordarrays data objects for X-Y plotting
                                                    ; store data for plotting
  y      = new((/ncurve,nlat/),float)
  y(0,:) = lngnr(:)
  y(1,:) = ncar97(:)
  y(2,:) = pham(:)
  y(3,:) = penr(:)
  y!0    = "curve"                                  ; name dimensions
  y!1    = "lat"
  y&lat  =  lat

; --------------- Compute Zonal Means - ------------start--------------;
; Use NCL function "gaus" to generate Gaussian lats and wgts  for T42 grid
; NCL function "gaus" returns a two dimensional array of double
; NCL function doubletofloat converts double-to-single precision
 
  gau_info = doubletofloat(gaus(nlat/2))  ; T42 has 64 lat (64/2=32)
  glat     = gau_info(:,0)                ; gaussian lat (1st dimension)
  gauw     = gau_info(:,1)                ; gaussian whts(2nd dimension)

  glbmean    = new ((/ncurve/), float) 
  glbmean(0) = sum( lngnr (:)*gauw(:) )*0.5
  glbmean(1) = sum( penr  (:)*gauw(:) )*0.5
  glbmean(2) = sum( ncar97(:)*gauw(:) )*0.5
  glbmean(3) = sum( pham  (:)*gauw(:) )*0.5
                             ; two decimal places/round-down for plot
  glbmean    = (floattointeger(glbmean*100. -0.5))*0.01

  delete ( gau_info)
  delete ( glat)
  delete ( gauw)
; --------------- Initialize Workstation -----------start--------------;
   wks   = gsn_open_wks ("png", "text" )  ; send graphics to PNG file
; --------------- Create the Basic Plot   -----------start-------------;
   res            = True
                                     ; alter default size
   res@vpXF       = 0.175            ; default is 0.2
   res@vpYF       = 0.85             ; default is 0.8
   res@vpWidthF   = 0.7              ; default is 0.6
   res@vpHeightF  = 0.7              ; default is 0.6

   res@trYMaxF    =  0.0             ; specify Y max
   res@trYMinF    = -3.0             ; specify Y min
   res@trXReverse = True             ; reverse X axis
 
   res@tiXAxisString   = "Latitude"    ; default is long_name (if present)
   res@tiYAxisString   = "W m~S~-2~N~" ; default is long_name (if present)
   res@tiMainString    = "Annual Mean Solar Forcing"
   res@tiMainFont      = "helvetica-bold"
   res@gsnCenterString = "Anthopogenic Sulfate Aerosols From Various Chemical Models"
   res@xyMarkLineModes   = (/"Markers","Lines","Lines"/)
   res@xyMarkers         = (/1, 0, 0, 0/)
   res@xyMarkerSizes     = (/.026,.025,.025,.025/)
   res@xyDashPatterns    = (/  0 ,   0,   1,   2/)
   res@xyLineThicknesses = (/ 0.1, 1.6, 1.6, 1.6 /)

   res@gsnDraw           = False          ; don't draw so text can be added  
   res@gsnFrame          = False   
   plot = gsn_csm_xy (wks, lat,y,res)     ; create basic plot 
;
; Add some text strings to the plot, using X,Y axis coordinate
; values to indicate the locations of the strings. The gsn_add_text
; function just attaches the text strings to the plot; it doesn't
; draw them. The text strings won't get drawn until you draw the plot.
; Each text string variable must be unique.
;
                                          ; label curves using the
                                          ; existing data space
   txid = new(9,graphic)                  ; Nine text strings

   txres               = True             
   txres@txFont        = "helvetica-bold" 
   txres@txFontHeightF = 0.01
   txid(0) = gsn_add_text (wks,plot,"Langer & Rhode", 39.5, -0.4 ,txres)
   txid(1) = gsn_add_text (wks,plot,"Penner"        , 40.5, -1.05,txres)
   txid(2) = gsn_add_text (wks,plot,"NCAR 97"       , 40.5, -1.5 ,txres)
   txid(3) = gsn_add_text (wks,plot,"Pham"          , 40.5, -1.8 ,txres)

   txres@txFont        = "duplex_roman" 
   txres@txJust        = "CenterLeft"
   txres@txFontHeightF = 0.014
   txres@txFuncCode    = "~"
   txid(4) = gsn_add_text (wks,plot,"Global Annual Means (W m~S~-2~N~)", 10.0, -2.3 ,txres)
   txid(5) = gsn_add_text (wks,plot,"Langer & Rhode   ="+glbmean(0), 10.0,-2.4,txres)
   txid(6) = gsn_add_text (wks,plot,"Penner           ="+glbmean(1), 10.0,-2.5,txres)
   txid(7) = gsn_add_text (wks,plot,"NCAR 97          ="+glbmean(2), 10.0,-2.6,txres)
   txid(8) = gsn_add_text (wks,plot,"Pham             ="+glbmean(3), 10.0,-2.7,txres)
   delete (txres)                         ; start over again
; ---------- create tiny meta data in ndc coordinates ---------------------;
; ----The following section could be replaced by the "infoTimeStamp"-------;
; --------------function which resides in "shea_util.ncl"------------------;
;  infoTimeStamp (wks, 0.010,"NCAR data source; fspj01s & fspj02 ('97)") 
; This long way is included to illustrate how to use "gsn_text_ndc"--------;

   txres               = True         ; additional info
   txres@txFontHeightF = 0.010        ; size of meta data
   txres@txJust        = "CenterRight"
   gsn_text_ndc  (wks,"NCAR data source; fspj01s & fspj02 ('97)" \
                     ,0.99 , 0.025, txres)
                                       ; note when plotted
   TimeStamp           = systemfunc( "date" )
   txres@txJust        = "CenterLeft"
   gsn_text_ndc  (wks,"Created: "+TimeStamp,0.01,0.025, txres)

   draw (plot)
   frame (wks)

end
