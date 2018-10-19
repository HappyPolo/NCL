;----------------------------------------------------------------------
; compare_wind_fields.ncl
;
; Concepts illustrated:
;   - Plotting QuiskSCAT and COADS data
;   - Drawing wind stress fields and wind stress curl fields
;   - Drawing two labelbars dedicated to different nature of data 
;   - Masking data based on a mask array
;----------------------------------------------------------------------
; This script was contributed by Clement Vic, a PhD student at 
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

begin

	;=============== read data ==================================================
	t	= 6	; month (0:11)

	; ~~~ QuickSCOW ~~~
	finQ	= addfile("QuickSCOW.nc","r")  
	tauxQ	= finQ->sustr(t,:,:)
	tauyQ	= finQ->svstr(t,:,:)	

	rinQ	= addfile("QuickSCOW_curl.nc","r")
        rotQ    = rinQ->wind_curl_at_rho_pt(t,:,:)
	
        grdinQ  = addfile("grd.nc","r")
        lonuQ   = grdinQ->lon_u(:,:)
        latuQ   = grdinQ->lat_u(:,:)
        umskQ   = grdinQ->mask_u(:,:)
	lonvQ	= grdinQ->lon_v(:,:)
	latvQ	= grdinQ->lat_v(:,:)
	vmskQ	= grdinQ->mask_v(:,:)	
	lonrQ	= grdinQ->lon_rho(:,:)
	latrQ	= grdinQ->lat_rho(:,:)
	rmskQ	= grdinQ->mask_rho(:,:)

        ; ~~~ COADS ~~~
        finC    = addfile("COADS.nc","r")
        tauxC   = finC->sustr(t,:,:)
        tauyC   = finC->svstr(t,:,:)

        rinC    = addfile("COADS_curl.nc","r")
        rotC    = rinC->wind_curl_at_rho_pt(t,:,:)

        grdinC  = addfile("grd.nc","r")
        lonuC   = grdinC->lon_u(:,:)
        latuC   = grdinC->lat_u(:,:)
        umskC   = grdinC->mask_u(:,:)
        lonvC   = grdinC->lon_v(:,:)
        latvC   = grdinC->lat_v(:,:)
        vmskC   = grdinC->mask_v(:,:)
        lonrC   = grdinC->lon_rho(:,:)
        latrC   = grdinC->lat_rho(:,:)
        rmskC   = grdinC->mask_rho(:,:)


	;============== open pdf ====================================================
	wks	= gsn_open_wks("png","compare_wind_fields") ; send graphics to PNG file
	plot 	= new(6,graphic) 
	cmap = read_colormap_file("BkBlAqGrYeOrReViWh200")

	;============== miscellanous ~~~ data processing ============================
	;ncolors	= 256
	cmap = cmap(::-1,:) ; reverse color map

	tauxQ		= mask(tauxQ,umskQ.eq.0,False)
	tauxC		= mask(tauxC,umskC.eq.0,False)
	tauyQ		= mask(tauyQ,vmskQ.eq.0,False)
	tauyC		= mask(tauyC,vmskC.eq.0,False)
	rotQ		= mask(rotQ,rmskQ.eq.0,False)	
	rotC		= mask(rotC,rmskC.eq.0,False)	

	;============== define the contour resource =================================
	res                   		= True
	;-------------- general attributes ------------------------------------------
  	res@gsnFrame                 	= False                 	;do not open a new pdf page by default
  	res@gsnDraw                   	= False                        	
  	res@gsnAddCyclic              	= False                        	;regional/cyclic domain
  	res@gsnLeftString            	= ""                           	;titre gauche
  	res@gsnRightString           	= ""                           	;titre droit
  	res@gsnSpreadColors           	= True                     	;use full colormap
  	res@gsnSpreadColorStart       	= 2                            	;index of starting color (only if res@gsnSpreadColors=True)
  	res@gsnSpreadColorEnd         	= 201                          	;index of ending color (only if res@gsnSpreadColors=True)

  	;-------------- map attributes ----------------------------------------------
  	res@mpLimitMode               	= "LatLon"                      
  	res@mpMinLatF                 	= -7		
  	res@mpMaxLatF                 	= 28
  	res@mpMinLonF                 	= 38.3 
  	res@mpMaxLonF                 	= 77.7
  	res@mpFillOn                  	= True                         	;fill with continental background
        res@mpDataBaseVersion           = "MediumRes"                   ;dataset of political bdy
        res@mpOutlineBoundarySets       = "AllBoundaries"               ;political bdy
	res@mpOutlineOn               	= True                         	;draw coastlines
 	res@mpOutlineDrawOrder       	= "PostDraw"                   	;draw continental outline last
  	;res@mpGridAndLimbOn          	= True                         	;draw grid ...
  	;res@mpGridLineDashPattern    	= 2                            	;... with dashed lines
  	;res@mpGridLatSpacingF        	= 5                            	;space (in degree) between 2 lines
  	;res@mpGridLonSpacingF        	= 5                            	;idem
  	res@mpLabelFontHeightF        	= 0.015                        	;label font size 0.02

	;-------------- contours attributes -----------------------------------------
  	res@cnFillMode                	= "RasterFill"                 	;RasterFill, CellFill, AreaFill
  	res@cnLevelSelectionMode      	= "ManualLevels"               	;explicit selection of contours drawn
  	res@cnLevelSpacingF           	= 0.005	                      	;data space between colors used
  	res@cnMinLevelValF            	= -0.1;min(taux1)             	;minimal value drawn
  	res@cnMaxLevelValF            	= 0.25;max(taux1)          	;maximal value drawn
  	res@cnMissingValFillColor    	= newindex                   	;missingValue color (created in misc topic)
  	res@cnLinesOn                 	= False                         ;draw contour lines or not
  	res@cnFillOn                  	= True                          ;fill contours with colors
        res@cnFillPalette               = cmap(:199,:)                  ; set color map
	res@cnLineLabelsOn            	= False                      	;no values on contours

  	;-------------- scalars attributes -------------------------------------------
  	res@sfXArray                  	= lonuQ                          ;abscisses
  	res@sfYArray                  	= latuQ                          ;ordonnees
  	res@trGridType                	= "TriangularMesh" 	         

  	;-------------- label bar attributes -----------------------------------------
  	res@lbLabelBarOn              	= False                         ;turn off individual cb's in case of paneling
	res@lbBoxLinesOn		= False				;turn off bars between colors in the lb
        res@lbTitleString              	= "~F33~t~B~~F~zonal/meridional~N~ [N/m2~N~]"             ;legend title
        res@lbTitleFontHeightF         	= 0.02                          ;colorbar legend font size
        res@lbTitlePosition            	= "Top"                         ;colorbar legend location
        res@lbLabelStride              	= 10                            ;print 1 value out of lbLabelStride 
        res@lbLabelFontHeightF         	= 0.02                         	;colorbar indices size

  	;-------------- plot manager attributes --------------------------------------
  	res@pmLabelBarOrthogonalPosF  	= 0.14                      	;vertical relative position of cb, positive 
									;downward  (0.0 : figure bottom)
        res@pmLabelBarParallelPosF      = 0.                            ;horizontal relative pos of cb
  	res@pmLabelBarHeightF         	= 0.05                          ;cb's relative height
        res@pmLabelBarWidthF            = 0.6;0.8

  	;-------------- tickmarks attributes -----------------------------------------
  	;res@tmXBMode                  	= "Explicit"                    ;XB=abscisse bottom : mode de commande de la legende
  	;res@tmXBTickSpacingF          	= 5                             ;intervalle entre les ticks
  	;res@tmYLMode                  	= "Explicit"                    ;YL=ordonnees left : mode de commande de la legende
  	;res@tmYLTickSpacingF          	= 5                             ;intervalle entre les ticks
  	res@tmXBLabelFontHeightF      	= 0.015                         ;taille de police des lat et lon
  	res@tmYLLabelFontHeightF      	= 0.015

	;============== define the panel resource ====================================
	resP                          	= True                          ; modify the panel plot
  	resP@gsnMaximize              	= True
  	resP@gsnPanelLabelBar         	= False                        	; add common colorbar

	;============== draw contour =================================================

	;-------------- plot #1 ------------------------------------------------------
	res@tmXBLabelsOn        = False
	res@gsnLeftString      	= "(a) ~F33~t~B~~F~zonal~N~ / QuickSCOW"
	plottaux1		= gsn_csm_contour_map(wks,tauxQ,res)	;draw 'taux' on the workspace with the ressource 'res'
	plot(0)			= plottaux1

	;-------------- plot #2 ------------------------------------------------------
        res@tmXBLabelsOn        = True
	res@gsnLeftString       = "(b) ~F33~t~B~~F~zonal~N~ / COADS"
	plottaux2		= gsn_csm_contour_map(wks,tauxC,res)
	plot(3)			= plottaux2

	; ~~~~~~~~~~~~~ adapting resource res for the tauy plots ~~~~~~~~~~~~~~~~~~~~~
	delete(res@sfXArray)		; compulsory to delete because of dimensions assigned
	delete(res@sfYArray)
	res@sfXArray		= lonvQ
	res@sfYArray		= latvQ
        res@tmYLLabelsOn   	= False                    ;YL=ordonnees left : mode de commande de la legende
	res@tmXBLabelsOn	= False

	;-------------- plot #3 ------------------------------------------------------
        res@gsnLeftString       = "(c) ~F33~t~B~~F~meridional~N~ / QuickSCOW"
        plottauy1       	= gsn_csm_contour_map(wks,tauyQ,res)
        plot(1)         	= plottauy1

        ;-------------- plot #4 ------------------------------------------------------
        res@tmXBLabelsOn        = True
	res@lbLabelBarOn        = True 

        res@gsnLeftString       = "(d) ~F33~t~B~~F~meridional~N~ / COADS"
        plottauy2               = gsn_csm_contour_map(wks,tauyC,res)
        plot(4)                 = plottauy2


        ; ~~~~~~~~~~~~~ adapting resource res for the curl plots ~~~~~~~~~~~~~~~~~~~~~
        delete(res@sfXArray)            ; compulsory to delete because of dimensions assigned
        delete(res@sfYArray)
        res@sfXArray            = lonrQ
        res@sfYArray            = latrQ
	res@tmXBLabelsOn        = False
	res@lbLabelBarOn        = False
        delete(res@cnMinLevelValF)
        delete(res@cnMaxLevelValF)
        res@cnMinLevelValF     	= -0.000001 ;min(rot1)               ;minimal value drawn
        res@cnMaxLevelValF    	= 0.000001 ;max(rot1)                ;maximal value drawn
        res@cnLevelSpacingF    	= 0.00000005;0.00000002              ;data space between colors used
	res@lbLabelStride  	= 20 
	
        ;-------------- plot #5 ------------------------------------------------------
        res@gsnLeftString       = "(e) curl(~F33~t~F~) / QuickSCOW"
	plotrot1		= gsn_csm_contour_map(wks,rotQ,res)
        plot(2)                 = plotrot1

        ;-------------- plot #6 ------------------------------------------------------
        res@gsnLeftString       = "(f) curl(~F33~t~F~) / COADS"
        res@tmXBLabelsOn        = True
        res@lbLabelBarOn        = True
        res@pmLabelBarWidthF    = 0.6 ; MUST BE CHANGED MAYBE !!!
  	res@pmLabelBarParallelPosF  = 0.4;0.5
        res@lbTitleString   	= "curl(~F33~t~F~) [N/m3]"             ;titre de la legende
        plotrot2                = gsn_csm_contour_map(wks,rotC,res)
        plot(5)                 = plotrot2
	
	gsn_panel(wks,plot,(/2,3/),resP)
	frame(wks)                                                    	;open pdf page
end
