;======================================================================
; orca_2.ncl
;
; Concepts illustrated:
;   - Drawing cell-filled contours of ORCA data
;   - Turning on edges for cell-fill
;   - Turning on edges for missing cell-fill areas
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  orca = addfile("ctorca.nc","r")
  sst  = orca->sosstsst(0,:,:)
  lon  = orca->nav_lon
  lat  = orca->nav_lat

;
; Open PS workstation and change color map.
;
  wks = gsn_open_wks("png","orca")              ; send graphics to PNG file

  res                     = True
  res@gsnMaximize         = True     ; Maximize plot in frame

  res@trGridType          = "TriangularMesh"    ; Define the mesh type.

  res@sfXArray            = lon
  res@sfYArray            = lat
  res@sfMissingValueV     = sst@missing_value
  res@gsnAddCyclic        = False      ; don't add cyclic point

; Define colors for filled contours

  res@cnFillOn            = True
  res@cnFillPalette       = "gui_default"       ; set color map
;
; Use the "CellFill" method to fill the contours, and
; outline the cell edges.
;
  res@cnFillMode          = "CellFill"

  res@cnLinesOn           = False         ; Turn lines off
  res@cnLineLabelsOn      = False         ; Turn labels off

  res@tiMainString        = "Orca Grid"

  res@mpProjection          = "Orthographic"
  res@mpCenterLatF          =  50
  res@mpGridLineColor       =  -1       ; Turn off grid lat/lon lines
  res@mpGridAndLimbOn       =  True

  res@gsnCenterString       = "Cell fill"

  map = gsn_csm_contour_map(wks,sst,res)

;
; Turn on the cell edges and the missing value edges so we can see 
; an outline of the grid and the missing value areas.
;
  res@cnCellFillEdgeColor           = 1
  res@cnCellFillMissingValEdgeColor = "ForestGreen"
  res@gsnCenterString               = "Cell fill with cell edges on"

  map = gsn_csm_contour_map(wks,sst,res)

end
