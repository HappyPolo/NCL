;*****************************************************
; maponly_6.ncl
;*****************************************************
;
; Concepts illustrated:
;   - Drawing the US with a Lambert Conformal projection
;   - Filling each US state based on a data value
;   - Drawing a custom labelbar
;   - Turning off the map lat/lon grid lines
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*****************************************************
begin
  wks = gsn_open_wks("png","maponly")                 ; send graphics to PNG file
  gsn_define_colormap(wks,"WhViBlGrYeOrRe")           ; assign colormap
  cmap = gsn_retrieve_colormap(wks)                   ; retrieve colormap
;**************************************************
; the data by state in alphabetical order
;**************************************************
  data=(/84.7,59.2,94.6,54.7,48.2,58.0,81.0,69.4,85.2,51.2,71.7,80.2, \
  66.2,66.1,100.7,90.5,77.0,73.6,64.6,70.6,54.0,90.5,79.8,56.1,\
  62.6,69.0,68.6,64.5,46.4,61.1,84.9,54.8,76.9,82.7,63.8,70.1, \
  74.7,81.7,61.3,93.5,73.0,29.8,64.6,77.4,61.1,87.0,57.3,55.1/)
;**************************************************         
; the state names. Note each state name must be 
; preceded by "Conterminous US :" which prevents the
; counties from being drawn.  
;**************************************************
  states = (/"Alabama","Arizona","Arkansas","California","Colorado",\
  "Connecticut","Delaware","Florida","Georgia","Idaho","Illinois",\
  "Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland",\
  "Massachusetts","Michigan","Minnesota","Mississippi","Missouri",\
  "Montana","Nebraska","Nevada","New Hampshire","New Jersey",\
  "New Mexico","New York","North Carolina","North Dakota","Ohio",\
  "Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina",\
  "South Dakota","Tennessee","Texas","Utah","Vermont","Virginia",\
  "Washington","West Virginia","Wisconsin","Wyoming"/)
  states="Conterminous US :"+states
;**************************************************
; data "contour" levels
;************************************************** 
  levels = (/30,35,40,45,50,55,60,65,70,75,80,85,90,95,100/)
  labels = (/"30","35","40","45","50","55","60","65","70","75","80", "85",\
  "90","95","100"/)
  nlevels = dimsizes(levels) 
;************************************************** 
; color indices into colormap (0 = foreground,1 = background)
; must have one  more color than number of levels
;**************************************************  
  firstdx = 2                                    ; starting index
  stride  = 6                                    ; interval between colors
  colors  = ispan(firstdx,firstdx+stride*nlevels,stride)
  ncolors = dimsizes(colors)
;**************************************************  
; set label bar RGB color triplets
;**************************************************  
  labelbarcolors        = new((/ncolors,3/),float)
  do n = 0, ncolors-1
    labelbarcolors(n,:) = cmap(colors(n),:)
  end do
;**************************************************  
; set the color index of each state 
;************************************************** 
  statecolors = new((/48/),integer)
  do n = 0, 47
    statecolors(n) = GetFillColorIndex(levels,colors,data(n))
  end do
;**************************************************
; plot parameters
;**************************************************  
  res                       = True
  res@gsnFrame              = False               ; don't advance frame yet
  res@mpDataBaseVersion     = "MediumRes"          ; higher res data base
  res@vpWidthF              = 0.90                ; change aspect ratio of plot
  res@vpHeightF             = 0.90
  res@vpXF                  = 0.05
  res@vpYF                  = 0.95
  
  res@mpFillOn              = True                ; turn on map fill
  res@mpLandFillColor       = "Background"        ; set to white  
  res@mpPerimOn             = False               ; don't draw box around map
  res@mpGridAndLimbOn       = False               ; Don't draw lat/lon lines.
  res@mpFillAreaSpecifiers  = states              ; area names 
  res@mpSpecifiedFillColors = statecolors              ; area colors
  res@mpOutlineOn           = True                ; turn on map outline
  res@mpOutlineBoundarySets = "USStates"          ; turn on state boundaries
  
  res@tiMainFontHeightF     = 0.018               ; font height of title
  res@tiMainString          = "1994-1998 Male Lung Cancer Age-Adjusted Deaths per 100,000"
  res@gsnMaximize           = True                ; blow up plot
;***************************************************
; map resources for projection
;***************************************************  
  res@mpProjection           = "LambertConformal"  ; choose projection
  res@mpLambertParallel1F    = 33.0                ; two parallels
  res@mpLambertParallel2F    = 45.0
  res@mpLambertMeridianF     = -95.0               ; central meridian
  res@mpLimitMode            = "LatLon"
  res@mpMinLatF              = 24.0                ; map area
  res@mpMaxLatF              = 50.0                ; latitudes
  res@mpMinLonF              = -125.0              ; and
  res@mpMaxLonF              = -65.0               ; longitudes
  
  map = gsn_csm_map(wks,res)                       ; Draw map.
;*************************************************
; add custom label bar
;************************************************* 
  lbres = True
  lbres@lbPerimOn            = False               ; no label bar box
  lbres@lbOrientation        = "Horizontal"        ; orientation
  lbres@vpWidthF             = 0.7                 ; size
  lbres@vpHeightF            = 0.1
  lbres@lbLabelFontHeightF   = 0.012               ; label font height
  lbres@lbLabelAlignment     = "InteriorEdges"     ; where to label
  lbres@lbMonoFillPattern    = True                ; fill sold
  lbres@lbFillColors         = labelbarcolors      ; must be RGB triplets
  
  gsn_labelbar_ndc (wks,nlevels+1,labels,0.13,0.28,lbres)
  frame(wks)                                       ; now advance frame
end

