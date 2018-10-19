;***********************************************************************;
; This procedure draws or attaches markers or lines on the given plot
; at coordinates associated with the input data array. For the markers,
; you can have the markers colored according to where the data values
; are missing.  The arguments are:
; 
;    wks[1]:graphic 
;    plot[1]:graphic
;    data:numeric
;    res[1]:logical
;
; This procedure examines "data" to see if it has 1D coordinate 
; arrays, or the special "lat2d"/"lon2d" attributes. If it has
; neither, then the special "gsnCoordsX" and "gsnCoordsY" attributes
; must be attached to "res", indicating the coordinates. 
; If you are drawing lines, then these two attributes must be 2D
; and the same size as each other. If you are drawing markers,
; then these arrays don't have to be 2D, but they must be the
; same size. They will get converted to 1D arrays.
;
; By default, this procedure draws the plot, and the markers or 
; lines are drawn on the plot with gsn_polymarker[line], and
; the frame is advanced. Nothing is attached to the plot. This
; method is faster.
;
; If gsnCoordsAttach is set to True, then the markers or lines
; are attached using gsn_add_polymarker[line], and the plot is 
; not drawn and the frame is not advanced, unless gsnDraw[Frame]
; are set to True.
;
; If res@gsnCoordsX and res@gsnCoordsY are set, these will be used for the X
; and Y coordinate points.  Otherwise, this function will try to get
; the 1D coordinate information from the input data variable, or look
; for the special "lat2d", "lon2d" attributes.
; 
; Note that this function requires the X and Y coordinates to be set the
; same way. You can't set one via, say, an attribute, and the other via
; a coordinate array.
;
; Special coordinates recognized by this routine:
;
;    "gsnCoordsX" and "gsnCoordsY" - The X and Y coordinates to plot.
;       You only need to set these if the input data array 
;       doesn't have 1D coordinate arrays attached, or doesn't
;       have the special "lat2d", "lon2d" attributes.
;
;    "gsnCoordsAttach" - if True, then the markers will be
;       attached via gsn_add_polymarker, instead of just 
;       drawn with gsn_polymarker. Note that gsnDraw and Frame will
;       both be set to False in this case.
;
;    "gsnCoordsAsLines" - [not implemented yet] if True, 
;      coordinates will be drawn as lines rather than markers.
;      This only works for 2D coordinate arrays.
;
;    "gsnCoordsMissingColor"
;    "gsnCoordsNonMissingColor" - If either one of these are set,
;       then at locations where the data is or isn't missing, they
;       will be drawn in the given color
;
;***********************************************************************;
undef("gsn_coordinates")
procedure gsn_coordinates(wks[1]:graphic,plot[1]:graphic, \
                               data:numeric,res[1]:logical)
local type_xcoord, type_ycoord, pres, res2, pres, dims, rank, \
  dims_xcoord, dims_ycoord, xcoord_1d, ycoord_1d, xcoord_2d, ycoord_2d, \
  xdim, ydim, calldraw, callframe, maxbb, defclr, nonmsgclr, msgclr, \
  draw_lines, draw_non_msg, attach_coords, is_msgclr_trans, 
  is_nonmsgclr_trans, is_defclr_trans, tmpstr, i, imsg
begin
  res2 = res                     ; Make copy so we can modify it
  imsg = new(1,integer)

;---Check for special resources
  maxbb         = get_bb_res(res2)
  defclr        = get_res_value(res2,"gsMarkerColor",1)
  defmrk        = get_res_value(res2,"gsMarkerIndex",16)
  msgclr        = get_res_value(res2,"gsnCoordsMissingColor",imsg)
  nonmsgclr     = get_res_value(res2,"gsnCoordsNonMissingColor",imsg)
  attach_coords = get_res_value(res2,"gsnCoordsAttach",False)
  draw_lines    = get_res_value(res2,"gsnCoordsAsLines",False)

;---Check if color is transparent.
  is_defclr_trans    = ((typeof(defclr).eq."string".and. \
                         str_lower(defclr).eq."transparent").or. \
                        (typeof(defclr).eq."integer".and.defclr.eq.-1))
  is_msgclr_trans    = ((typeof(msgclr).eq."string".and. \
                         str_lower(msgclr).eq."transparent").or. \
                        (typeof(msgclr).eq."integer".and.msgclr.eq.-1))
  is_nonmsgclr_trans = ((typeof(nonmsgclr).eq."string".and. \
                         str_lower(nonmsgclr).eq."transparent").or. \
                        (typeof(nonmsgclr).eq."integer".and.nonmsgclr.eq.-1))

  if(attach_coords) then
    calldraw  = get_res_value(res2,"gsnDraw", False)
    callframe = get_res_value(res2,"gsnFrame",False)
  else
    calldraw  = get_res_value(res2,"gsnDraw", True)
    callframe = get_res_value(res2,"gsnFrame",True)
  end if
;
; Figure out what kind of X and Y coordinates we have.
; Valid kinds include:
;    gsnCoordsX or gsnCoordsY attributes attached to res ("res_coord").
;    1D coord array attached to data ("data_coord").
;    2D lat2d/lon2d attributes attached to data ("data_att")
; 
  type_xcoord = ""
  type_ycoord = ""
  dims        = dimsizes(data)
  rank       = dimsizes(dims)

;----------------------------------------------------------------------
; This section gets the X,Y coordinate arrays and converts them
; to 1D for markers, and 2D for lines.
;----------------------------------------------------------------------

  if(res2.and.isatt(res2,"gsnCoordsX").and.isatt(res2,"gsnCoordsY")) then
    type_xcoord = "res_coord"
    type_ycoord = "res_coord"
    if(draw_lines) then
      xcoord_2d = res2@gsnCoordsX
      ycoord_2d = res2@gsnCoordsY
    else
      xcoord_1d = ndtooned(res2@gsnCoordsX)
      ycoord_1d = ndtooned(res2@gsnCoordsY)
    end if
    delete(res2@gsnCoordsX)
    delete(res2@gsnCoordsY)
  end if

;---Check if "data" contains 1D coordinate arrays.
  xdim = rank-1
  ydim = rank-2
  if((type_xcoord.eq."".and.(isdimnamed(data,xdim).and. \
                             iscoord(data,data!xdim))).and.\
     (type_ycoord.eq."".and.(isdimnamed(data,ydim).and. \
                             iscoord(data,data!ydim)))) then
    type_xcoord = "data_coord"
    type_ycoord = "data_coord"
    dd          = (/dims(ydim),dims(xdim)/)
    if(draw_lines) then
      xcoord_2d = conform_dims(dd,data&$data!xdim$,1)
      ycoord_2d = conform_dims(dd,data&$data!ydim$,0)
    else
      xcoord_1d = ndtooned(conform_dims(dd,data&$data!xdim$,1))
      ycoord_1d = ndtooned(conform_dims(dd,data&$data!ydim$,0))
    end if
  end if

;---Check if "data" contains "lat2d", "lon2d" attributes
  if(type_xcoord.eq."".and.isatt(data,"lon2d")) then
    type_xcoord = "data_att"
    if(draw_lines) then
      xcoord_2d = data@lon2d
    else
      xcoord_1d = ndtooned(data@lon2d)
    end if
  end if
  if(type_ycoord.eq."".and.isatt(data,"lat2d")) then
    type_ycoord = "data_att"
    if(draw_lines) then
      ycoord_2d = data@lat2d
    else
      ycoord_1d = ndtooned(data@lat2d)
    end if
  end if

;---Error checking
  if(type_xcoord.eq."".or.type_ycoord.eq."") then
    print("gsn_coordinates: no valid X and/or Y coordinate values provided.")
    return
  end if
  if(type_xcoord.ne.type_ycoord) then
    print("gsn_coordinates: conflicting X/Y coordinate values provided.")
    return
  end if

  if(draw_lines) then
    dims_xcoord = dimsizes(xcoord_2d)
    dims_ycoord = dimsizes(ycoord_2d)
    rank_xcoord = dimsizes(dims_xcoord)
    rank_ycoord = dimsizes(dims_ycoord)
    if(rank_xcoord.ne.2.or.rank_xcoord.ne.rank_ycoord) then
      print("gsn_coordinates: can't draw coordinates as lines if they")
      print("                      are not 2D arrays of the same size.")
      return
    end if
    ny = dims_xcoord(0)
    nx = dims_xcoord(1)
    if(dims_ycoord(0).ne.ny.and.dims_ycoord(1).ne.nx) then
      print("gsn_coordinates: coordinates must have the same")
      print("                      dimensionality")
      return
    end if
  else
    dims_xcoord = dimsizes(xcoord_1d)
    dims_ycoord = dimsizes(ycoord_1d)
    if(dims_xcoord.ne.dims_ycoord) then
      print("gsn_coordinates: coordinates must have the same")
      print("                      dimensionality")
      return
    end if
  end if

;---Copy over resources if True
  if(res2) then
    pres = res2
  else
    pres = True
  end if

  if(.not.attach_coords.and.calldraw) then
    draw_and_frame(wks,plot,calldraw,False,False,maxbb)
  end if

;----------------------------------------------------------------------
; There are three ways the markers can get drawn:
;    - the markers in missing data locations
;    - the markers in non-missing data locations
;    - the markers at all locations.
;
; If a color is specified as -1 or "transparent", then don't
; waste time drawing the markers.
;
; If drawing lines, then you get all of them.
;----------------------------------------------------------------------
  if(draw_lines) then
    if(attach_coords) then
      do i=0,ny-1
        tmpstr = unique_string("xlines")
        plot@$tmpstr$ = gsn_add_polyline(wks,plot,xcoord_2d(i,:),\
                                                  ycoord_2d(i,:),pres)
      end do
      do i=0,nx-1
        tmpstr = unique_string("ylines")
        plot@$tmpstr$ = gsn_add_polyline(wks,plot,xcoord_2d(:,i),\
                                                  ycoord_2d(:,i),pres)
      end do
    else
      do i=0,ny-1
        gsn_polyline(wks,plot,xcoord_2d(i,:),\
                              ycoord_2d(i,:),pres)
      end do
      do i=0,nx-1
        gsn_polyline(wks,plot,xcoord_2d(:,i),\
                              ycoord_2d(:,i),pres)
      end do
    end if
  else
    if(.not.ismissing(msgclr).and..not.is_msgclr_trans) then
      pres@gsMarkerColor = msgclr
      pres@gsMarkerIndex = defmrk
      ii = ind(ismissing(ndtooned(data)))
      if(.not.all(ismissing(ii))) then
        if(attach_coords) then
          tmpstr = unique_string("markers_msg")
          plot@$tmpstr$ = gsn_add_polymarker(wks,plot,xcoord_1d(ii),\
                                             ycoord_1d(ii),pres)
        else
          gsn_polymarker(wks,plot,xcoord_1d(ii),ycoord_1d(ii),pres)
        end if
      end if
      delete(ii)
    end if
    draw_non_msg = False
;
; Somewhat complicated logic to determine whether we want to
; draw the markers at non-missing locations.
;
    if(.not.ismissing(msgclr).or..not.ismissing(nonmsgclr)) then
      if(.not.is_nonmsgclr_trans) then
        if(isatt(pres,"gsMarkerColor")) then
          delete(pres@gsMarkerColor)
        end if
        pres@gsMarkerColor = nonmsgclr
        pres@gsMarkerIndex = defmrk
        draw_non_msg       = True
      else
        if(ismissing(nonmsgclr).and..not.is_defclr_trans) then
          if(isatt(pres,"gsMarkerColor")) then
            delete(pres@gsMarkerColor)
          end if
          pres@gsMarkerColor = defclr
          pres@gsMarkerIndex = defmrk
          draw_non_msg       = True
        end if
      end if
      if(draw_non_msg) then
        ii = ind(.not.ismissing(ndtooned(data)))
        if(.not.all(ismissing(ii))) then
          if(attach_coords) then
            tmpstr = unique_string("markers_nonmsg")
            plot@$tmpstr$ = gsn_add_polymarker(wks,plot,xcoord_1d(ii),\
                                               ycoord_1d(ii),pres)
          else
            gsn_polymarker(wks,plot,xcoord_1d(ii),ycoord_1d(ii),pres)
         end if
       end if
        delete(ii)
      end if
     end if

    if(ismissing(msgclr).and.ismissing(nonmsgclr).and. \
       .not.is_defclr_trans) then
      pres@gsMarkerColor = defclr
      pres@gsMarkerIndex = defmrk
      if(attach_coords) then
        tmpstr = unique_string("markers_all")
        plot@$tmpstr$ = gsn_add_polymarker(wks,plot,xcoord_1d,\
                                           ycoord_1d,pres)
      else
        gsn_polymarker(wks,plot,xcoord_1d,ycoord_1d,pres)
      end if
    end if

  end if  ; draw_lines
  if(attach_coords) then
    draw_and_frame(wks,plot,calldraw,callframe,False,maxbb)
  else
    if(callframe) then
      frame(wks)
    end if
  end if
end
