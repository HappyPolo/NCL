;**************************************************************
; radar_4.ncl
;
; Concepts illustrated:
;   - Drawing a radial background plot
;   - Plotting radar (r,theta) data
;   - Adding special labels to a radar plot
;**************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;----------------------------------------------------------------------
; This NCL script was contributed by:
;
;  Chris Fletcher
;  Assistant Professor & SHARCNET Research Chair
;  Geography & Environmental Management, University of Waterloo
;
; M. Haley added some extra notes for the NCL applications page.
;----------------------------------------------------------------------
;
; taking Mary Haley's polar XY example and modifying it for my 
; phase/amplitude data MODS REQD: 1. convert amplitude (radius) to 
; latitude (simple scaling should work --> 0 = 0N, max_rad ~ 90N)
;  2. tick marks (insert latitude ticks and override name with radius val)
;
; (this part borrowed from: http://www.ncl.ucar.edu/Applications/Scripts/lcmask_4.ncl)
;----------------------------------------------------------------------
; This procedure attaches lat/lon labels to a masked lambert plot
;
; You will likely need to change lat_values and/or lon_values to
; contain the locations where you want lat/lon labels.
;----------------------------------------------------------------------
procedure add_lc_labels(wks,map,minlat,maxlat,minlon,maxlon,ytickvals,yticknames)
local lat_values, nlat, lat1_ndc, lat2_ndc, lon1_ndc, lon2_ndc,slope,txres, \
lon_values, PI, RAD_TO_DEG, dum_lft, dum_rgt, dum_bot
begin
;---Pick some "nice" values for the latitude labels.
  lat_values = ytickvals
  nlat       = dimsizes(lat_values)

;---Set some text resources
  txres               = True
  txres@txFontHeightF = 0.0125
  txres@txPosXF       = 0.1
;
; Loop through lat values, and attach labels to the left and
; right edges of the masked LC plot.  The labels will be 
; rotated to fit the line better.
;
  dum_lft = new(nlat,graphic)    ; Dummy array to hold attached strings.
  do n=0,nlat-1
; Add extra white space to labels.
    lat_label_lft = yticknames(n)  

;---Left label
;    txres@txAngleF = 0.0 
    dum_lft(n) = gsn_add_text(wks,map,lat_label_lft,minlon,ytickvals(n),txres)

  end do

end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;
root = "./"
; read data for particular experiments
expt_list = (/"xbmea","xbmeb","xbmed","xbmee","xbooc","xbooj","xbook","xbood","xbooa"/)
color_index = (/"blue","red","red","red","black","orange","orange",\
             "orange","blue"/)
expt_index = (/"A","B","C","D","E","F","G","H","I"/)
;---Start the graphics
  wks = gsn_open_wks("png","radar")   ; send graphics to PNG file
do zl=0,1
zlat=60
if (zl.eq.1) then
 zlat=40
end if
if (zlat.eq.40) then
 trop_strat="trop"
 yticknames=(/0,20,40,60,80,100/)
else
 trop_strat="strat"
 yticknames=(/0,100,200,300,400,500/)
end if 
max_amp = max(yticknames)
;set up output array
phase_w1=new(dimsizes(expt_list),"double")
amp_w1=new(dimsizes(expt_list),"double")
phase_w2=new(dimsizes(expt_list),"double")
amp_w2=new(dimsizes(expt_list),"double")
do i=0,dimsizes(expt_list)-1
 expt = expt_list(i)
 f=addfile(root+expt+".zstar"+zlat+"_"+trop_strat+".fourier.nc","r")
 thisz=f->ht_mm_p
 amp_w1(i)=thisz(0,0,0,0)
 phase_w1(i)=thisz(1,0,0,0)
 amp_w2(i)=thisz(0,0,0,1)
 phase_w2(i)=thisz(1,0,0,1)
 delete(f)
end do

print(max(amp_w1))
print(max(amp_w2))

;
; rescale amplitudes so they are in the range 0-90N
; method: work from max plotted amplitude from yticks, divide by 90
; then divide all amplitudes by same factor, then do 90- answer to make outside ring 90N
fact=(max_amp/90.0)
amp_w1_s=90-(amp_w1/fact)
amp_w2_s=90-(amp_w2/fact)
ytickvals=yticknames/fact	; these are the ytick values
yticknames=yticknames(::-1)	; these are the ytick labels (reversed so 90N is outside)
;---Create some dummy lat,lon and data values.
  npts   = dimsizes(expt_list)
;  lat    = random_uniform(   5, 90,npts)
;  lon    = random_uniform(-180,180,npts)
;  dvals  = random_uniform(0,100,npts)

;---Generate some levels to group the data values by.
;  levels  = ispan(0,100,10)
;  nlevels = dimsizes(levels)

;---For each range, we want a different size and color.
;  sizes  = ispan(25,75,5)/1000.    ; 0.0025 to 0.0075


;---Set some resources for a polar map.
  res              = True

  res@gsnMaximize  = False                 ; Maximize plot in frame
  res@gsnDraw      = False                ; Don't draw plot 
  res@gsnFrame     = False                ; Don't advance frame (page)

  res@gsnTickMarksOn  = True
  res@tiMainString  = "Z*"+zlat+"N "+trop_strat

  res@gsnPolar     = "NH"                 ; North hemisphere

  res@mpFillOn     = False                ; Turn off map fill
  res@mpOutlineOn  = False                ; Turn off map outlines

  res@mpCenterLonF = -90                  ; Rotate the map
  res@mpCenterLatF = 90                  ; Rotate the map
  res@mpGridLatSpacingF = 90/5.

;---Create a polar map with the given resources.
  map = gsn_csm_map_polar(wks,res)

;---Create a resource list for the markers.
  mkres = True

;---Arrays for attaching two sets of markers
  dum_fill   = new(npts,graphic)
  dum_hollow = new(npts,graphic)

  mkres@gsMarkerThicknessF = 2.0      ; Twice as thick
  do i=0,npts-1
    
    mkres@gsMarkerIndex = 16          ; Filled dots
    mkres@gsMarkerSizeF = 0.01
    mkres@gsMarkerColor = "red"

    ; new code use letters/text
    ;---Set some text resources
    txres               = True
    txres@txFontHeightF = 0.0125
    txres@txPosXF       = 0.1
    txres@txFontColor = color_index(i)
    dum_hollow(i) = gsn_add_text(wks,map,expt_index(i),phase_w1(i),amp_w1_s(i),txres)
    dum_fill(i) = gsn_add_text(wks,map,expt_index(i),phase_w2(i),amp_w2_s(i),txres)
    
  end do
;
; add y-axis labels
minlat=0
maxlat=90
minlon=120
maxlon=105
add_lc_labels(wks,map,minlat,maxlat,minlon,maxlon,ytickvals,yticknames)

;---Drawing the map plot will draw all the attached markers too.
  draw(map)
  frame(wks)
end do
end


