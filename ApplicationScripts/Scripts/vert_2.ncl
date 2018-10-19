;*********************************************
; vert_2.ncl
;*********************************************
; Concepts illustrated:
;   - Creating a vertical slice plot
;   - Converting sigma coorindates to pressure levels
;   - Linearizing the Y axis
;   - Reversing the Y axis
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*********************************************  
begin
;*************************************************
; read in data
;*************************************************
  in1 = addfile("temp.89335.1.nc","r")  
  t   = in1->temp(361,:,:,:)                           

  in2 = addfile("u.89335.1.nc","r")  
  u   = in2->u(361,:,:,:)           

  in3 = addfile("mix.89335.1.nc","r")  
  mix = in3->mix(361,:,:,:)           

  in4 = addfile("ps.89335.1.nc","r")  
  ps    = in4->ps(361,:,:)
  sigma = in4->sigma

;**************************************************
; take input data and calculate derived quantities
;**************************************************
  dims = dimsizes(u)
  nlev = dims(0)
  nlat = dims(1)
  nlon = dims(2)

  pres = new((/nlev,nlat,nlon /),float)  
  do k=0,nlev-1                                      ; calc press @ pt 
    pres(k,:,:) = ps*sigma(k)*100
  end do

  Rd      = 287            ; gas constant
  density = pres/(Rd*t)

  flux = density * u * mix
;***************************************************
; interpolate to pressure levels
;***************************************************
 plevs = (/1000,990,980,965,950,930,900,870,840,800,750,700,600,500,400,200/)
 fake = fspan(0.,0.,17)  ; create fake hyba array

 fluxp = vinth2p(flux,fake,sigma,plevs,ps*100,1,1000,1,True)

 plevs!0     = "plevs"
 plevs&plevs =  plevs

 fluxp!0     = "plevs"
 fluxp&plevs =  plevs
;***************************************************
;mask the pressure when below the surface pressure
;***************************************************
 do i=0,5
   fluxp(i,:,:) = mask(fluxp(i,:,:),(plevs(i).gt.ps),False)
 end do
 fluxp@long_name = "moisture flux"
;***************************************************
; some parameters
;***************************************************
 col    = 20
 rowmin = 20
 rowmax = 40

 f    = addfile ("header.nc", "r")
 LAT2D= f->lat
 lat2d=LAT2D(ycoord|:,xcoord|:)
;***************************************************
; create plot
;***************************************************
 wks  = gsn_open_wks ("png", "vert")           ; send graphics to PNG file
 cmap = read_colormap_file("ViBlGrWhYeOrRe")   ; read color map file

 res          = True

 res@cnFillOn              = True        ; color fill
 res@cnFillPalette         = cmap(1:,:)  ; set color map

 res@lbLabelStride         = 2           ; every other label bar label
 res@lbOrientation         = "Vertical"  ; vertical label bar

 res@cnLevelSelectionMode = "ManualLevels" ; manually set contour levels
 res@cnMinLevelValF       = -0.04          ; min level
 res@cnMaxLevelValF       =  0.04          ; max level

 res@cnInfoLabelOn        = False        ; no info label
 res@cnLinesOn            = False        ; no contour lines  

 res@tiXAxisString        = "Latitude"   ; some titles
 res@tiYAxisString        = "Pressure"
 res@tiMainString         = "Sigma ==> Pressure Levels"

 res@sfXArray              = lat2d(rowmin:rowmax,col) ; data for x-axis tm's
 res@sfYArray              = plevs                    ; data for y-axis tm's

;---These two resources reverse the Y axis and linearize it.
 res@trYReverse               = True
 res@gsnYAxisIrregular2Linear = True
 plot = gsn_csm_contour(wks,fluxp(:,col,rowmin:rowmax),res)   
end
