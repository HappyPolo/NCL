;----------------------------------------------------------------------
; text_17.ncl
;
; Concepts illustrated:
;   - Attaching text strings to a map
;   - Removing text strings that fall partially outside the map border
;   - Converting lat/lon values to NDC values
;   - Removing an annotation that has been attached to a plot
;   - Using "getvalues" to retrieve the size of a text string
;   - Using "setvalues" to change the main title of an existing plot
;   - Using "setvalues" to change the color of a text string
;   - Using functions for cleaner code
;   - Generating dummy lat/lon data using random_uniform
;   - Generating text strings using  random_uniform
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure removes all the text strings attached to the given
; map that fall partially outside the border, and then draws the
; plot again.
;----------------------------------------------------------------------
procedure remove_text_and_draw(wks,plot)
local anno_ids, tlat, tlon, vpx, vpy,vpw, vph, xndc, yndc, remove_ids, nrm
begin
  DRAW_BAD_TEXT = True   ; This is for debug purposes, so we can see
                         ; which strings are going to be removed.

;
; Get all the annotations attached to map. This will include all the 
; text strings, plus (potentially) other things like tickmarks and
; tickmark labels.
;
  getvalues plot
    "pmAnnoViews" : anno_ids
  end getvalues
  nannos = dimsizes(anno_ids)

;
; For each text string, get the four NDC corners. Then, use
; NhlNDCToData to convert these to lat/lon.
;
; If any of these lat/lon values are missing, then we know 
; the text box is at least partially outside the map.
;
  tlat = new(4,float)   ; (top left, top right, bottom right, bottom left)
  tlon = new(4,float)

  remove_ids = new(nannos,graphic)   ; Array to hold strings to be removed
  nrm        = 0
  do i=0,nannos-1
;
; Make sure this is a text annotation, and not something else 
; like tickmarks or tickmark labels.
;
    if(NhlClassName(anno_ids(i)).eq."textItemClass") then

;---Retrieve the text box location and size
      getvalues anno_ids(i)
        "vpXF"      : vpx
        "vpYF"      : vpy
        "vpWidthF"  : vpw
        "vpHeightF" : vph
      end getvalues

;---This is the box that encloses the text in NDC space.
      xndc = (/vpx, vpx+vpw, vpx+vpw, vpx/)
      yndc = (/vpy, vpy, vpy-vph, vpy-vph/)

;---Convert NDC box coordiates to lat/lon box coordinates.
      NhlNDCToData(plot,xndc,yndc,tlon,tlat)
;
; If any coordinates are missing, then flag this string to be removed.
; If desired, for debug purposes, draw text string in another color
; so you can see which ones will be removed.
;
      if(any(ismissing(tlon)).or.any(ismissing(tlat))) then
        remove_ids(nrm) = anno_ids(i)
        nrm = nrm+1

;---Change color of bad text
        if(DRAW_BAD_TEXT) then
          setvalues anno_ids(i)
            "txFontColor" : "red"
          end setvalues
        end if
      end if
    end if
  end do

  if(DRAW_BAD_TEXT) then
    setvalues plot
      "tiMainString" : "Map with bad text strings in red"
    end setvalues

;---Draw plot again. Bad strings will be in red.
    draw(plot)
    frame(wks)
  end if

;---Remove the bad strings
  NhlRemoveAnnotation(plot,remove_ids(0:nrm-1))

;---Change title
  setvalues plot
    "tiMainString" : "Map with bad text strings removed"
  end setvalues

;---Draw plot again. Bad strings will be gone.
  draw(plot)
  frame(wks)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
;---Generate random lat/lon locations and dummy text strings
  ntext = 200
  lons  = random_uniform(-180,180,ntext)
  lats  = random_uniform( -90, 90,ntext)
  text  = tostring(tochar(random_uniform(  65,122,(/ntext,5/))))

  wks = gsn_open_wks("png","text")    ; Open workstation for graphics

;---Resources for map
  res                = True
  res@gsnMaximize    = True
  res@gsnDraw        = False
  res@gsnFrame       = False
  res@gsnTickMarksOn = False
  res@mpPerimOn      = True
  res@tiMainString   = "Map with text strings extending beyond borders"

  plot = gsn_csm_map(wks,res)    ; Create the map, don't draw it yet.

;---Attach some dummy text strings
  txres               = True
  txres@txFontHeightF = 0.015
  txres@txJust        = "CenterLeft"

  text_id = gsn_add_text(wks,plot,text,lons,lats,txres)

;---Draw the map to see the text outside the borders
  draw(plot)
  frame(wks)

;---Remove the text that falls outside the plot borders
  remove_text_and_draw(wks,plot)

end
