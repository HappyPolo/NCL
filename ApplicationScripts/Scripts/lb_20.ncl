;----------------------------------------------------------------------
; lb_20.ncl
;
; Concepts illustrated:
;   - Drawing several labelbars on one page
;   - Reading a colormap from an ASCII file
;----------------------------------------------------------------------
; This example shows how to read a color map and its labels from
; an ASCII file, and then draw the color map as a bunch of labelbars
; on a page.
;
; The "lithologic" color map was downloaded from:
;
;  http://mrdata.usgs.gov/catalog/lithclass-color.php
;
; According to the website above, these colors provide the lithologic 
; legend for a state geological map compilation.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function reads the lithrgb.txt provided at 
;
;   http://mrdata.usgs.gov/catalog/lithclass-color.php
;
; and returns an RGB table with labels (as a n x 4 array)
;
; The return array looks like this:
;
;   255   255   255   background color
;     0     0     0   foreground color
;   253   244    63   unconsolidated material
;   255   255   137   alluvium
;   255   211    69   silt
;   255   203    35   sand
;    .     .      .    
;   255   255   255   ice
;   153   204   255   water
;
; The background and foreground colors are added by this script.
; They are not part of the original lithclass-color.php file.
;----------------------------------------------------------------------
function read_lithrgb_file()
local lines, nlines, line, tab, i, nrows
begin
  lines  = asciiread("lithrgb.txt",-1,"string")
  nlines = dimsizes(lines)
  tab    = str_get_tab()

;---Add 2 for background and foreground colors. Assuming nlines <- 254!
  rgb_array = new((/2+nlines,4/),"string")

;---Loop through each line and make sure it has 5 columns of data.
  nrows = 0
  do i=1,nlines-1     ; Skip the header line
    line = str_split(lines(i),tab)
    ncols = dimsizes(line)
    if(ncols.eq.5)
      rgb_array(nrows+2,:) = line(1:)
      nrows = nrows+1
    end if
    delete(line)
  end do

;---Return the RGB values and the rock type as strings.
  rgb_array(0,0:2) = "" + (/255,255,255/)    ; background
  rgb_array(1,0:2) = "" + (/  0,  0,  0/)    ; foreground
  rgb_array(0,3)   = "background color"
  rgb_array(1,3)   = "foreground color"
  return(str_lower(rgb_array(:nrows+1,:)))
end

;----------------------------------------------------------------------
; Procedure to draw labelbars associated with lithologic legend.
;----------------------------------------------------------------------
undef("draw_labelbars")
procedure draw_labelbars(wks,lithlabels:string)
local nboxes, lbid, lbres, vpx, vpy, vpw, vph
begin
  nboxes = dimsizes(lithlabels)-2   ; Remove background/foreground colors

  nboxes_per_bar = 45

  lbres                      = True

  lbres@lbOrientation        = "vertical"
  lbres@vpHeightF            = 0.9       ; Height and width
  lbres@vpWidthF             = 0.1       ; of labelbar.

;---Allow more control over labelbars.
  lbres@lbAutoManage         = False
  lbres@lbLabelFontHeightF   = 0.008

;---Turn various features on and off.
  lbres@lbPerimOn            = False
  lbres@lbTitleOn            = False
  lbres@lbMonoFillPattern    = True
  lbres@lbLabelJust          = "CenterLeft"
  lbres@lbLabelAlignment     = "BoxCenters"

;---How many labelbars do we need to create?
  nlabelbars = (nboxes/nboxes_per_bar) + 1
  lbid = new(nlabelbars,graphic)

;
; Loop through each set of labelbars and draw them. Each
; one will be to the right of the previous one.
;
  vpx = 0.00       ; Start at the leftmost edge.
  vpy = 0.95       ; Close to top of the screen.

  do i=0,nlabelbars-1
    istart = i*nboxes_per_bar+2
    iend   = min((/istart+nboxes_per_bar-1,nboxes+1/))
    if((iend-istart+1).lt.nboxes_per_bar)
      lbres@vpHeightF = (iend-istart+1.)/nboxes_per_bar
    end if
    lbres@lbFillColors         := ispan(iend,istart,1)
    gsn_labelbar_ndc(wks,min((/nboxes,iend-istart+1/)), \
                     lithlabels(istart:iend:-1),vpx,vpy,lbres)
    vpx = vpx+0.21   ; Move to right each time
  end do

;---Draw a title at the top
  txres = True
  txres@txFontHeightF = 0.02
  gsn_text_ndc(wks,"Legend for lithology colors",0.5,0.98,txres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  color_map = read_lithrgb_file()        ;  Read the color map.
  wks = gsn_open_wks("png","lb")         ;  send graphics to PNG file

;---Set the color map
  gsn_define_colormap(wks,toint(color_map(:,0:2))/255.)

  draw_labelbars(wks,color_map(:,3))     ; Draw the labelbars
  frame(wks)
end
