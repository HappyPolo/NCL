;----------------------------------------------------------------------
; bar_horz_17.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Adding your own fill and lines to a bar chart
;   - Drawing a Y reference line in a bar chart
;   - Filling bars in a bar plot based on a Y reference line
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Add a various primitives to a bar chart, given an X reference line.
;----------------------------------------------------------------------
procedure customize_bar_chart(wks,plot,x,y,ref_line)
local yfill_bot, yfill_top, yfill_bot, yfill_top, npts, npts2_top, \
npts2_bot, npts2_top, i, gsres, ii_bot, ii_top,xmin,xmax,ymin,ymax
begin
  ADD_OUTLINE  = True
  ADD_FILL_BOT = True
  ADD_FILL_TOP = True
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
; below the given Y reference line.
;----------------------------------------------------------------------
  if(ADD_FILL_BOT) then
    ii_bot = ind(y.le.ref_line)
    npts   = dimsizes(ii_bot)
    npts2_bot    = 2*npts
    xfill_bot = new(npts2_bot+3,typeof(x))
    yfill_bot = new(npts2_bot+3,typeof(y))

    do i=0,npts-1,1
      xfill_bot(2*i)   = x(ii_bot(i))
      yfill_bot(2*i)   = y(ii_bot(i))
      if(i.ne.(npts-1)) then
        xfill_bot(2*i+1) = x(ii_bot(i))
        yfill_bot(2*i+1) = y(ii_bot(i+1))
      else
        xfill_bot(2*i+1) = xfill_bot(2*i)
        yfill_bot(2*i+1) = ref_line
      end if
    end do

;---Be sure to close the polygon
    xfill_bot(npts2_bot)   = xmin
    yfill_bot(npts2_bot)   = ref_line
    xfill_bot(npts2_bot+1) = xmin
    yfill_bot(npts2_bot+1) = ymin
    xfill_bot(npts2_bot+2) = xfill_bot(0)
    yfill_bot(npts2_bot+2) = ymin

;---Add the filled left area to plot
    gsres@gsFillColor = "orange"
    str = unique_string("fill_bot")
    plot@$str$ = gsn_add_polygon(wks,plot,xfill_bot,yfill_bot,gsres)
  end if

;----------------------------------------------------------------------
; Collect the points needed to fill in the bar chart area
; to the right of the given X reference line.
;----------------------------------------------------------------------
  if(ADD_FILL_TOP) then
    ii_top = ind(y.ge.ref_line)
    npts     = dimsizes(ii_top)
    npts2_top    = 2*npts
    xfill_top = new(npts2_top+3,typeof(x))
    yfill_top = new(npts2_top+3,typeof(y))

    do i=0,npts-1,1
      xfill_top(2*i) = x(ii_top(i))
      yfill_top(2*i) = y(ii_top(i))
      if(i.ne.(npts-1)) then
        xfill_top(2*i+1) = x(ii_top(i))
        yfill_top(2*i+1) = y(ii_top(i+1))
      else
        xfill_top(2*i+1) = xfill_top(2*i)
        yfill_top(2*i+1) = ymax
      end if
    end do

;---Be sure to close the polygon
    xfill_top(npts2_top)   = xmin
    yfill_top(npts2_top)   = ymax
    xfill_top(npts2_top+1) = xmin
    yfill_top(npts2_top+1) = ref_line
    xfill_top(npts2_top+2) = xfill_top(0)
    yfill_top(npts2_top+2) = ref_line

;---Add the filled right area to plot
    gsres@gsFillColor = "lightblue"
    str = unique_string("fill_top")
    plot@$str$ = gsn_add_polygon(wks,plot,xfill_top,yfill_top,gsres)
  end if

;---Add the Y reference line to plot
  if(ADD_REFLINE) then
    gsres@gsLineColor      = "NavyBlue"
    gsres@gsLineThicknessF = 3.0
    str = unique_string("line")
    plot@$str$ = gsn_add_polyline(wks,plot,(/xmin,xmax/), \
                                  (/ref_line,ref_line/),gsres)
  end if

;---Outline the bars
  if(ADD_OUTLINE) then
    gsres@gsLineColor      = "black"
    gsres@gsLineThicknessF = 3.0
    str = unique_string("outline_bot")
    plot@$str$ = gsn_add_polyline(wks,plot,xfill_bot(0:npts2_bot-1),\
                                           yfill_bot(0:npts2_bot-1),gsres)
    str = unique_string("outline_top")
    plot@$str$ = gsn_add_polyline(wks,plot,xfill_top(0:npts2_top-1),\
                                           yfill_top(0:npts2_top-1),gsres)
  end if
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Generate some dummy X,Y points
  x = ispan(-15,30,5)*1.
  y = (/0.03,0.05,.18,.35,.23,.1,.05,.04,.03,.02/)
  y2 = (/0.03,0.025,.045,.18,.23,.1,.05,.04,.03,.02/)

  wks = gsn_open_wks("png","bar_horz")  ; send graphics to PNG file

  res                   = True     ; Plot options desired
  res@gsnMaximize       = True     ; Maximize plot in frame
  res@gsnDraw           = False
  res@gsnFrame          = False

  res@gsnXYBarChart            = True      ; Create bar plot
  res@gsnXYBarChartOutlineOnly = True
  res@gsnXRefLine              = min(y)

  res@trYMinF           = min(x)
  res@trYMaxF           = max(x)
  res@trXMinF           = min(y)
  res@trXMaxF           = 0.4

  plot = gsn_csm_xy(wks,y2,x,res)

  yref_line = 0.0
  customize_bar_chart(wks,plot,y,x,yref_line)

;---Drawing the plot will draw all the primitives that were attached.
  draw(plot)
  frame(wks)
end


