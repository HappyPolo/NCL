;----------------------------------------------------------------------
; panel_29.ncl
;
; Concepts illustrated:
;   - Zooming in on Alaska region on a cylindrical equidistant map
;   - Using contour resource "cnFillPalette" to specify 2 colormaps
;   - Drawing panel plots with two color labelbars
;   - Retrieving contour resource values to create a labelbar
;   - Using mpFillColors to mask out ocean, etc. 
;   - Adding a common title to paneled plots
;   - Using new "reassignment operator" [ := ]: Version 6.1.2
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

;----------------------------------------------------------------------
;     Local function that extracts information from the
;     contour object attribute associated with the input plot. 
;     This makes the code a bit cleaner also.  
;----------------------------------------------------------------------
undef("createLabelBar")
function createLabelBar(wks: graphic, plt:graphic, lbres:logical)
begin
   getvalues plt@contour               ; object from which info extracted
      "cnFillColors"   : fill_colors   ; get the colors used
      "lbLabelStrings" : lbstrings     ; get the labels used
   end getvalues
   lbres@lbFillColors = fill_colors    ; associate with input lnres argument
   lbid = gsn_create_labelbar(wks,dimsizes(lbstrings)+1,lbstrings,lbres)
   return(lbid)
end

;============================================================================
;                        MAIN SCRIPT
;============================================================================

;****************************************************************************
; Generic/User info
;****************************************************************************

   var    = "txxETCCDI"         ; variable name
   model  = (/"MODEL_1","MODEL_2","MODEL_3","MODEL_4","MODEL_5","MODEL_6"/)

   pltDir = "./"                ; where output will be written
   pltName= "panel"                                   
   pltType= "png"               ; ps, eps, png, pdf, x11 .....

;****************************************************************************
; Miscellaneous 
;****************************************************************************
  nrow = dimsizes(model)
  ncol = 3                             ; fila, filb, filh

  print("nrow="+nrow)
  print("ncol="+ncol)

;****************************************************************************
; Data for future period for maximum daily temperature JJA
;****************************************************************************
   dira = "./"            
   keya = "AK_climdex_JJA_2040_2070"
   fila = systemfunc("cd "+dira+" ; ls "+keya+"*nc")
   print(fila)

;****************************************************************************
; Data for future period for maximum daily temperature for JJA
;****************************************************************************
   dirb = "./"             
   keyb = "AK_climdex_JJA_2070_2100"
   filb = systemfunc("cd "+dirb+" ; ls "+keyb+"*nc")
   print(filb)

;****************************************************************************
; Historical data for JJA
;****************************************************************************
   dirh = "./"       
   keyh = "ymf_AK_JJA_climdex_1970_2000"
   filh = systemfunc("cd "+dirh+" ; ls "+keyh+"*nc")
   print(filh)

;****************************************************************************
; Graphic resources
;****************************************************************************
  pltPath = pltDir+pltName
  wks     = gsn_open_wks(pltType ,pltPath) 

  res                       = True     ; plot mods desired
  res@gsnDraw               = False
  res@gsnFrame              = False
  res@gsnAddCyclic          = False    ; data is regional

  res@cnFillOn              = True     ; turn on color fill
  res@cnLinesOn             = False    ; turn of contour lines
  res@cnLineLabelsOn        = False    ; turn of contour line labels
  res@cnLevelSelectionMode  = "ManualLevels"    ; set manual contour levels

  res@lbLabelBarOn          = False

  res@mpMinLatF             =  55.     ; Alaska region
  res@mpMaxLatF             =  71.5
  res@mpMinLonF             = 191.
  res@mpMaxLonF             = 218.9    ; eastern Alaska boundary  
  res@mpCenterLonF          = 0.5*(res@mpMinLonF + res@mpMaxLonF)

  res@tmYLLabelsOn          = False    ; turn off lat labels
  res@tmXBLabelsOn          = False    ; turn off lon labels

  res@mpDataBaseVersion     = "MediumRes"
  res@mpFillOn              = True    
  res@mpOutlineOn           = True
  res@mpFillColors          = (/-1,0,-1,-1/)       ; mask out all non-land areas
  res@mpFillDrawOrder       = "PostDraw"
  res@mpOutlineBoundarySets = "USStates"           ; what outlines to use
  res@mpProjection          = "CylindricalEquidistant"

;****************************************************************************
; Set up labelbar resources for vertical and horizontal labelbars
; Some of these may change depending upon the nrow and ncols 
;****************************************************************************
  lbres                     = True                ; common resources for both
                                                  ; horizontal and vertical bars
  lbres@lbPerimOn           = False               ; no label bar box
  lbres@lbLabelFontHeightF  = 0.012               ; label font height
  lbres@lbLabelAlignment    = "InteriorEdges"     ; where to label
  lbres@lbMonoFillPattern   = True                ; solid fill

; Bottom Horizontal Label bar (Projection)
  lbhres                    = lbres
  lbhres@lbOrientation      = "Horizontal"        ; orientation
  lbhres@vpXF               = 0.18
  lbhres@vpYF               = 0.05
  lbhres@vpWidthF           = 0.40                ; size
  lbhres@vpHeightF          = 0.05

; Right Vertical Label bar (Hist)
  lbvres                    = lbres
  lbvres@lbOrientation      = "Vertical"          ; orientation
  lbvres@vpXF               = 0.85   
  lbvres@vpYF               = 0.75
  lbvres@vpWidthF           = 0.05                ; size
  lbvres@vpHeightF          = 0.5

;****************************************************************************
; Generate panel entries
;****************************************************************************
  nt   = 0                                     ; only one time per file
  plot = new(nrow*ncol , "graphic")
  nplt = -1
   
  do nr=0,nrow-1
     fa  = addfile(dira+fila(nr), "r")
     fb  = addfile(dirb+filb(nr), "r")
     fh  = addfile(dirh+filh(nr), "r")

    ;********************************
    ; Future Projection changes
    ;********************************
     res@cnFillPalette        = "WhiteYellowOrangeRed"
     res@cnMinLevelValF       =  0.0            ; set min contour level
     res@cnMaxLevelValF       = 12.0            ; set max contour level
     res@cnLevelSpacingF      =  1.0            ; set contour spacing

     x   := fa->$var$(nt,:,:)                     ; different dimensions
     res@gsnLeftString  = model(nr)
     res@gsnRightString = "Future A"
     nplt = nplt+1
     plot(nplt) = gsn_csm_contour_map(wks,x, res)

    ;********************************
    ; Horizontal labelbar: Extract info needed for horizontal labelbar
    ;********************************
     if (nplt.eq.0) then
         lbhid = createLabelBar(wks, plot, lbhres)
     end if
                                                  ; 2nd column
     x   := fb->$var$(nt,:,:)                     ; different dimensions
     res@gsnLeftString  = model(nr)
     res@gsnRightString = "Future B"
     nplt = nplt+1
     plot(nplt) = gsn_csm_contour_map(wks,x, res)

    ;********************************
    ; Hist (Rightmost column)
    ;********************************
     res@cnFillPalette        = "amwg256"
     res@cnMinLevelValF       =  0.0            ; set min contour level
     res@cnMaxLevelValF       = 26.0            ; set max contour level
     res@cnLevelSpacingF      =  1.0            ; set contour spacing

     x   := fh->$var$(nt,:,:)                   ; different dimensions
     res@gsnLeftString  = "Reference: "+model(nr)
     res@gsnRightString = "Base Period"
     nplt = nplt+1
     plot(nplt) = gsn_csm_contour_map(wks,x, res)
     
    ;********************************
    ; Vertical labelbar: Extract info needed for Hist (right) labelbar
    ;********************************
     if (nplt.eq.(ncol-1)) then                ; use last plot
         lbvid = createLabelBar(wks, plot, lbvres)
     end if

  end do         ; nrow

;****************************************************************************
; Draw the panel and label bars
;****************************************************************************
  resP = True
  resP@gsnPanelMainString = "Land Only: Tmax: 2 Colorbars"
  resP@gsnMaximize = True
  resP@gsnFrame    = False
 ;resP@gsnPanelRight  = 0.98
  resP@gsnPanelBottom = 0.045 

  gsn_panel(wks,plot,(/nrow,ncol/),resP)  ; plots

  draw(lbvid)                             ; vertical label bar
  draw(lbhid)                             ; horizontal label bar
  frame(wks)
