;----------------------------------------------------------------------
; table_6.ncl
;
; Concepts illustrated:
;   - Drawing a table of filled triangles
;   - Using gsn_csm_blank_plot to get custom tickmark labels
;   - Using "getvalues" to retrieve the min/max of axes
;   - Turning off the top and right tickmarks
;   - Attaching a custom labelbar to a plot
;   - Attaching filled triangles to a plot
;   - Attaching lines to a plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Function to draw upper and lower triangles in a viewport space,
; given data dimensioned 2 x row x col, a range of values for
; binning the data, and an array of colors for each bin.
;
; The 0 x row x col represent the upper triangles, and
; the 1 x row x col represent the lower triangles.
;----------------------------------------------------------------------
undef("add_triangles")
function add_triangles(wks:graphic,plot:graphic,values[2][*][*],ranges,colors)
local i, ii, lnres, gnres, dims, nrows, ncols, nrng, cols_for_tris, \
      rng_beg, rng_end, xmin, xmax, ymin, ymax, nr, nc, tri, line, xpos, ypos
begin
  dims  = dimsizes(values)
  nrows = dims(1)
  ncols = dims(2)
  nrng  = dimsizes(ranges)

;---Create array to hold colors for upper and lower triangles.
  cols_for_tris = new(dims,string)

  cols_for_tris = where(values.le.ranges(0),colors(0),cols_for_tris)
  cols_for_tris = where(values.gt.ranges(nrng-1),colors(nrng),cols_for_tris)
  do i=0,nrng-2
    rng_beg = ranges(i)
    rng_end = ranges(i+1)
    cols_for_tris = where(rng_beg.lt.values.and. \
                          values.le.rng_end,colors(i+1), \
                          cols_for_tris)
  end do

;---Retrieve range of axes so we can get width/heights of triangles
  getvalues plot
    "trXMinF"   : xmin
    "trXMaxF"   : xmax
    "trYMinF"   : ymin
    "trYMaxF"   : ymax
  end getvalues

  xsize = (xmax-xmin)/ncols         ; width of triangle
  ysize = (ymax-ymin)/nrows         ; height of triangle
  xdelta = xsize/10000.
  ydelta = ysize/10000.

  gnres = True
  lnres = True

;---Arrays to hold primitives.
  tri  = new((/2,nrows,ncols/),graphic)
  line = new((/nrows,ncols/),graphic)

;
; Loop through each row/column of data, and draw the 
; upper and lower triangle.
; 
  lnres@gsLineThicknessF = 1.5
  do nr = 0,nrows-1
;
; This test becomes necessary when the triangles reach the edge
; of the right axis. The coordinates for the triangles may not
; quite be inside the coordinates of the axes (xmin,xmax,ymin,ymax)
; so we have to subtract a small delta to make sure the coordinates
; are smaller.
;
    if(nr.eq.nrows-1) then
      ypos = ymax - ((nr+1) * (ysize-ydelta))
    else
      ypos = ymax - ((nr+1) * ysize)
    end if
    do nc = 0,ncols-1

;---Upper triangle
      gnres@gsFillColor = cols_for_tris(0,nr,nc)
      ii = nr*ncols+nc
      if(nc.eq.ncols-1) then
        xpos = xmin + (nc * (xsize-xdelta))
      else
        xpos = xmin + (nc * xsize)
      end if
      tri(0,nr,nc) = gsn_add_polygon(wks,plot,(/xpos,xpos+xsize,xpos,xpos/), \
                                  (/ypos,ypos+ysize,ypos+ysize,ypos/),gnres)
;---Lower triangle
      gnres@gsFillColor = cols_for_tris(1,nr,nc)
      ii = nr*ncols+nc
      if(nc.eq.ncols-1) then
        xpos = xmin + (nc * (xsize-xdelta))
      else
        xpos = xmin + (nc * xsize)
      end if
      tri(1,nr,nc) = gsn_add_polygon(wks,plot, \
                                  (/xpos,xpos+xsize,xpos+xsize,xpos/), \
                                  (/ypos,ypos+ysize,ypos,ypos/),gnres)
;---Diagonal line plus box
     line(nr,nc) = gsn_add_polyline(wks,plot,\
                   (/xpos,xpos+xsize,xpos+xsize,xpos,xpos,xpos+xsize/), \
                   (/ypos,ypos,ypos+ysize,ypos+ysize,ypos,ypos+ysize/),lnres)
    end do
  end do

;---Attach primitives to plot id so the "live" outside this function.
  plot@triangles = tri
  plot@lines     = line
  return(plot)
end

;----------------------------------------------------------------------
; Procedure to attach a horizontal labelbar to the bottom of plot.
;----------------------------------------------------------------------
undef("add_labelbar")
procedure add_labelbar(wks,plot,colors,labels)
local vph, vpw, nboxes, lbres, lbid, amres, annoid
begin
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(colors)

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False          ; Necessary to control sizes
  lbres@vpWidthF           = 0.15 * vpw    ; labelbar width
  lbres@vpHeightF          = 0.95 * vph    ; labelbar height
  lbres@lbFillColors       = colors        ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.02          ; font height. default is small
  lbres@lbLabelAlignment   = "InteriorEdges"  ; center of box
  lbres@lbOrientation      = "Vertical"
  lbres@lbPerimOn          = False

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
   
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot. Here, we are using the top right
; corner of the labelbar as the point which we are going to position
; it, and then we use amParallelPosF and amOrthogonalPosF to indicate
; where we want to place it.
;
; amParallelPosF/amOrthogonalPosF                                       ;
;    0.0/ 0.0  -  annotation in dead center of plot
;    0.5/ 0.5  -  annotation at bottom right of plot
;    0.5/-0.5  -  annotation at top right of plot
;   -0.5/-0.5  -  annotation at top left of plot
;   -0.5/ 0.5  -  annotation at bottom left of plot
;                                                                 
  amres                  = True
  amres@amJust           = "CenterLeft"
  amres@amParallelPosF   =  0.52
  amres@amOrthogonalPosF =  0.0
  plot@annoid = gsn_add_annotation(plot,lbid,amres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
;---Generate some dummy data, 2 x nrow, x ncol
  ndat   = 2
  nrow   = 7
  ncol   = 22
  values = random_uniform(0.4,1.6,(/ndat,nrow,ncol/))

;---Ranges and colors for binning values
  ranges = ispan(6,14,1)*.1
  colors = (/"blue","royalblue3","steelblue","cyan","green",\
             "forestgreen","tan","orange","brown","red"/)

;---Labels for axes
  row_labels = (/"aa","bb","cc","dd","ee","ff","gg"/)
  col_labels = (/"AAA","BBB","CCC","DDD","EEE","FFF","GGG","HHH","III",\
                 "JJJ","KKK","LLL","MMM","NNN","OOO","PPP","QQQ","RRR",\
                 "SSS","TTT","UUU","VVV"/)

;---Start the graphics.
  wks = gsn_open_wks("png","table")  ; send graphics to PNG file

;---Create a blank plot so we can get some tickmarks.
  resb                         = True
  resb@gsnShape                = True

  resb@vpXF                    = 0.1
  resb@vpYF                    = 0.9
  resb@vpHeightF               = 0.70
  resb@vpWidthF                = 0.75

; Main title
  resb@tiMainString            = "Table of dummy data"

;---Remove bottom (and hence all) tickmarks
  resb@tmXBMajorOutwardLengthF = 0.
  resb@tmXBMajorLengthF        = 0.

  resb@tmXBMode                = "Explicit"
  resb@tmXBValues              = ispan(1,ncol,1)/(1.*ncol)-(1./ncol)/2.
  resb@tmXBLabels              = col_labels
  resb@tmXBLabelAngleF         = -90.
  resb@tmXBLabelJust           = "CenterLeft"
  resb@tmXBLabelFontHeightF    = 0.02

  resb@tmYLMode                = "Explicit"
  resb@tmYLValues              = ispan(1,nrow,1)/(1.*nrow)-(1./nrow)/2.
  resb@tmYLLabels              = row_labels

;---Create the blank plot
  plot = gsn_csm_blank_plot(wks,resb)

;---Add the triangles
  plot = add_triangles(wks,plot,values,ranges,colors)

;---Add the labelbars
  labels = "" + ranges
  add_labelbar(wks,plot,colors,labels)

;---Drawing the plot will draw labelbars and triangles
  draw(plot)

; Advance the frame.
  frame(wks)

end
