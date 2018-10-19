;*************************************************
; text_10.ncl
;
; Concepts illustrated:
;   - Attaching text strings to a map
;   - Removing text strings that overlay other text strings
;   - Converting lat/lon values to NDC values
;   - Removing an annotation that has been attached to a plot
;   - Using "getvalues" to retrieve the size of a plot
;   - Using "setvalues" to change the main title of an existing plot
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  stationfile="istasyontablosu_son.txt"
;
; -1 means read all rows into a one-dimensional variable,
; ATTENTION, DO NOT READ STRINGS.
;
  dummy = asciiread(stationfile,-1,"float")
  ncol = 6                                ; number of columns is 6
  npts = dimsizes(dummy)/ncol             ; get number of points

  stationdata = onedtond(dummy,(/npts,ncol/)) ; npts x ncol 

  no  = stationdata(:,0)     ; station numbers to appear on the map
  lat = stationdata(:,4)     ; latitude values
  lon = stationdata(:,5)     ; longitude values

;
; Start the graphics..
;
  wks = gsn_open_wks("png", "text")      ; send graphics to PNG file

  res = True

  res@gsnMaximize = True
  res@gsnDraw     = False
  res@gsnFrame    = False

  res@mpProjection      = "Mercator"     ; Change Map projection
  res@mpDataBaseVersion = "MediumRes"    ; Medium resolution

  res@mpLimitMode = "LatLon"     ; Limit the map area by latitude/longitude.
  res@mpMinLonF   = 25.50
  res@mpMaxLonF   = 45.20
  res@mpMinLatF   = 35.50
  res@mpMaxLatF   = 42.50

  res@pmTickMarkDisplayMode = "Always"
  res@mpPerimOn             = False

  res@mpOutlineOn                 = True
  res@mpOutlineBoundarySets       = "Geophysical"
  res@mpGeophysicalLineThicknessF = 1.0
  res@mpNationalLineThicknessF    = 0.5
  res@mpLandFillColor             = "white"
  res@mpGridAndLimbOn             = False
  res@mpOutlineDrawOrder          = "PostDraw"

  res@tiMainString = "Overlapping text strings"

;
; Create the map and add the station number texts.
;
  map = gsn_csm_map(wks,res)

  txres               = True
  txres@txFontHeightF = 0.007
  txres@txFont        = "helvetica-bold"

  text = gsn_add_text(wks,map,sprintf("%6.4g",no),lon,lat,txres)
  nstrs = dimsizes(text)

  draw(map)      ; Now draw map with text strings and 
  frame(wks)     ; advance the frame

;
; Retrieve the ids of the text strings that were just added so we can
; retrieve their heights, widths, and locations. This information 
; will be used to determine if any text strings are overlaying other text
; strings.
;
  nstrs=dimsizes(no)
  getvalues map
    "pmAnnoViews" : text_ids
  end getvalues

  xndc    = new(nstrs,float)     ;  X center of box in NDC coords
  yndc    = new(nstrs,float)     ;  Y center of box in NDC coords
  rgt     = new(nstrs,float)     ; Hold right position of text box.
  lft     = new(nstrs,float)     ;  "   left     "     "   "    " 
  top     = new(nstrs,float)     ;  "   top      "     "   "    " 
  bot     = new(nstrs,float)     ;  "   bottom   "     "   "    " 
  width   = new(nstrs,float)     ;  width of each text box
  height  = new(nstrs,float)     ;  height of each text box

; Loop through and get the width and height of each box.
;
  do i=0,nstrs-1
    getvalues text_ids(i)
      "vpWidthF"  : width(i)
      "vpHeightF" : height(i)
    end getvalues
  end do

; Convert the lat/lon center of each box to NDC coordinates, since this
; is what the width and height values are in.
;
  datatondc(map,lon,lat,xndc,yndc)

; Calculate the four corners of each text box in NDC coordinates.
;
  top = yndc + height/2.
  bot = yndc - height/2.
  lft = xndc -  width/2.
  rgt = xndc +  width/2.

;
; Now we're going to loop through each text string that has been added,
; and compare it to all other text strings that have been added to see if
; they overlap. If an overlap is encountered, one of the strings will be
; tagged for removal, and a box will be drawn around it (just to show,
; for debug purposes, which text strings are getting removed).
;
  removed_list = new(nstrs,integer)
  rcount = 0                         ; Number of removed text boxes.

;
; ibox1 is index of box that we're checking to see if it overlaps.
; ibox2 is the index of the box that we're checking box ibox1
; against.
;
  do ibox1 = 0,nstrs-1
    ibox2 = 0
    overlap_found = False 

    do while(ibox2.lt.nstrs.and..not.overlap_found)
;
; Check if any one of the corners represented by box "ibox1" is inside
; the box representd by "ibox2".  If so, remove it.  Make sure you are
; not checking a box against itself, or against a box that has already
; been removed.
;
      if (ibox1.ne.ibox2.and.(.not.any(ibox2.eq.removed_list))) then
        if ( (top(ibox1).le.top(ibox2).and.top(ibox1).ge.bot(ibox2).and. \
              lft(ibox1).le.rgt(ibox2).and.lft(ibox1).ge.lft(ibox2)).or. \
             (bot(ibox1).le.top(ibox2).and.bot(ibox1).ge.bot(ibox2).and. \
              lft(ibox1).le.rgt(ibox2).and.lft(ibox1).ge.lft(ibox2)).or. \
             (bot(ibox1).le.top(ibox2).and.bot(ibox1).ge.bot(ibox2).and. \
              rgt(ibox1).le.rgt(ibox2).and.rgt(ibox1).ge.lft(ibox2)).or. \
             (top(ibox1).le.top(ibox2).and.top(ibox1).ge.bot(ibox2).and. \
              rgt(ibox1).le.rgt(ibox2).and.rgt(ibox1).ge.lft(ibox2))) then

          overlap_found = True         ; Mark that an overlap has been found.

          removed_list(rcount) = ibox1    ; Update removed_list and
          rcount = rcount + 1             ; its counter.
        end if
      end if
      ibox2 = ibox2 + 1               ; Update the box counter
    end do
  end do

;
; Here's the code that removes the overlapping text strings.
;
  NhlRemoveAnnotation(map,text_ids(removed_list(:rcount-1)))

;
; Now redraw the plot, which should have all of the overlapping text 
; strings removed.
;
  setvalues map
    "tiMainString" :  "Overlapping text strings removed"
  end setvalues

  draw(map)
  frame(wks)
end
