;*****************************************************
; nlom_4.ncl
;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*****************************************************
begin
;*****************************************************
; open file and read in data
;*****************************************************
  f1 = addfile("PV1TPMODGB12_HIN1993_19930415_IAS.nc","r")
  f2 = addfile("SSHTPMODGB12_HIN1993_19930415_IAS.nc","r")
  x    = f1->PV1TPMODGB12_HIN1993__from_NLOM
  cont = f2->SSHTPMODGB12_HIN1993__from_NLOM
  
  lat  = x&Latitude
  lon  = x&Longitude
;**************************************************
; assign required attributes
;**************************************************
  x&Longitude@units       = "degrees_east"
  x&Latitude@units        = "degrees_north"
  cont&Longitude@units    = "degrees_east"
  cont&Latitude@units     = "degrees_north"
;**************************************************
;   Create first plot (pv color fill contours)
;**************************************************
  wks  = gsn_open_wks("ps","nlom")                ; open ps file
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")       ; choose color map
  i = NhlNewColor(wks,0.8,0.8,0.8)                ; add gray to colormap
  
  res1                             = True          ; plot mods desired
  
  res1@cnFillOn                    = True          ; turn on color 
  res1@cnLinesOn                   = False         ; no contour lines
  res1@gsnAddCyclic                = False         ; regional data
  
  res1@cnMissingValFillColor       = "gray"        ; color missing values
  res1@cnMissingValFillPattern     = 0             ; make it a solid fill
  
  res1@cnLevelSelectionMode        = "ManualLevels"; set manual contour levels
  res1@cnMinLevelValF              = -1.5e-6       ; set min contour level
  res1@cnMaxLevelValF              =  1.5e-6       ; set max contour level

  
  res1@gsnSpreadColors             = True          ; use full color map
  res1@gsnSpreadColorEnd           = -3            ; don't use added gray
  res1@pmLabelBarOrthogonalPosF    = 0.06          ; move label bar down
  res1@lbLabelStride               = 4             ; label bar stride
  
;  res1@mpDataBaseVersion           = "MediumRes"  ; use finer database
  res1@mpDataBaseVersion           = "HighRes"     ; use finer database
  res1@mpOutlineOn                 = True          ; turn on cont. outlines
  
; create variables for map zoom, so we don't have to repeat changes
  minlat                           =  11.
  maxlat                           =  15.
  minlon                           = -67.
  maxlon                           = -60.

  res1@mpMinLatF                   = minlat
  res1@mpMaxLatF                   = maxlat
  res1@mpMinLonF                   = minlon
  res1@mpMaxLonF                   = maxlon
  
;titles
  res1@gsnLeftString               = "SSH over Potential Vorticity"
  res1@gsnRightString              = x@units       ; right string title
  res1@gsnMaximize                 = True          ; blow up plot
  
  res1@gsnDraw                     = False         ; don't draw yet
  res1@gsnFrame                    = False         ; don't advance frame yet

  plot1 = \
  gsn_csm_contour_map_ce(wks,x({minlat:maxlat},{360+minlon:360+maxlon}),res1)
;**************************************************
; Create second plot (ssh contours)
;**************************************************
  res2                            = True
  res2@gsnDraw                    = False
  res2@gsnFrame                   = False
  res2@cnInfoLabelOn              = False ; turn off info label
  res2@gsnLeftString              = "" ; turn off left string
  res2@gsnRightString             = ""
  plot2 = \
  gsn_csm_contour(wks,cont({minlat:maxlat},{360+minlon:360+maxlon}),res2)
  plot2 = ZeroNegDashLineContour(plot2)
  overlay(plot1,plot2)
  draw(plot1)
  frame(wks)
end





