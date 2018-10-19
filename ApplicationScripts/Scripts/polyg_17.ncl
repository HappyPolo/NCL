;----------------------------------------------------------------------
; poly_17.ncl
;
; Concepts illustrated:
;   - Color-coding markers based on surface wind speed
;   - Drawing a custom labelbar outside a map
;   - Reading an ASCII file with a mix of headers and rows of data
;----------------------------------------------------------------------
; The ASCII file for this example consists of a random number of header
; lines, followed by a single number representing the number of rows,
; followed by that many rows of data, each with 9 columns. 
; 
; The read_data function below is written to handle this kind of file
; although in this particular script, the ASCII file only has one
; set of headers and data.
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This function reads an ascii file and returns an nrow by ncol array.
;
; Assumptions about this file:
;  - The very first line starts with a % in the first column.
;  - There will be a series of these "%" lines immediately
;    followed by a single number with a row count
;  - This will immediately be followed by this many rows, with
;    9 columns of data to read.
;  - There are no blank lines
;  - There are no other stray lines
;----------------------------------------------------------------------
undef("read_data")
function read_data(filename)
begin
  lines  = asciiread(filename,-1,"string")
  nlines = dimsizes(lines)

  ncols = 9
  nl    = 0    ; line counter
  do while(nl.lt.nlines)
;---Read the first character of this line
    first = str_get_cols(lines(nl),0,0)

;---If it's a "%", then increment to next line.
    if(first.eq."%") then
      nl = nl + 1           ; increment line counter
      continue
    else
;---Otherwise, get the number of rows and read the data.
      nrows = toint(lines(nl))
      nl = nl + 1           ; increment line counter
      print("==================================================")
      print("Reading " + nrows + " rows of data.")
;
; Clean up the strings so there's only one space between
; each string, and no extra space at beginning or end.
; This allows us to use str_split_csv to parse this
; chunk of data. str_split_csv expects a single character
; delimiter (a space in this case).
;
      lines(nl:nl+nrows-1) = str_sub_str(lines(nl:nl+nrows-1),"    "," ")
      lines(nl:nl+nrows-1) = str_sub_str(lines(nl:nl+nrows-1),"   "," ")
      lines(nl:nl+nrows-1) = str_sub_str(lines(nl:nl+nrows-1),"  "," ")
      lines(nl:nl+nrows-1) = str_strip(lines(nl:nl+nrows-1))

;---Parse the data into a 2D integer array
      x := tofloat(str_split_csv(lines(nl:nl+nrows-1)," ",0))
      nl = nl + nrows

;---Print min/max of each column of data.
      do i=0,ncols-1
        print("Column " + (i+1) + " has min/max = " + min(x(:,i)) + \
               "/" + max(x(:,i)))
      end do
    end if
  end do

  return(x)
end


;----------------------------------------------------------------------
; This is the main code that reads the data and plots it.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;----------------------------------------------------------------------
; Read the data and place into individual arrays.
;----------------------------------------------------------------------
  x     = read_data("cygnss_test.txt")
  dim   = dimsizes(x)
  nrows = dim(0)
  ncols = dim(1)

  year = x(:,0)
  jday = x(:,1)
  secs = x(:,2)/10.0
  lats = x(:,3)/100.0
  lons = x(:,4)/100.0
  idno = toint(x(:,5))
  wspd = x(:,6)/10.0
  stdv = x(:,7)/10.0
  gain = x(:,8)/10.0

;----------------------------------------------------------------------
; Start the graphics
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","polyg")

;---Assign a colormap and then get its RGB array
  colormap = "WhViBlGrYeOrRe"
  gsn_define_colormap(wks,colormap)
  cmap = gsn_retrieve_colormap(wks)

;---Levels to use for grouping wind speed values
  levels = fspan(0.0,10.0,50)
  nlevels  = dimsizes(levels)
;
; Get a nice span of colors through the current color map, but
; skip the first three colors (0-2).
;
  colors = span_color_indexes(cmap(3:,:),dimsizes(levels)+1) + 3

;----------------------------------------------------------------------
; Create a map plot for which to add color-coded markers.
;----------------------------------------------------------------------
  mpres                       = True

  mpres@gsnMaximize           = True   ; maximize size of plot in window
  mpres@gsnDraw               = False  ; turn off draw
  mpres@gsnFrame              = False  ; turn off page advance

  mpres@mpMinLatF             = min(lats)-3
  mpres@mpMaxLatF             = max(lats)+3
  mpres@mpMinLonF             = min(lons)-3
  mpres@mpMaxLonF             = max(lons)+3

  mpres@mpDataBaseVersion     = "MediumRes"     ; Better map resolution
  mpres@mpLandFillColor       = "tan"
  mpres@tiMainString          = "Surface Wind Speed"
  mpres@pmTickMarkDisplayMode = "Always"    ; Nicer map tickmarks

;---Create the map
  map = gsn_csm_map(wks,mpres)

;----------------------------------------------------------------------
; Group the wind speed values according to which range they fall
; in, and attach them to the map as a colored marker.
;----------------------------------------------------------------------
  mkres               = True
  mkres@gsMarkerIndex = 16        ; filled dot
  mkres@gsMarkerSizeF = 0.002
  markerid = new(nlevels+1,graphic)

  do i=0,nlevels
    if(i.eq.0) then                         ; first level
      ii := ind(wspd.lt.levels(0))
    else if(i.eq.nlevels) then              ; middle levels
      ii := ind(wspd.ge.levels(nlevels-1))
    else                                    ; last level
      ii := ind(wspd.ge.levels(i-1).and.wspd.lt.levels(i))
    end if
    end if    
    if(.not.any(ismissing(ii))) then
      mkres@gsMarkerColor = colors(i)
      markerid(i) = gsn_add_polymarker(wks,map,lons(ii),lats(ii),mkres)
    end if
  end do

  draw(map)   ; This will draw map and the attached markers

;----------------------------------------------------------------------
; Draw a labelbar
;----------------------------------------------------------------------
  lbres                    = True
  lbres@vpWidthF           = 0.80             ; width
  lbres@vpHeightF          = 0.10             ; height
  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lbres@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
  lbres@lbFillColors       = colors           ; Colors for boxes.
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF = 0.012            ; label font height

  labels = sprintf("%4.2f",levels)
  gsn_labelbar_ndc (wks,nlevels+1,labels,0.1,0.23,lbres) 

  frame(wks)
end
