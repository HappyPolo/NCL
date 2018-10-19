;============================================================
; pdf_6.ncl
;
; Concepts illustrated:
;   - Using functions for cleaner code
;   - Using coordinate subscripting to read a specified geographical region
;   - Using "RasterFill" contour mode for better delineation of data
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   

;============================================================
;        Utility Function: Cleaner code 
;============================================================
function getVarFreq (f:list, varName[1]:string, frqName[1]:string)
; [ncl_join|3] x [time|1] x [lev|30] x [lat|96] x [lon|144]
begin
         ; [ncl_join|3] x [lev|30] x [lat|96] x [lon|144]
  x      = f[:]->$varName$(:,0,:,:,:)  
  freq   = f[:]->$frqName$(:,0,:,:,:)    ; Fractional occurance 

  freq@_FillValue = 0.0   ; avoid dividing by 0.0
  
  x      = x/freq
  x!0    = "season"       ; DJF(0), JJA(1), ANN(2)

  x@_FillValue = 1e20     ; more conventional _FillValue
  x@varName    = varName  ; may be used in plotting
  x@frqName    = frqName 
  return(x)
end

;============================================================
;                      MAIN
;============================================================
begin                     
  diri     = "./"                         ; file input directory
                                          ; [0=DJF, 1=JJA, 2=ANN]
  fils     = (/"CLOUD.DJF.nc","CLOUD.JJA.nc","CLOUD.ANN.nc"/) 

  pltDir   = "./"                         ; where graphical output sent
  pltType  = "png"                        ; send graphics to PNG file
  pltName  = "pdf"                        ; root name ( CLOUD_JOINT )

  f      = addfiles ( diri+fils, "r")     ; [0=DJF, 1=JJA, 2=ANN]
  nSea   = dimsizes(fils)                 ; one "season" per file

  ListSetType (f, "join") ; like ncecat
                                          ; All the following divided by FREQ{L/I}
  awnc   = getVarFreq(f, "AWNC", "FREQL") ; Average in-cloud water number conc
  arel   = getVarFreq(f, "AREL", "FREQL") ; Average droplet effective radius

  awnc   = awnc/1e7                       ; scale for graphical reasons

;*************************************************************
; Off the coast of S. America at low altitudes (Liquid):  
;     15-30S, 75-90W, 1000-700 hPa
;*************************************************************

  latS   = -30         ; 30S
  latN   = -15         ; 15S
  lonL   = 270         ; 90W
  lonR   = 285         ; 75W
  pLo    = 1000        ; use model nominal pressure levels
  pHi    =  700

;*************************************************************
; Bivariate (Joint) PDFs
; Use coordinate subscripting to select data
;*************************************************************

  pdf2_djf = pdfxy(awnc(0,{pHi:pLo},{latS:latN},{lonL:lonR}) \
                  ,arel(0,{pHi:pLo},{latS:latN},{lonL:lonR}) ,0,0,False)
  pdf2_jja = pdfxy(awnc(1,{pHi:pLo},{latS:latN},{lonL:lonR}) \
                  ,arel(1,{pHi:pLo},{latS:latN},{lonL:lonR}) ,0,0,False)
  pdf2_ann = pdfxy(awnc(2,{pHi:pLo},{latS:latN},{lonL:lonR}) \
                  ,arel(2,{pHi:pLo},{latS:latN},{lonL:lonR}) ,0,0,False)

;*************************************************************
; Set all pdf2=0.0 to _FillValue 
; Better illustrates actual data distribution
;*************************************************************

  pdf2_djf = where(pdf2_djf.eq.0, pdf2_djf@_FillValue, pdf2_djf)
  pdf2_jja = where(pdf2_jja.eq.0, pdf2_jja@_FillValue, pdf2_jja)
  pdf2_ann = where(pdf2_ann.eq.0, pdf2_ann@_FillValue, pdf2_ann)

;*************************************************************
; plots
;*************************************************************
  seaName  = (/"DJF" , "JJA" , "ANN" /) 
  nSea     = dimsizes(seaName)

  title    = "SA: "+abs(latS)+"S-"+abs(latN)+"S: " \
                   +abs(lonL)+"W-"+abs(lonR)+"W: "+pLo+"-"+pHi

  plot   = new ( nSea, "graphic")

  wks    = gsn_open_wks(pltType, pltName)

  res    = True
  res@gsnDraw              = False    ; do not draw picture
  res@gsnFrame             = False    ; do not advance frame
  res@cnFillOn             = True     ; turn on color fill
  res@cnFillPalette        = "amwg"   ; set color map
  res@cnFillMode           = "RasterFill"       ; Raster Mode
  res@cnLinesOn            = False    ; no contour lines
  res@cnLineLabelsOn       = False    ; no contour line labels
  res@cnInfoLabelOn        = False
 ;res@cnLabelBarEndStyle   = "ExcludeOuterBoxes"
  res@tiXAxisString        = awnc@varName
  res@tiYAxisString        = arel@varName
  res@tiXAxisOffsetYF      = 0.105

  res@gsnCenterString      = "DJF"
  plot(0) = gsn_csm_contour (wks, pdf2_djf, res)

  res@gsnCenterString      = "JJA"
  plot(1) = gsn_csm_contour (wks, pdf2_jja, res)

  res@gsnCenterString      = "ANN"
  plot(2) = gsn_csm_contour (wks, pdf2_ann, res)

  resP                     = True                ; modify the panel plot
  resP@txString            = title
  resP@gsnPanelRowSpec = True                   ; tell panel what order to plt
  gsn_panel(wks,plot,(/2,1/),resP)

;*************************************************************
; Use "plt_pdfxy" to plot
;*************************************************************

  res@gsnCenterString      = "DJF (plt_pdfxy)"
  plot(0) = plt_pdfxy (wks, pdf2_djf, res)

  res@gsnCenterString      = "JJA (plt_pdfxy)"
  plot(1) = plt_pdfxy (wks, pdf2_jja, res)

  res@gsnCenterString      = "ANN (plt_pdfxy)"
  plot(2) = plt_pdfxy (wks, pdf2_ann, res)

  resP                     = True                ; modify the panel plot
  resP@txString            = title
  resP@gsnPanelRowSpec = True                   ; tell panel what order to plt
  gsn_panel(wks,plot,(/2,1/),resP)

end                 
