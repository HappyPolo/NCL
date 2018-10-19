;----------------------------------------------------------------------
; stream_6.ncl 
;
; Concepts illustrated:
;   - Drawing streamlines over filled contours on a map
;   - Adding more arrows to streamlines
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  f = addfile("uvt.nc","r")
  u    = f->U(0,0,:,:)    ; read in example data [2D only here]
  v    = f->V(0,0,:,:)

  f2 = addfile("sst8292.nc","r")
  sst = f2->SST           ; read in sst data

;---create plots
  wks  = gsn_open_wks("png","stream")           ; send graphics to PNG file
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")  ; choose color map

  res                      = True               ; plot mods desired
  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnSpreadColorStart  = 17                 ; start at color 17
  res@gsnSpreadColorEnd    = 200                ; end at color 200

  res@mpLandFillColor       = "gray"            ; set land to be gray

  res@mpMinLonF            =  65.               ; select a subregion
  res@mpMaxLonF            =  95.
  res@mpMinLatF            =   5. 
  res@mpMaxLatF            =  25.

  res@lbOrientation            = "Vertical"     ; vertical label bar
  res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
  res@lbLabelStride            = 4

; note, when doing a subregion, NCL determines the range of the data from
; the full domain. If you wish to just consider the domain you are plotting,
; you must manually set those levels.

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 24.0               ; set min contour level
  res@cnMaxLevelValF       = 29                 ; set max contour level
  res@cnLevelSpacingF      = 0.10               ; set contour spacing

  res@stArrowLengthF     = 0.015            ; changes the size of the arrows.
  res@stArrowStride      = 1                        ; arrows start every third

  plot = gsn_csm_streamline_contour_map_ce(wks,u,v,sst(0,:,:),res)
end

