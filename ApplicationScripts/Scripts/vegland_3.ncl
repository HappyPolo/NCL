;*************************************************
; vegland_3.ncl
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

begin
  region = "NE_China"
  latS   = 35.0      
  latN   = 55.0     
  lonL   = 110.0   
  lonR   = 135.0  

  diri   = "./"
  fili 	 = "MCD12C1.A2005001.051.2013164180706.hdf"  ; this is actually a hdf5 file
  f      = addfile (diri+fili+".he2", "r")           ; read as he2
  varhe  = "Majority_Land_Cover_Type_1_MOD12C1"

  info = (/                             \ ;Majority_Land_Cover_Type_1
        " 0 water"                     ,\ 
        " 1 evergreen_needleleaf"      ,\ ;_forest
        " 2 evergreen_broadleaf"       ,\ ;_forest     
        " 3 deciduous_needleleaf"      ,\ ;_forest
        " 4 deciduous_broadleaf"       ,\ ;_forest     
        " 5 mixed_forests"             ,\
        " 6 closed_shrubland"          ,\
        " 7 open_shrublands"           ,\
        " 8 woody_savannas"            ,\
        " 9 savannas"                  ,\
        " 10 grasslands"               ,\
        " 11 permanent_wetlands"       ,\
        " 12 croplands"                ,\
        " 13 urban_and_built_up"       ,\
        " 14 crop_nat_veg_mosaic"      ,\ ; cropland_natural_vegetation_mosaic
        " 15 snow_and_ice"             ,\
        " 16 barren_or_sparse"         ,\ ; barren_or_sparsely_vegetated       
        " 17 unclassified"             /)

  ninfo = dimsizes(info)        ; # of classifications

  xhe   = f->$varhe$({latS:latN},{lonL:lonR})
  printVarSummary(xhe)

;************************************************
; create plot
;************************************************
  pltType = "png"               ; ps, pdf, png, x11, eps
  sfx     = get_file_suffix(fili,0)

  pltDir  = "./"
 ;pltName = sfx@fBase+"."+region+"_majority"
  pltName = "vegland"
  pltPath = pltDir + pltName

  colorscheme = (/"cadetblue1", "darkgreen", "chartreuse", "olivedrab3","palegreen",\
		"darkseagreen","mediumpurple1","mistyrose","burlywood3","gold",\
		"tan1","royalblue","lightgoldenrod1","red","lightgoldenrod4","white",\
		"lightsteelblue","grey90"/) 

  ncolors = dimsizes(colorscheme)
  if (ninfo.ne.ncolors) then             ; make sure # of colors match categories (classes)
      print("size mismatch: ninfo="+ninfo+"   ncolors="+ncolors)
      exit
  end if

  wks = gsn_open_wks(pltType,pltPath)  

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True               ; ps, pdf 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill" 
  res@cnLinesOn        =  False             ; Turn off contour lines
  res@cnLevelSelectionMode = "ExplicitLevels" ; set explict contour levels
  res@cnLevels         = tobyte( ispan(1,ninfo-1,1) )
  res@cnFillPalette    = colorscheme        ; distinct colors for categories
  res@gsnSpreadColors  = False              ; use each color sequentially

  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(0,ninfo,1)  
  res@lbLabelStride    = 1
  res@lbLabelAutoStride = False 	    ; in V6.1.0 and up, this is defaulted
					    ; to True, and overrides lbLabelStride
					    ; default. Set this to ensure that 
					    ; your label scheme is preserved.
  res@pmLabelBarHeightF        =  0.075
  res@pmLabelBarWidthF         =  0.60      ; default is 0.6
  res@pmLabelBarOrthogonalPosF =  0.03; move up smidge

  res@mpFillOn         = False
  res@mpCenterLonF     = 0.5*(lonL+lonR)

  res@mpMinLatF  = latS     ; range to zoom in on
  res@mpMaxLatF  = latN
  res@mpMinLonF  = lonL
  res@mpMaxLonF  = lonR

  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpGridLineDashPattern = "2"

  res@gsnAddCyclic   = False             ; regional data   
  res@trGridType     = "TriangularMesh"
  res@tmXBLabelFontHeightF = 0.01        ; Make lon & lat text smaller
  res@tmYLLabelFontHeightF = res@tmXBLabelFontHeightF 

  res@tiMainString   = fili
  plot = gsn_csm_contour_map_ce(wks, xhe, res) ; create plot

  rtxt = True
  rtxt@txJust        = "TopLeft"
  rtxt@txFontHeightF = 0.0125

  res@vpHeightF      = 0.475
  res@vpWidthF       = 0.475

; Add text: rows x columns of text (arbitrary)
; Usually must play with xx, yy and txFontHeightF

  nrow = 4       ; # rows
  ncol = 5       ; # columns

  n  = -1        ; counter
  xx = 0.025     ; iterate to get right  
  do nc=0,ncol-1
     yy = 0.090   ; 0.065 
    do nr=0,nrow-1
       n = n+1
       if (n.le.(ninfo-1)) then    ; handle less than ninfo
           gsn_text_ndc (wks,info(n),xx,yy,rtxt)
           yy = yy - 2*rtxt@txFontHeightF
       end if
    end do
     xx = xx + 0.200    ; iterate to get right 
  end do
  draw(plot)
  frame(wks)

end

