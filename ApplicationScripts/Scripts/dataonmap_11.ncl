;======================================================================
; dataonmap_11.ncl
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
  f   = addfile("ctorca.nc","r")
  sst = f->sosstsst(0,:,:)
  printVarSummary(sst)

  sst@lon2d = f->nav_lon
  sst@lat2d = f->nav_lat

  wks = gsn_open_wks("png","dataonmap")              ; send graphics to PNG file

  res                     = True
  res@gsnMaximize         = True     ; Maximize plot in frame

  res@gsnAddCyclic        = False

  res@cnFillOn            = True
  res@cnFillPalette       = "BlueYellowRed"       ; set color map

;---Use "CellFill" method to fill the contours outline the cell edges.
  res@cnFillMode          = "CellFill"

  res@cnLinesOn           = False         ; Turn lines off
  res@cnLineLabelsOn      = False         ; Turn labels off

  res@tiMainString        = "Orca grid -  " + sst@long_name + " (" + sst@units + ")"
  res@gsnRightString      = ""
  res@gsnLeftString       = ""

  res@mpProjection        = "Orthographic"
  res@mpCenterLatF        =  50
  res@mpPerimOn           = False

  map = gsn_csm_contour_map(wks,sst,res)

;
; Turn on the cell edges and the missing value edges so we can see 
; an outline of the grid and the missing value areas.
;
  res@cnCellFillEdgeColor           = "Black"
  res@cnCellFillMissingValEdgeColor = "ForestGreen"

  map = gsn_csm_contour_map(wks,sst,res)

end
