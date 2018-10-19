;----------------------------------------------------------------------
;  isolines_1.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using get_isolines to retrieve isolines from a contour plot
;   - Using "setvalues" to change the title of an existing plot
;   - Drawing polylines and polymarkers on a contour plot
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------

undef("add_isolines")
procedure add_isolines(wks,plot,min_level,max_level,color)
local isolines, nlist, gres, i, iso, count, j, ibeg, iend, x, y
begin
;
; Retrieve all isolines associated with this plot
; and print some information about them. Any
; levels falling between min_level and max_level
; will be highlighted in red.
;
  isolines = get_isolines(plot,"plot")
  nlist    = ListCount(isolines)    ; Each list item is one of the 
                                    ; contour levels
  gres                  = True
  gres@gsLineColor      = color
  gres@gsLineThicknessF = 4.0
  gres@gsMarkerIndex    = 16   ; filled dot
  do i = 0, nlist-1
    iso := isolines[i]
    count = 0
    print("==================================================")
    print("   Level " + iso@level + " has " + iso@segment_count + " segment(s)" )
    do j = 0, iso@segment_count -1
      ibeg = iso@start_point(j)
      iend = ibeg + iso@n_points(j) - 1
      y := iso(0,ibeg:iend)
      x := iso(1,ibeg:iend)
      if(min_level.le.iso@level.and.iso@level.le.max_level) then
        gsn_polyline(wks,plot,x,y,gres)
        gsn_polymarker(wks,plot,x,y,gres)
      end if
      count = count + iso@n_points(j)
    end do
    print("   ...with a total of " + count + " points.")
  end do
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Open file and read in data
  f    = addfile("cone.nc","r")
  u  = f->u(4,:,:)                

  wks = gsn_open_wks("png","isolines")

;---Create a basic line contour plot with a title
  res = True
  res@gsnMaximize    = True
  res@tiMainString   = "Original contour plot"
  res@gsnRightString = ""
  res@gsnLeftString  = ""
  res@tiXAxisString  = ""
  res@tiYAxisString  = ""
  plot = gsn_csm_contour(wks,u,res)

;---Change title of plot.
  min_level = 3.0
  max_level = 5.0
  color     = "red"
  setvalues plot
    "tiMainString" : "Levels >= " + min_level + " and <= " + \
                     max_level + " highlighted"
  end setvalues

;---Draw plot, add isolines of interest, and advance frame
  draw(plot)
  add_isolines(wks,plot,min_level,max_level,color)
  frame(wks)
end
