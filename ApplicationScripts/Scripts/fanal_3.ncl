;----------------------------------------------------------------------
; fanal_3.ncl
;
; Concepts illustrated:
;   - Calculating wave information of a monthly climatology
;---------------------------------------------------------
; Calculate wave information of a monthly climatology
; .  Plot wave numbers 1, 2, 3
;---------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

  id = "./" 
  in = addfile(id+"ERAI.1989-2005.climo.subset.nc","r")  ; climatology: 1989-2005

  z  = in->Z300                               ; (time,lat,lon)  ; ( 12 ,121,240)

  dimz = dimsizes(z)
  nmos = dimz(0)
;****************************************
; Calculate amplitude of each harmonic
;****************************************
                                              ; reorder: ezfftf works on right dim
  CF = ezfftf (z)                             ; ezfftf works on right dim
  printVarSummary(CF)                         ; [2] x [12] x [121] x [120]

  cf = CF
  cf(:,:,:,1:)  = 0.0                         ; set waves 2 and higher to 0.0
  z_wave1 = ezfftb (cf, 0.0)                  ; [12] x [121] x [240]
  copy_VarMeta(z, z_wave1)                    ; [time | 12] x [lat | 121] x [lon | 240]

  cf = CF
  cf(:,:,:,0:0) = 0.0                         ; set wave 1 to 0.0
  cf(:,:,:,2: ) = 0.0                         ; set wave 3 and higher to 0.0
  z_wave2 = ezfftb (cf, 0.0)                  ; [12] x [121] x [240]
  copy_VarMeta(z, z_wave2)                    ; [time | 12] x [lat | 121] x [lon | 240]

  cf = CF
  cf(:,:,:,0:1) = 0.0                         ; set wave 1 and 2 to 0.0                  
  cf(:,:,:,3: ) = 0.0                         ; set wave 4 and higher to 0.0
  z_wave3 = ezfftb (cf, 0.0)                  ; [12] x [121] x [240]
  copy_VarMeta(z, z_wave3)                    ; [time | 12] x [lat | 121] x [lon | 240]

;****************************************
; Create plot
;****************************************
  month   = (/"January","Feb","Mar","Apr","May","Jun"\
             ,"July"   ,"Aug","Sep","Oct","Nov","Dec"/) 

  plot    = new (3,"graphic") 
 
  pltType = "png"                          ; send graphics to PNG file
  pltName = "fanal"
  wks     = gsn_open_wks(pltType, pltName)    
 
  res                      = True          ; individual plot
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@cnFillOn             = True          ; turn on color
  res@cnFillPalette        = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn            = False         ; turn on line labels
  res@cnLineLabelsOn       = False         ; turn on line labels
  res@lbOrientation        = "vertical"    ; vertical label bar

  resP                     = True          ; panel resources
 ;resP@gsnPaperOrientation = "portrait"
  resP@gsnMaximize         = True
 
  do nmo=0,nmos-1,6
     res@gsnLeftString     = "Wave 1"
     symMinMaxPlt (z_wave1(nmo,:,:),16,False,res)
     plot(0) = gsn_csm_contour_map(wks,z_wave1(nmo,:,:),res)
    
     res@gsnLeftString     = "Wave 2"
     symMinMaxPlt (z_wave2(nmo,:,:),16,False,res)
     plot(1) = gsn_csm_contour_map(wks,z_wave2(nmo,:,:),res)
    
     res@gsnLeftString     = "Wave 3"
     symMinMaxPlt (z_wave3(nmo,:,:),16,False,res)
     plot(2) = gsn_csm_contour_map(wks,z_wave3(nmo,:,:),res)
 
     resP@txString         = "ERA-Interim: 1989-2005: Z300: "+month(nmo)
     gsn_panel(wks,plot,(/3,1/),resP)
  end do
