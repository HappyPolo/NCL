;----------------------------------------------------------------------
; unique_14.ncl
;
; Concepts illustrated:
;   - Superimposing quiver/filled contours
;   - Creating a quiver plot
;   - Using dash-dotted fill values for significativity information
;   - Enhancing the labelbar in a panel plot
;----------------------------------------------------------------------
; This script was contributed by Nicolas Barrier, a PhD student at 
; Laboratoire de Physique des Oceans, Brest (FRANCE)
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;----------------------------------------------------------------------

begin
                              
  fdata=addfile("data/composites.nc","r") 
  
  ; Loading data composites
  t=fdata->t
  u=fdata->u
  v=fdata->v

  ;Loading data t-test statistics
  st=fdata->st
  su=fdata->su
  sv=fdata->sv
 
  ;Loading landsea mask
  a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
  lsdata = a->LSMASK
  lsm  = landsea_mask(lsdata,u&lat,u&lon)
  lsmC=conform(t,lsm,(/1,2/)) ; conforms mask to data

  ;Mask land points
  t = mask(t,lsmC.ge.1,False)
  u = mask(u,lsmC.ge.1,False)
  v = mask(v,lsmC.ge.1,False)
  
  ;Mask non significant points
  t = mask(t,abs(st).le.coef,False)
  u = mask(u,abs(su).le.coef.and.abs(sv).le.coef,False)
  v = mask(v,abs(su).le.coef.and.abs(sv).le.coef,False)

  ;******************************************************************************************Drawing

  ;define names of the clusters
  clnames=(/"AR","BLK","NAO-","NAO+"/)
  
  ; create levels for air-temperature composites
  m=-3
  M=-m
  ecart=0.5
  n=floattointeger((M-m)/ecart)
  levels=fspan(m,M,n+1)
  
  ; open workspace
  wks=gsn_open_wks("png","unique")  ; send graphics to PNG file 

  ; define colormap
  cmap = read_colormap_file("amwg_blueyellowred")

  ; initialize panel
  plotF=new(4,graphic)

  ; --------------------------------------------------------------- res= resource contour plot
  res=True

  ;gsn resources
  res@gsnFrame=False
  res@gsnDraw = False
  res@gsnAddCyclic = False

  ;map resources
  res@mpLimitMode            = "LatLon" ; LatLon limit mode
  res@mpMinLatF=10 
  res@mpMaxLatF=80
  res@mpMinLonF=-80
  res@mpMaxLonF=20
  res@mpFillOn               = True ; filled map
  res@mpLandFillColor        = "gray70" ; gray continents
  res@mpOutlineOn            = True  ; continental lines
  res@mpOutlineDrawOrder     = "PostDraw" ; map postdrawn  
  res@mpGridAndLimbOn        =  True ; grid drawing
  res@mpGridLineDashPattern      = 2 ; dashed grid
  res@mpGridLatSpacingF = 10 ; grid spacing
  res@mpGridLonSpacingF = 10

  ;gsn resources
  res@gsnMajorLatSpacing=10 ; tick spacing
  res@gsnMajorLonSpacing=10
  
  ;cn resources
  res@cnFillOn            = True ; filled contours
  res@cnFillPalette       = cmap(1:14,:)      ; set color map
  res@cnLinesOn           = False ; no lines
  res@cnLineLabelsOn      = False  ; no labels
  res@cnLevelSelectionMode = "ExplicitLevels" ; explicit labels
  res@cnLevels=levels ; labels definition
  res@cnFillDrawOrder="PreDraw" ; contours are predrawn
  res@cnMissingValFillColor="gray70" ; filled values drawn in gray
  res@cnMissingValFillPattern=17 ; filled valyes are dotted
  res@cnFillBackgroundColor=-1 ; contour background color is transparent

  ;sf ressources
  res@sfXArray = u&lon ; x coordinates
  res@sfYArray = u&lat ; y coordinates
  
  ;lb ressources
  res@lbLabelBarOn = False ; no label bar
  
  ; --------------------------------------------------------------- resV= resource quiver plot

  resV=True

  ;gsn resources
  resV@gsnFrame=False
  resV@gsnDraw = False

  ;vf resources
  resV@vfXArray = u&lon ; arrows coordinates
  resV@vfYArray = u&lat 
  
  refmag = 5
  ;vc resources
  resV@vcRefMagnitudeF         = refmag      ; reference magnitude         
  resV@vcRefLengthF            = 0.050  ; reference length    
  resV@vcGlyphStyle            = "CurlyVector"  ; curly vectors
  resV@vcMinDistanceF          = 0.017  ; minimum distance
  resV@vcLineArrowThicknessF = 2 ;arrow thickness

  
  ; loop over number of clusters
  do indCl=0,3
    
    if(indCl.eq.0)
      ;vc ressources
      resV@vcRefAnnoString1 ="Wind anomalies~C~        ("+refmag +"m/s)" ; reference label
      resV@vcRefAnnoFontHeightF = 0.015 ; label size
      resV@vcRefAnnoOn=True ; turn label on
      resV@vcRefAnnoString2On = False ; turn default string off
      resV@vcRefAnnoOrthogonalPosF   = -0.29 ; label position
      resV@vcRefAnnoParallelPosF   = 0.97
      resV@vcRefAnnoPerimSpaceF=0.33 ; label box space 
      resV@vcRefAnnoArrowSpaceF=0.7
    end if
    
    if(indCl.ne.0) then
      resV@vcRefAnnoOn=False
    end if

    ; switches on/off xlabel-ylabel depending on the panel
    if(indCl.eq.0)  
      res@tmXBLabelsOn=False
      res@tmYLLabelsOn=True
    else if(indCl.eq.1) 
      res@tmXBLabelsOn=False
      res@tmYLLabelsOn=False     
    else if(indCl.eq.2) 
      res@tmXBLabelsOn=True
      res@tmYLLabelsOn=True
    else
      res@tmXBLabelsOn=True
      res@tmYLLabelsOn=False
    end if
    end if
    end if
    
    res@gsnCenterString=clnames(indCl) ; change title with cluster index
    plott= gsn_csm_contour_map(wks,t(indCl,:,:),res) ; contour drawing
    plotu = gsn_csm_vector(wks,u(indCl,:,:),v(indCl,:,:),resV) ; arrows drawing

    overlay(plott,plotu) ; overlaying
    
    plotF(indCl)=plott
    
  end do
  
  ; panel resources
  resP=True 
  resP@gsnPanelLabelBar = True                   ; add common colorbar
  resP@lbLabelStride=2 ;colorbar stride 
  resP@lbTitleString ="Air-temperature anomalies (K)" ;colorbar title
  resP@lbTitlePosition="Bottom" ; title position
  resP@lbLabelFontHeightF=0.013 ; label font height
  resP@lbTitleFontHeightF=0.013 ; title font height
  resP@pmLabelBarOrthogonalPosF=-0.0 ; label bar orth. position
  resP@gsnPanelYWhiteSpacePercent=7 ; panels height spacing

  gsn_panel(wks,plotF,(/2,2/),resP)  ; now draw as one plot
  
end
