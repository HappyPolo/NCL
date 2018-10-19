;----------------------------------------------------------------------
; hdf5_1.ncl
;
; Concepts illustrated:
;   - Reading group data off an HDF5 file using two methods
;   - Creating a color map using RGB triplets
;   - Drawing raster contours for faster results
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;----------------------------------------------------------------------

begin
;---It is necessary to use advanced file structure to read group data
 setfileoption("nc", "FileStructure", "Advanced")
 fname = "MSG3-SEVI-MSG15-0100-NA-20130521001244.164000000Z-1074164.h5"
 f     = addfile(fname,"r")

;------------------------------------------------------------
; There are two ways to read variables off a files
; containing nested groups.
;
; Method 1: 
;     - Open the group with the "=>" syntax
;     - Read the data using the usual "->" syntax
;
; Method 2:
;     - Open the variable directly using the full path 
;       to the file
;
; Note: there's an inconsistency with how the group names
; are constructed for the two methods. We have opened a
; trouble ticket for this.
;------------------------------------------------------------

  USE_FULL_PATH = True

  if(.not.USE_FULL_PATH) then
;---First method; open group, then read data from it.
    group_name  ="/U_MARF/MSG/Level1_5/DATA/Channel_07"
    iname      = "IMAGE_DATA"
    pname      = "Palette"
    gp         = f=>$group_name$
    fdata      = tofloat(gp->$iname$)
    palette    = tofloat(gp->$pname$)
  else
;---Second method; use full path to variable.
   group_name = "/U-MARF/MSG/Level1.5/DATA/Channel 07"
   iname      = group_name + "/IMAGE_DATA"
   pname      = group_name + "/Palette"
   fdata      = tofloat(f->$iname$)
   palette    = tofloat(f->$pname$)
  end if

  wks = gsn_open_wks("png","hdf5")              ; send graphics to PNG file

  res                      = True               ; plot mods desired
  res@gsnMaximize          = True               ; maximize plot in frame

  res@cnFillOn             = True               ; color fill 
  res@cnFillMode           = "RasterFill"       ; Raster mode is much faster
                                                ; and uses less memory.
  res@cnFillPalette        = palette/255.
  res@cnLinesOn            =  False             ; turn off contour lines

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = min(fdata)         ; set min contour level
  res@cnMaxLevelValF       = max(fdata)         ; set max contour level
  res@cnLevelSpacingF      =  10.0              ; set contour spacing

  res@lbOrientation        = "vertical"         ; vertical labelbar
  res@lbBoxLinesOn         = False
  res@gsnTickMarksOn       = False

  if(USE_FULL_PATH)
    res@tiMainString = "Variable read using full group path"
  else
    res@tiMainString = "Variable read by opening group first"
  end if

  plot = gsn_csm_contour(wks,fdata, res) ; create plot
end
