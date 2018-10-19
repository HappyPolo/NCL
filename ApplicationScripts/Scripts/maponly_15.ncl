;================================================;
;  maponly_15.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing U.S. climate divisions
;   - Filling U.S. climate divisions with different colors
;   - Setting land, ocean, and inland water fill to transparent
;   - Attaching a custom labelbar to a map
;   - Turning off the map lat/lon grid lines
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("png","maponly")        ; send graphics to PNG file
  gsn_define_colormap(wks,"gui_default")

  res                      = True
  res@gsnMaximize          = True
  res@mpFillOn             = False

;
; These next three resources set up the drawing of climate divisions.
;
  res@mpOutlineBoundarySets = "AllBoundaries"
  res@mpDataBaseVersion     = "MediumRes"
  res@mpDataSetName         = "Earth..3"

  res@mpGridAndLimbOn       = False

  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             =   20.
  res@mpMaxLatF             =   50.
  res@mpMinLonF             = -130.
  res@mpMaxLonF             =  -65. 

  res@tiMainString          = "U.S. with climate divisions outlined"

  map = gsn_csm_map(wks,res)

;
; Now do something more complicated of coloring the climate
; areas by a third field.
;
; The original name of the file was
; "climdivcorr.24.8.154.75.267.22.53.59.data"
;
   dir   = ncargpath("data") + "/asc/"
  cldata = asciiread(dir + "climdivcorr.txt",(/345,3/),"float")
  clmin = min(cldata(:,2))
  clmax = max(cldata(:,2))

; Group each datum into 1 of 20 equally-spaced bins
  bins    = fspan(clmin,clmax,20)
  databin = new(dimsizes(cldata(:,0)),integer)
  do i = 0, dimsizes(databin) - 1
     databin(i) = min(ind(bins .ge. cldata(i,2))) + 1
  end do

;
; Note that for Earth..3, the climate divisions are the 
; equivalent of "counties".
;
  res@mpOutlineSpecifiers   = "conterminous us : counties"
  res@mpFillAreaSpecifiers  = "conterminous us : counties"
  res@mpOutlineBoundarySets = "usstates"      ; "geophysical"
  res@mpFillBoundarySets    = "geophysical"

  res@gsnTickMarksOn = False
  res@mpFillOn       = True
  res@mpFillColors   = ispan(0,23,1)

  res@mpOceanFillColor       = "transparent"
  res@mpLandFillColor        = "transparent"
  res@mpInlandWaterFillColor = "transparent"

  res@mpOutlineOn     = True

  res@gsnDraw  = False
  res@gsnFrame = False

  res@tiMainString    = "Climate divisions colored by 3rd field"
  res@gsnCenterString = "climdivcorr.24.8.154.75.267.22.53.59.data"

  map = gsn_csm_map_ce(wks,res)
;
; Get all of the area names associated with Earth..3 and the
; corresponding group numbers. The area names will be of the
; format "Arkansas : 01", where "01" is the climate division number.
;
; The group numbers are essentially color index values that were
; chosen such that adjacent areas will not have the same color
; (if you choose to color each one randomly).
;
; For example, Arkansas has 9 climate divisions, with the following
; groups:
;       Arkansas : 01, group 7
;       Arkansas : 02, group 8
;       Arkansas : 03, group 7
;       Arkansas : 04, group 6
;       Arkansas : 05, group 5
;       Arkansas : 06, group 6
;       Arkansas : 07, group 4
;       Arkansas : 08, group 7
;       Arkansas : 09, group 4
;
; From this, if you chose to use the default group numbers to color each 
; climate area, then climate areas (01,03,08) would be the same color, 
; (07,09) would be the same, and (04,06) would be the same, and 
; 02 and 05 would each be their own color.
;
  getvalues map
    "mpAreaNames"         : anames
    "mpDynamicAreaGroups" : groups
  end getvalues

; Areas 659 through 1116 are the states with their climates.
;  print(anames(659:1116) + ", group " + groups(659:1116))

  states = (/ "Alabama", "Arizona", "Arkansas", "California", "Colorado",\
              "Connecticut", "Delaware", "Florida", "Georgia", "Idaho",\
              "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",\
              "Louisiana", "Maine", "Maryland", "Massasachusetts", "Michigan",\
              "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", \
              "Nevada", "New Hampshire", "New Jersey", "New Mexico", \
              "New York", "North Carolina", "North Dakota", "Ohio", \
              "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", \
              "South Carolina", "South Dakota", "Tennessee", "Texas", \
              "Utah", "Vermont", "Virginia", "Washington", "West Virginia",\
              "Wisconsin", "Wyoming"/)
;
; For each state and climate division id in the data (first two
; columns), get the state name and build the area name. These are all in
; the form "State : 01". Use this name to then retrieve the index
; value into the anames array, and then use this same index to reset
; the group id to the index calculated above in the databin array.
; This will give us our new set of colors for the climate areas.
;
; Note the first four indexes (0-3) are reserved (undefined, land,
; ocean, inland water), so add 3 to start at index 4.
;
; A prerequisite was to increase the number of area groups to the number of
; bins (20) + the four predefined indexes. The result is that the areas
; corresponding to the group ids that are set will be colored based on fill
; color indexes 4-23.
;
  ming = max(databin) + 5      ; Use to keep track of actual min/max of
  maxg = -1                    ; group ids used.

  do i = 0, dimsizes(databin) - 1
    state_ix = floattointeger(cldata(i,0)) - 1
    clim_ix  = floattointeger(cldata(i,1))
    state    = states(state_ix)
    areaname = state + " : " + sprinti("%2.2i",clim_ix)

    j = ind(areaname.eq.anames)     ; Find the index into the anames array.
    if(.not.any(ismissing(j))) then
      groups(j) = databin(i) + 3     ; Reset the group id
      ming = min((/ming,groups(j)/))
      maxg = max((/maxg,groups(j)/))
    end if
    delete(j)
  end do
;
; Increase the area group count (which lets you have more
; different colors) and set the new group ids.
;
  setvalues map
    "mpAreaGroupCount"    : 24         ; Default is 10
    "mpDynamicAreaGroups" : groups
  end setvalues

;
; Create a labelbar.
;
  colors = ispan(ming,maxg,1)
  nboxes = dimsizes(colors)

  labels                   = new(nboxes+1,string)
  labels                   = ""
  labels(0)                = sprintf("%.2f",min(bins))
  labels(nboxes)           = sprintf("%.2f",max(bins))

  lbres                    = True          ; labelbar only resources
  lbres@vpWidthF           = 0.70
  lbres@vpHeightF          = 0.10
  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lbres@lbLabelAlignment   = "ExternalEdges"  
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF = 0.013            ; label font height

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
;
; Create some annotation resources indicating how we want to
; attach the labelbar to the plot. Here, we are using the top center
; of the labelbar as the point which we are going to position
; it, and then we use amOrthogonalPosF to move it down.
;                                                                 
  amres                  = True
  amres@amJust           = "TopCenter"
  amres@amOrthogonalPosF = 0.4
  annoid = gsn_add_annotation(map,lbid,amres)

  draw(map)
  frame(wks)

end
