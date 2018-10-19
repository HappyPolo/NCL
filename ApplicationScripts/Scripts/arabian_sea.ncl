;----------------------------------------------------------------------
; arabian_sea.ncl
;
; Concepts illustrated:
;   - Drawing bathymetric features over a map of the Arabian Sea
;   - Drawing a schematic map 
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
	fin	= addfile("DATA/BLUF_grd.nc","r")
	lon	= fin->lon_rho(:,:)
	lat	= fin->lat_rho(:,:)
	topo	= fin->h(:,:)

	;============== open png ====================================================
	wks=gsn_open_wks("png","arabian_sea")

	;============== miscellanous ~~~ data processing ============================
	g		= 0.75
  	newindex	= NhlNewColor(wks,g,g,g)                     	;create a new color (gray here)
	g		= 0.6
	newindex2	= NhlNewColor(wks,g,g,g)
	
	;============== define the contour resource =================================
	res                   		= True
	;-------------- general attributes ------------------------------------------
  	res@gsnFrame                 	= False                 	;do not open a new pdf page by default
  	res@gsnDraw                   	= False                        	
  	res@gsnAddCyclic              	= False                        	;regional/cyclic domain
  	res@gsnLeftString            	= ""                           	
  	res@gsnRightString           	= ""                           
	res@gsnMaximize			= True
	res@tiMainFont			= 14
	res@tiMainPosition		= "Center"
	res@tiMainFontHeightF		= 0.012
	res@tiMainOffsetYF		= 0.03
	res@tiMainString		= "Arabian Sea and ASGP07a configuration domain"

  	;-------------- map attributes ----------------------------------------------
  	res@mpLimitMode               	= "LatLon"                      
  	res@mpMinLatF                 	= -15;-10
  	res@mpMaxLatF                 	= 31;28
  	res@mpMinLonF                 	= 32;38.3 
  	res@mpMaxLonF                 	= 85;77.7
  	res@mpFillOn                  	= True                         	;fill with continental background
	res@mpFillDrawOrder		= "PreDraw"
  	res@mpOutlineOn               	= True                         	;draw coastlines
 	res@mpOutlineDrawOrder       	= "PostDraw"                   	;draw continental outline last
       	res@mpDataBaseVersion 		= "MediumRes"			;dataset of political bdy
	res@mpOutlineBoundarySets	= "AllBoundaries"			;political bdy
  	res@mpGridAndLimbOn          	= True                         	;draw grid ...
  	res@mpGridLineDashPattern    	= 2                            	;... with dashed lines
	res@mpGridLineColor		= newindex2
  	res@mpGridLatSpacingF        	= 10                           	;space (in degree) between 2 lines
  	res@mpGridLonSpacingF        	= 10                           	;idem
  	res@mpLabelFontHeightF        	= 0.005                        	;label font size
	res@mpGeophysicalLineColor 	= "black"			; color of the continental outlines
	res@mpGeophysicalLineThicknessF = 1.5				; line size of the continental outlines
	
	;-------------- lines contours attributes ------------------------------------
	res@cnFillMode			= "AreaFill"
	res@cnLevelSelectionMode      	= "ManualLevels"
	res@cnLevelSpacingF           	= 1000
	res@cnMinLevelValF             	= 0 
	res@cnMaxLevelValF             	= 5000
	res@cnLineColor			= newindex
	res@cnLineLabelFontColor	= newindex 
	res@cnLinesOn                 	= True
	res@cnLineLabelsOn            	= True
	res@cnLineLabelFontHeightF    	= 0.005
	res@cnLineLabelDensityF       	= 1				; label spacing when cnLineLabelPlacementMode != "Constant"
	res@cnLineLabelFontAspectF   	= 1                       	;shape of the line label. > 1 :thinner characters. < 1 :wider
	res@cnLineLabelInterval       	= 1
	res@cnInfoLabelOn		= False				; turn off "CONTOUR FROM X TO X BY X" legend.
	;res@cnLineLabelPlacementMode  	= "Constant"			; "Constant", "Randomized" (default), "Computed"
	;res@cnLineDashSegLenF		= 1				; label spacing when cnLineLabelPlacementMode = "Constant"
	res@cnLabelMasking		= True				; mask lines where label appear

  	;-------------- scalars attributes -------------------------------------------
  	res@sfXArray                  	= lon                           ;abscisses
  	res@sfYArray                  	= lat                           ;ordonnees
  	res@trGridType                	= "TriangularMesh"            	
  	
  	;-------------- tickmarks attributes -----------------------------------------
  	res@tmXBMode                  	= "Explicit"                    ;XB=abscisse bottom : mode de commande de la legende
  	res@tmXBTickSpacingF          	= 10                           	;intervalle entre les ticks
  	res@tmYLMode                  	= "Explicit"                   	;YL=ordonnees left : mode de commande de la legende
  	res@tmYLTickSpacingF          	= 10                           	;intervalle entre les ticks
  	res@tmXBLabelFontHeightF      	= 0.005                        	;taille de police des lat et lon
  	res@tmYLLabelFontHeightF      	= 0.005

	;============== draw contour/contour lines ====================================
	plot				= gsn_csm_contour_map(wks,topo,res)	;draw 'topo' on the workspace with the ressource 'res'

        ;-------------- draw basic domain box -----------------------------------------
        ;ybox = (/ -10.0, -10.0, 28.0, 28.0, -10.0 /)
        ;xbox = (/  38.3,  77.6, 77.6, 38.3,  38.3 /)
        ;resbox                         	= True                      	; polyline mods desired
        ;resbox@gsLineColor             	= "red"                     	; color of lines
        ;resbox@gsLineThicknessF        	= 3.0                       	; thickness of lines
        ;resbox@gsLineLabelString       	= "ASGP07a"                 	; adds a line label string
	;resbox@gsLineLabelFontColor		= "red"
	;resbox@gsLineLabelConstantSpacingF 	= 0. 
        ;dum                           		= new(4,graphic)
        ;do i = 0 , 3
        ;        dum(i)=gsn_add_polyline(wks,plot,xbox(i:i+1),ybox(i:i+1),resbox)
        ;end do

        ;-------------- draw domain box with open/close bdy ----------------------------
        ybox = (/ -10.0, -10.0, -10.0,  8.0, 28.0, 28.0, -10.0 /)
        xbox = (/  38.3,  40.0,  77.6, 77.6, 77.6, 38.3,  38.3 /)
        resbox                                 	= True                          ; polyline mods desired
        resbox@gsLineColor                     	= "red"                         ; color of lines
        resbox@gsLineThicknessF                	= 3.0                           ; thickness of lines
        ;resbox@gsLineLabelString               = "Closed boundary"            ; adds a line label string
        resbox@gsLineLabelFontColor    		= "red"
        resbox@gsLineLabelConstantSpacingF 	= 0.
	resbox@gsFillBackgroundColor		= "black"
	resbox@txBackgroundFillColor		= "black"
	resbox@cnLineLabelDensityF         	= 0.1 
	resbox@cnLineLabelInterval         	= 10 
	
	restxt                          	= True
        restxt@txFontHeightF            	= 0.01
	restxt@txFontColor			= "red"
        restxt@txPerimOn               		= True
        restxt@txBackgroundFillColor   		= "white"

        dum                            		= new(7,graphic)

	; ~~~~~~ close bdy ~~~~~~
        do i = 0 , 0 
                dum(i)=gsn_add_polyline(wks,plot,xbox(i:i+1),ybox(i:i+1),resbox)
        end do
        do i = 3 , 5
                dum(i)=gsn_add_polyline(wks,plot,xbox(i:i+1),ybox(i:i+1),resbox)
        end do
	closebdy = gsn_add_text(wks,plot,"Closed boundaries",43.5,28.0,restxt)
	
	; ~~~~~~ open bdy ~~~~~~
	resbox@gsLineDashPattern		= 1
        ;resbox@gsLineLabelString                = "Open boundary"  
	do i = 1 , 2
                dum(i)=gsn_add_polyline(wks,plot,xbox(i:i+1),ybox(i:i+1),resbox)
        end do
        openbdy = gsn_add_text(wks,plot,"Open boundaries",70,-10,restxt)

        ;-------------- draw points, capes, straits, seas -------------------------------------------
	respt               		= True
	respt@gsMarkerColor		= "red"
  	respt@gsMarkerIndex 		= 16          			; Use filled dots for markers.
	respt@gsMarkerSizeF		= 0.010
	restxt@txFontColor             	= "black"
        restxt@txPerimOn              	= False	
        restxt@txBackgroundFillColor    = "transparent"
	; ~~~~~~ points ~~~~~~
	ypts = (/ 22.517, 	18.966,		11.84,	16.98 	/) 
	xpts = (/ 59.767, 	57.750,		51.26,	54.7 	/)	
	ytxt = (/ 22.5, 	19.5,		10.0,	17.5 	/)
	xtxt = (/ 56.0, 	54.0,		48.0,	51.5	/)
	labels = (/ "Ras al Hadd", "Ras Madraka", "   Cape~C~Guardafui", "Ras Marbat" /)
	points	= gsn_add_polymarker(wks,plot,xpts(:),ypts(:),respt)
	text	= gsn_add_text(wks,plot,labels(:),xtxt(:),ytxt(:),restxt)

		; ~~~ draw points outlines ~~~
		respt@gsMarkerIndex             = 4 				; hollow circle
		respt@gsMarkerColor             = "black"
		outlines = gsn_add_polymarker(wks,plot,xpts(:),ypts(:),respt)

	; ~~~~~~ straits ~~~~~~
	respt@gsMarkerColor             = "red"
        respt@gsMarkerIndex             = 7;11;3;12 					; star 5 points
	respt@gsMarkerSizeF             = 0.015
	ystrpts = (/ 12.58,	26.57 /)
	xstrpts = (/ 43.33,	56.25 /)
	ystrtxt = (/ 12.5,  27.0    /)
	xstrtxt = (/ 38.0,   62.0   /)
	strait = (/ "   Strait of~C~Bab el Mandeb", "Strait of Hormuz" /)
	straitpts = gsn_add_polymarker(wks,plot,xstrpts(:),ystrpts(:),respt)
	straittxt = gsn_add_text(wks,plot,strait(:),xstrtxt(:),ystrtxt(:),restxt)

	; ~~~~~~ seas and gulfs ~~~~~~
	restxt@txFont			= 14 ;22=helvetica_bold (normal : 21=helvetica)
	ysea = (/ 12.5,   19.0,	28,	24.0    /) ;27.0
	xsea = (/ 48.0,   39.4,	50.5,	62.0    /) ;50.0
	seas = (/ "Gulf of Aden", "Red~C~Sea", "Persian~C~ ~C~   Gulf", "Gulf of Oman" /)
	textsea = gsn_add_text(wks,plot,seas(:),xsea(:),ysea(:),restxt)

	; ~~~~~~ ridges and basins ~~~~~~
	;restxt@txAngleF			= -45
	restxt@txFontColor		= newindex2
	yrid = (/ 5,	17,	0,	7.5	/)		
	xrid = (/ 62,	65,	52,	73	/)
	rid  = (/ "Carlsberg~C~~C~      ridge", "Arabian~C~ basin", "Somali~C~ basin", " Chagos ~C~ ~C~Laccadive~C~ ~C~ plateau "   /)	
	textrid = gsn_add_text(wks,plot,rid(:),xrid(:),yrid(:),restxt)
	
	draw(plot)
        frame(wks) 	
end
