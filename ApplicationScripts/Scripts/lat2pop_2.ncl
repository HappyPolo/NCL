;************************************************
; lat2pop_2.ncl
;   - Converting a lat/lon grid to a POP grid
;   - Drawing a perimeter around areas on a contour plot with missing data
;   - Adding shading or color fill to areas on a contour plot with missing data
;   - Drawing curly vectors
;   - Thinning vectors using a minimum distance resource
;   - Changing the magnitude of the vectors
;   - Changing the length of the smallest vector as a fraction of the reference vector
;
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
;************************************************
function msgValOutlineOrFill(wks:graphic,plot:graphic,data[*][*],\
         flag:logical,color:string)
begin
  ; this function is similiar to the shea_util function msgValOutline,
  ; except the user has the option to fill the missing values as well
  ; as draw the outline. 

; first draw a contour plot of the given data just to determine the number
; of contour levels
  cres                       = True
  cres@gsnDraw               = False
  cres@gsnFrame              = False

  cplot = gsn_contour(wks,data,cres)

  getvalues cplot
    "cnLevels" : levels
  end getvalues
  nlev    = dimsizes(levels)

; create an array of integer that is one larger than the number of levels
; and set that to -1 which mean no color.
  ncolors = new(nlev+1,integer)
  ncolors = -1

; set the contour resources
  cres                         = True    ; plot mods desired
  if(flag.eq.True)then
    cres@cnMissingValPerimOn     = True  ; turn on continental outlines
  end if
  cres@cnLinesOn               = False   ; don't draw contours
  cres@cnLineLabelsOn          = False   ; don't draw line labels
  cres@cnInfoLabelOn           = False   ; don't draw contour info label
 
  cres@cnFillOn                = True    ; turn on color fill 
  cres@cnFillColors            = ncolors ; use our array of "no color" to 
                                         ; fill the contours so we don't see
                                         ; them

  cres@cnMissingValFillPattern = "SolidFill" ; select solid
  cres@cnMissingValFillColor   = color       ; set color based on user input

  cplot = gsn_contour(wks,data,cres)      ; draw the contour plot
; create overlay of two plots
  overlay(plot,cplot)
  return(plot)
end
;********************************************
begin
  in = addfile("atmos.nc","r")
  u = in->U
  v = in->V
;************************************************
; convert t42 to POP
;************************************************
  remap   = PopLatLonV(u,v,"T42","gx1v3","bilin","da","010710")
  u_remap = remap(0,0,0,:,:)           ; (2,time,lev,lat,lon)
  v_remap = remap(1,0,0,:,:)
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("ps","lat2pop")             ; open ps file
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  i = NhlNewColor(wks,0.8,0.8,0.8)               ; will add gray to colormap

 
  res                       = True
  res@vcRefMagnitudeF       = 50.0               ; vec magnitude
  res@vcRefLengthF          = 0.060              ; size of ref vector
  res@vcMinDistanceF        = 0.007              ; thins arrows near pole 
  res@vcGlyphStyle          = "CurlyVector"      ; turn on curley vectors
  res@vcMinDistanceF        = 0.017              ; thin out vectors

  res@gsnDraw               = False              ; don't draw yet
  res@gsnFrame              = False              ; don't advance frame yet

  plot         = gsn_csm_vector(wks,u_remap,v_remap,res)
  plot         = msgValOutlineOrFill(wks,plot,u_remap,False,"gray")
  draw(plot)
  frame(wks)
end

