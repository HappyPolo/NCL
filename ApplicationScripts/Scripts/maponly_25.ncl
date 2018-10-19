;----------------------------------------------------------------------
;  maponly_25.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Drawing U.S. climate divisions for Idaho
;   - Drawing specific map areas in a given color.
;   - Attaching a custom labelbar to a map
;   - Adding a labelbar to a map as an annotation
;   - Attaching text strings to a map
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
; This function attaches a labelbar to the map, using the fill
; colors specified by the mpSpecifiedFillColors resource.
;----------------------------------------------------------------------
undef("add_labelbar")
function add_labelbar(wks,plot,labels,mpres)
local vph, vpw, lbres, lbid, nboxes
begin
;---Get width/height of map so we can calculate width/height for labelbar.
  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

;---Set up labelbar info.
  nboxes = dimsizes(labels)
   
  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = True          ; Necessary to control sizes
  lbres@vpWidthF           = 0.3 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.5 * vph     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.75          ; puts space between color boxes
  lbres@lbFillColors       = mpres@mpSpecifiedFillColors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbPerimOn          = False         ; turn off labelbar perimeter

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
   
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot. Here, we are using the top right
; corner of the labelbar as the point which we are going to position
; it, and then we use amParallelPosF and amOrthogonalPosF to indicate
; where we want to place it.
;                                                                 
  amres                  = True
  amres@amJust           = "TopRight"
  amres@amParallelPosF   =  0.5      ; Top
  amres@amOrthogonalPosF = -0.5      ; Right
  annoid = gsn_add_annotation(plot,lbid,amres)

  return(annoid)
end

;----------------------------------------------------------------------
; This function attaches text strings labeling each climate division.
; We used trial and error to get the lat/lon locations of each 
; division name.
;----------------------------------------------------------------------
undef("add_text_strings")
function add_text_strings(wks,plot)
local txid, labels, num_cdivs
begin
  num_cdivs = 10
  labels = sprinti("%02i",ispan(1,num_cdivs,1))
  lats   = (/  48.5,  46.7,  45.8,  45.0,  44.0,  42.3,  42.9,  44.4,\
               43.5,  43.0/)
  lons   = (/-116.6,-116.8,-116.5,-115.2,-116.6,-115.5,-114.2,-113.6,\
             -112.8,-111.8/)

  txres = True
  txres@txJust        = "CenterCenter"
  txres@txFontHeightF = 0.01
  txres@txPerimOn     = True
  txres@txBackgroundFillColor = "white"
  txid = gsn_add_text(wks,plot,labels,lons,lats,txres)
  return(txid)
end

;----------------------------------------------------------------------
; Main code.
;----------------------------------------------------------------------
begin
;---Get the names of the Idaho climate divisions ["Idaho : 01", etc.]
  num_cdivs   = 10       ; Idaho
  idaho_str   = "Idaho : "
  idaho_areas = idaho_str + sprinti("%02i",ispan(1,num_cdivs,1))

  wks = gsn_open_wks("png","maponly") ; send graphics to PNG file

;---Resources for Idaho map.
  res                       = True

  res@gsnMaximize           = True
  res@gsnDraw               = False
  res@gsnFrame              = False

;---Zoom in on Idaho. Leave space on right side for a labelbar.
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             =   41.5
  res@mpMaxLatF             =   49.5
  res@mpMinLonF             = -117.5
  res@mpMaxLonF             = -110.5

  res@mpOutlineOn          = True
  res@mpFillOn             = True

  res@pmTickMarkDisplayMode = "Always"    ; nicer tickmarks

;---These next three resources set up the drawing of climate divisions.
  res@mpOutlineBoundarySets = "NoBoundaries"
  res@mpFillBoundarySets    = "NoBoundaries"
  res@mpDataBaseVersion     = "MediumRes"
  res@mpDataSetName         = "Earth..3"

;---Indicate that you only want to outline and fill the Idaho divisions.
  res@mpOutlineSpecifiers   = idaho_areas
  res@mpFillAreaSpecifiers  = idaho_areas

;---These colors were chosen to match a graphic found on the NOAA website
  res@mpSpecifiedFillColors = (/"red","skyblue","orange","yellow","green", \
  "pink","blue","navyblue","purple","hotpink"/)

  res@tiMainString          = "Climate divisions in Idaho"
  
  map = gsn_csm_map(wks,res)    ; Create the map

;---Attach a labelbar.
  labels = (/"Panhandle", "North Central Prairies", \
             "North Central Canyons", "Central Mountains", \
             "Southwestern Valleys", "Southwestern Highlands", \
             "Central Plains", "Northeastern Valleys", \
             "Upper Snake River Plains", "Eastern Highlands"/)
  amid = add_labelbar(wks,map,labels,res)

;---Attach some text strings.
  txid1 = add_text_strings(wks,map)

  draw(map)
  frame(wks)
end
