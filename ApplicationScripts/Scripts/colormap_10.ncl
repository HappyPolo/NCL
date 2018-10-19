;----------------------------------------------------------------------
; colormap_10.ncl
;
; Concepts illustrated:
;   - Drawing a color map as a horizontal labelbar
;   - Drawing every color map in NCL
;   - Using functions for cleaner code
;   - Using "systemfunc" to get a list of files
;   - Using read_colormap_file to read in a colormap as an RGBA array.
;   - Reversing a color map
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This function gets a list of NCL's current colormap names, 
; without their ".gp", ".rgb", etc, suffixes.
;----------------------------------------------------------------------
undef("get_current_colormap_names")
function get_current_colormap_names()
local ssplit, nssplit, ncfiles
begin
  cfiles = systemfunc("ls -1 $NCARG_ROOT/lib/ncarg/colormaps/*.rgb")

;---Parse each string to get just the name without the ".rgb" and paths.
  ncfiles = dimsizes(cfiles)
  print("Found " + ncfiles + " color maps")
  do i=0,ncfiles-1
    ssplit  := str_split(cfiles(i),"/.")
    nssplit = dimsizes(ssplit)
    cfiles(i) = ssplit(nssplit-2)
  end do
  return(cfiles)
end

;----------------------------------------------------------------------
; This function draws a page of labelbars of the given colormaps.
;----------------------------------------------------------------------
undef("labelbar_colormap")
procedure labelbar_colormap(cmap_names,opt)
local height, lbres, ncmaps
begin
  ncmaps = dimsizes(cmap_names)

;---Set various options based on "opt"
  reverse      = get_res_value_keep(opt,"reverse",False)
  title        = get_res_value_keep(opt,"title",True)
  wks_type     = get_res_value_keep(opt,"wks_type","png")
  wks_dir      = get_res_value_keep(opt,"wks_dir","./")

;
; Start with a larger image and later trim to 500x500, 
; for better looking fonts.
;
  wks = gsn_open_wks("png","colormap")

  lbres                   = True
  txres                   = True
  txres@txFontHeightF     = 0.015

  lbres@vpWidthF          = 1.0     ; full width of viewport
  lbres@vpHeightF         = 0.05
  lbres@vpXF              = 0.0     ; flush right

  lbres@lbOrientation     = "horizontal"
  txres@txJust            = "BottomCenter"

  lbres@lbLabelsOn        = False
  lbres@lbBoxLinesOn      = False

;---Make sure labelbar fills the viewport region we specified
  lbres@lbBoxMinorExtentF = 1.0
  lbres@lbTopMarginF      = 0.0
  lbres@lbBottomMarginF   = 0.0
  lbres@lbRightMarginF    = 0.0
  lbres@lbLeftMarginF     = 0.0

  lbres@lbPerimOn         = True
  lbres@lbPerimThicknessF = 2.0
  lbres@lbPerimColor      = "black"

;---necessary so we get all solid fill
  lbres@lbMonoFillPattern = True    

  lnres = True
  lnres@gsLineThicknessF = 1.5

;---Read color map
  num_per_page = 10
  do i=0,ncmaps-1,num_per_page
    do j=0,num_per_page-1
      n = i+j
      if(n.ge.ncmaps) then
         break
      end if
;---Read colormap as an array of RGBA quadruplets
      cmap := read_colormap_file(cmap_names(n))
      clen = dimsizes(cmap(:,0))
      if(reverse) then
        cmap = cmap(::-1,:)
      end if

      lbres@lbFillColors := cmap
      lbres@vpYF         = 0.93 - j*0.1+(lbres@vpHeightF)/2.
      if(title) then
        tposx  = 0.5
        tposy  = lbres@vpYF+0.01
        if(.not.reverse) then
          title_string = cmap_names(n) + " (" + clen + " colors)"
        else
          title_string = cmap_names(n) + " (reversed, " + clen+ " colors)"
        end if
      end if

      lbid = gsn_create_labelbar (wks,clen,"",lbres)

      if(title) then
        txid = gsn_create_text_ndc(wks,title_string,tposx,tposy,txres)
      end if

      draw(lbid)
      draw(txid)
;
; This draws a line around the labelbar. This *might* be to 
; force the labelbar to always be a consistent size.
;
      x = lbres@vpXF
      y = lbres@vpYF
      w = lbres@vpWidthF
      h = lbres@vpHeightF
      gsn_polyline_ndc(wks,(/x,x+w,x+w,x,x/),(/y,y,y-h,y-h,y/),lnres)
    end do
    frame(wks)
  end do
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  cname_array = get_current_colormap_names()
  opt = True
;  opt@reverse = True     ; this will reverse each color map
  labelbar_colormap(cname_array,opt)
end
