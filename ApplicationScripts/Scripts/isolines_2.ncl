;----------------------------------------------------------------------
;  isolines_2.ncl
;----------------------------------------------------------------------
; This script will only work with a beta version of NCL 6.5.0.
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using get_isolines to retrieve isolines from a contour plot
;   - Attaching polylines to a map plot
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------

undef("add_isolines")
procedure add_isolines(wks,cplot,mplot)
local isolines, nlist, gres, i, iso, count, j, ibeg, iend, x, y
begin
;
; Retrieve all isolines associated with this plot
; and print some information about them. At
; the same time, draw them as polylines on the
; given map.
;
  if(isatt(cplot,"contour")) then
    isolines = get_isolines(cplot@contour,"plot")
  else
    isolines = get_isolines(cplot,"plot")
  end if
  nlist    = ListCount(isolines)    ; Each list item is one of the 
                                    ; contour levels
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
      mplot@$unique_string("line")$ = gsn_add_polyline(wks,mplot,x,y,False)
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
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")

;---read in zonal winds
  u = a->U(1,:,:)                                ; read July zonal winds

  wks = gsn_open_wks("png","isolines")

;---Create basic map plot with a title
  res = True
  res@gsnDraw        = False     ; will panel later
  res@gsnFrame       = False
  res@gsnRightString = ""
  res@gsnLeftString  = ""
  res@tiXAxisString  = ""
  res@tiYAxisString  = ""
  res@tiMainString   = "Map plot with isolines added"
  map_plot = gsn_csm_map(wks,res)

;---Create a basic line contour plot with a title
  res@cnInfoLabelOn  = False
  res@cnLineLabelsOn = False
  res@tiMainString   = "Original contour/map plot"
  contour_plot = gsn_csm_contour_map(wks,u,res)

;---Attach isolines to map plot
  add_isolines(wks,contour_plot,map_plot)

;---These two plots should be identical, except for the titles.
  pres = True
  pres@gsnMaximize = True
  gsn_panel(wks,(/contour_plot,map_plot/),(/2,1/),pres)
end
