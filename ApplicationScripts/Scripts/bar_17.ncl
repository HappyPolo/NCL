;----------------------------------------------------------------------
; bar_17.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Adding your own fill and lines to a bar chart
;   - Drawing an X reference line in a bar chart
;   - Filling bars in a bar plot based on an x reference line
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Add a various primitives to a bar chart, given an X reference line.
;----------------------------------------------------------------------
procedure customize_bar_chart(wks,plot,x,y,ref_line)
local xfill_lft, xfill_rgt, yfill_lft, yfill_rgt, npts, npts2_rgt, \
npts2_lft, npts2_rgt, i, gsres, ii_lft, ii_rgt,xmin,xmax,ymin,ymax
begin
  ADD_OUTLINE  = True
  ADD_FILL_LFT = True
  ADD_FILL_RGT = True
  ADD_REFLINE  = True

  getvalues plot
    "trXMinF" : xmin
    "trXMaxF" : xmax
    "trYMinF" : ymin
    "trYMaxF" : ymax
  end getvalues

  gsres = True     ; resource to hold various primitives

;----------------------------------------------------------------------
; Collect the points needed to fill in the bar chart area
; to the left of the given X reference line.
;----------------------------------------------------------------------
  if(ADD_FILL_LFT) then
    ii_lft = ind(x.le.ref_line)
    npts     = dimsizes(ii_lft)
    npts2_lft    = 2*npts
    xfill_lft = new(npts2_lft+3,typeof(x))
    yfill_lft = new(npts2_lft+3,typeof(y))

    do i=0,npts-1,1
      xfill_lft(2*i)   = x(ii_lft(i))
      yfill_lft(2*i)   = y(ii_lft(i))
      if(i.ne.(npts-1)) then
        xfill_lft(2*i+1) = x(ii_lft(i+1))
        yfill_lft(2*i+1) = y(ii_lft(i))
      else
        xfill_lft(2*i+1) = ref_line
        yfill_lft(2*i+1) = yfill_lft(2*i)
      end if
    end do

;---Be sure to close the polygon
    xfill_lft(npts2_lft)   = ref_line
    yfill_lft(npts2_lft)   = ymin
    xfill_lft(npts2_lft+1) = xmin
    yfill_lft(npts2_lft+1) = ymin
    xfill_lft(npts2_lft+2) = xmin
    yfill_lft(npts2_lft+2) = yfill_lft(0)

;---Add the filled left area to plot
    gsres@gsFillColor = "orange"
    str = unique_string("fill_lft")
    plot@$str$ = gsn_add_polygon(wks,plot,xfill_lft,yfill_lft,gsres)
  end if

;----------------------------------------------------------------------
; Collect the points needed to fill in the bar chart area
; to the right of the given X reference line.
;----------------------------------------------------------------------
  if(ADD_FILL_RGT) then
    ii_rgt = ind(x.ge.ref_line)
    npts     = dimsizes(ii_rgt)
    npts2_rgt    = 2*npts
    xfill_rgt = new(npts2_rgt+3,typeof(x))
    yfill_rgt = new(npts2_rgt+3,typeof(y))

    do i=0,npts-1,1
      xfill_rgt(2*i) = x(ii_rgt(i))
      yfill_rgt(2*i) = y(ii_rgt(i))
      if(i.ne.(npts-1)) then
        xfill_rgt(2*i+1) = x(ii_rgt(i+1))
        yfill_rgt(2*i+1) = y(ii_rgt(i))
      else
        xfill_rgt(2*i+1) = xmax
        yfill_rgt(2*i+1) = yfill_rgt(2*i)
      end if
    end do

;---Be sure to close the polygon
    xfill_rgt(npts2_rgt)   = xmax
    yfill_rgt(npts2_rgt)   = ymin
    xfill_rgt(npts2_rgt+1) = ref_line
    yfill_rgt(npts2_rgt+1) = ymin
    xfill_rgt(npts2_rgt+2) = ref_line
    yfill_rgt(npts2_rgt+2) = yfill_rgt(0)

;---Add the filled right area to plot
    gsres@gsFillColor = "lightblue"
    str = unique_string("fill_rgt")
    plot@$str$ = gsn_add_polygon(wks,plot,xfill_rgt,yfill_rgt,gsres)
  end if

;---Add the X reference line to plot
  if(ADD_REFLINE) then
    gsres@gsLineColor      = "NavyBlue"
    gsres@gsLineThicknessF = 3.0
    str = unique_string("line")
    plot@$str$ = gsn_add_polyline(wks,plot,(/ref_line,ref_line/),\
                                          (/ymin,ymax/),gsres)
  end if

;---Outline the bars
  if(ADD_OUTLINE) then
    gsres@gsLineColor      = "black"
    gsres@gsLineThicknessF = 3.0
    str = unique_string("outline_lft")
    plot@$str$ = gsn_add_polyline(wks,plot,xfill_lft(0:npts2_lft-1),\
                                        yfill_lft(0:npts2_lft-1),gsres)
    str = unique_string("outline_rgt")
    plot@$str$ = gsn_add_polyline(wks,plot,xfill_rgt(0:npts2_rgt-1),\
                                        yfill_rgt(0:npts2_rgt-1),gsres)
  end if
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Generate some dummy X,Y points
  x = ispan(-15,30,5)*1.
  y = (/0.03,0.05,.18,.35,.23,.1,.05,.04,.03,.02/)

  wks = gsn_open_wks("png","bar")  ; send graphics to PNG file

  res                   = True     ; Plot options desired
  res@gsnMaximize       = True     ; Maximize plot in frame
  res@gsnDraw           = False
  res@gsnFrame          = False

  res@gsnXYBarChart            = True      ; Create bar plot
  res@gsnXYBarChartOutlineOnly = True

  res@trXMinF           = min(x)
  res@trXMaxF           = max(x)
  res@trYMinF           = min(y)
  res@trYMaxF           = 0.4

  plot = gsn_csm_xy(wks,x,y,res)

  xref_line = 0.0
  customize_bar_chart(wks,plot,x,y,xref_line)

;---Drawing the plot will draw all the primitives that were attached.
  draw(plot)
  frame(wks)
end


