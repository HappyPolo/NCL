;--------------------------------------------------
; unique_12.ncl
;
; Concepts illustrated:
;   - Drawing a map and an XY plot on the same page.
;   - Plotting a PIREP/METAR/RAOB combo
;   - Reading data from several ASCII files
;   - Using str_get_field to parse data in an ASCII file
;   - Attaching markers, text, and polylines to a map
;   - Attaching a legend to a plot
;   - Creating your own markers for an XY plot
;   - Drawing counties in the United States
;   - Manually creating a legend using markers and text
;   - Using command line options to set variables
;--------------------------------------------------
; Original File: plot_combo.ncl
;
; Author: D. Adriaansen
;
; Date: 12 October 2011
;
; Purpose: Plot a PIREP/METAR/RAOB combo for visualization
;
; Usage: ncl unique_12.ncl 'yyyymmdd="YYYYMMDD"' 'hr="HH"'
;
; Notes:
;________________________________________________________________________

; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; Input files
m_in = yyyymmdd+hr+"_metar.txt"
p_in = yyyymmdd+hr+"_pirep.txt"
r_in = yyyymmdd+hr+"_sites.txt"

; Check to make sure input files exist
if .not.isfilepresent(m_in) then
  print("METAR File missing.")
end if
if .not.isfilepresent(p_in) then
  print("PIREP File missing.")
end if
if .not.isfilepresent(r_in) then
  print("RAOB File missing.")
end if
if .not.isfilepresent(m_in) .or. .not.isfilepresent(p_in) .or. .not.isfilepresent(r_in) then
  print("Exiting...")
  exit()
end if

; Output directory
outdir = "./"

; Resources for the map plot
res                                           = True
res@mpProjection                              = "LambertConformal"
res@mpLambertMeridianF                        = 265
res@mpLambertParallel1F                       = 25
res@mpLambertParallel2F                       = 25
res@mpLimitMode                               = "Corners"
res@mpFillOn                                  = True
res@mpPerimOn                                 = True
res@mpDataBaseVersion                         = "MediumRes"
res@mpOutlineBoundarySets                     = "AllBoundaries"
res@mpDataSetName                             = "Earth..2"
res@mpInlandWaterFillColor                    = 70
res@mpOceanFillColor                          = 70
res@mpLandFillColor                           = "white"
res@mpOutlineOn                               = True

res@gsnDraw                                   = False
res@gsnFrame                                  = False

; Resources for the polymarkers on the map plot
mkres                                         = True

; Resources for the text displaying "INT" on the sonde plot
txres                                         = True
txres@txFontHeightF                           = 0.014
txres@txFontColor			      = "black"

; Resources for the "TOP" and "BOT" line labels on the sonde plot
txres2 					      = True
txres2@txFontHeightF 			      = 0.009
txres2@txFontColor	                      = "black"

; Resources for the "TOP" and "BOT" lines
lres                  = True
lres@gsLineThicknessF = 2.5
lres@gsLineColor      = "black"

; Read in the data
pdata = asciiread(p_in,-1,"string")
mdata = asciiread(m_in,-1,"string")
rdata = asciiread(r_in,-1,"string")

; Store individual variables
plat = tofloat(str_get_field(pdata,4," "))
plon = tofloat(str_get_field(pdata,5," "))
pid  = toint(str_get_field(pdata,1," "))
int  = str_get_field(pdata,20," ")
top  = str_get_field(pdata,19," ")
bot  = str_get_field(pdata,18," ")
mlat = tofloat(str_get_field(mdata,8," "))
mlon = tofloat(str_get_field(mdata,9," "))
mid  = toint(str_get_field(mdata,1," "))
slat = tofloat(str_get_field(rdata,3," "))
slon = tofloat(str_get_field(rdata,4," "))
sid  = toint(str_get_field(rdata,1," "))
sname = str_get_field(rdata,2," ")

; Loop over every ID and plot the RAOB location, and any METARs and PIREPs.
; Also open sounding file and create RAOB plot
do i=1,dimsizes(sid),1
    
  ; Store other vars
  cslat = slat(i-1)
  cslon = slon(i-1)
  cplat = plat(i-1)
  cplon = plon(i-1)
  cname = sname(i-1)
  pint = int(i-1)
  ptop = top(i-1)
  pbot = bot(i-1)

  ; Sanity check for PIREP TOP and BOT values
  if ptop.lt.0 then
    topon = False
  else
    topon = True
  end if
  if pbot.lt.0 then
     boton = False
  else
     boton = True
  end if

  ; Convert the "TOP" and "BOT" from ft to m
  tl = tofloat(ptop)*10
  tl = tl*0.3048
  bl = tofloat(pbot)*10
  bl = bl*0.3048

  ; Set the lat/lon bounds for the map based on the RAOB location
  res@mpLeftCornerLatF  = cslat+1.5
  res@mpLeftCornerLonF  = cslon-2
  res@mpRightCornerLatF = cslat-1.5
  res@mpRightCornerLonF = cslon+2

  ; Format the ID correctly 
  if  i.lt.10 then
    id = "00"+tostring(i)
  end if
  if i.ge.10 .and. i.lt.100 then
    id = "0"+tostring(i)
  end if

  ; Open sounding file if present, otherwise continue to the next sounding
  sfin = yyyymmdd+hr+"_"+id+"_"+cname+"_raob.txt"
  if isfilepresent(sfin) then
    
    ; Store sounding profile
    sdata = asciiread(sfin,-1,"string")
    T     = tofloat(str_get_field(sdata,3," "))
    Td    = tofloat(str_get_field(sdata,4," "))
    pres  = tofloat(str_get_field(sdata,2," "))
    rh    = tofloat(str_get_field(sdata,5," "))
    alt   = tofloat(str_get_field(sdata,15," "))
    T@_FillValue    = 999.0
    Td@_FillValue   = 999.0
    pres@_FillValue = 999.0
    alt@_FillValue  = 999
    
    ; Get the best lowest altitude where there is a valid T ob and use this as surface
    goodt = ind(.not.ismissing(T))
    sfcalt = alt(goodt(0))
  
    ; Arrays for top and bot lines x & y coords
    xcoords = new((/dimsizes(T)/),float)
    xcoords = fspan(min(Td),max(T)+5,dimsizes(T))
    ytop    = new((/dimsizes(xcoords)/),float)
    ytop(:) = (tl+sfcalt)/1000
    ybot    = new((/dimsizes(xcoords)/),float)
    ybot(:) = (bl+sfcalt)/1000
    
    ; Convert altitude to km for plotting
    alt = alt/1000
    
    ; Clean up altitude for random negative heights
    bad = ind(alt.lt.0)
    if .not.ismissing(bad) then
      alt(bad) = 999.0
    end if

    ; Calculate theta-E to plot as well
    es  = 6.112*exp((17.67*T)/(243.5+T))
    smr = 0.622*(es/((pres)-es))
    mr  = (rh*smr)/100
    te  = (243.15+T)*((1000/pres)^(0.286))+3*(mr)
    tec = te-273.15

    ; Open workstation
    wks = gsn_open_wks("png",outdir+yyyymmdd+hr+"_"+id+"_"+cname+"_map")
    gsn_define_colormap(wks,"wh-bl-gr-ye-re")

    ; Position map on the LHS of the plot
    res@vpXF      = 0.00
    res@vpWidthF  = 0.65
    res@vpHeightF = 0.8
    res@vpYF      = 0.95

    ; Plot the map
    map = gsn_csm_map(wks,res)

    ; Define an array for the METAR points
    dum = new((/dimsizes(mlat)/),graphic)
    
    ; Create a new marker (filled star) for sounding location
    mstring = "z"
    fontnum = 35
    xoffset = 0.0
    yoffset = 0.0625
    ratio   = 1.0
    size    = 1.1
    angle   = 0.0
    new_index = NhlNewMarker(wks,mstring,fontnum,xoffset,yoffset,ratio,size,angle)
    
    ; Add the RAOB location
    mkres@gsMarkerSizeF = 0.035
    mkres@gsMarkerColor = "yellow"
    mkres@gsMarkerIndex = new_index
    rdum = gsn_add_polymarker(wks,map,cslon,cslat,mkres)

    ; Loop over all the METAR sites in the file and add a polymarker each time
    print("Adding "+dimsizes(ind(mid.eq.i))+" METARS to the map for "+cname+".  Please wait.")
    mkres@gsMarkerSizeF = 0.04
    mkres@gsMarkerColor = "blue"
    mkres@gsMarkerIndex = 1
    do j=0,dimsizes(mlat)-1,1
      if mid(j).eq.i then
        dum(j) = gsn_add_polymarker(wks,map,mlon,mlat,mkres)
      end if
    end do

    ; Add the PIREP location
    mkres@gsMarkerSizeF = 0.04
    mkres@gsMarkerColor = "red"
    pdum = gsn_add_polymarker(wks,map,cplon,cplat,mkres)

    ; Map legend resources
    lgres                                     = True
    lgres@lgMonoMarkerSize                    = False
    lgres@lgMonoItemType                      = False
    lgres@lgItemTypes                         = (/"Markers","Markers","Markers"/)
    lgres@lgMarkerIndexes                     = (/new_index,1,1/)
    lgres@lgMarkerColors                      = (/"yellow","red","blue"/)
    lgres@lgMarkerSizes                       = (/0.035,0.04,0.04/)
    lgres@lgPerimOn                           = True
    lgres@lgPerimColor                        = "black"
    lgres@lgPerimThicknessF                   = 1.0
    lgres@lgLabelFontHeightF                  = 0.013
    lgres@lgPerimFill                         = 0
    lgres@lgPerimFillColor                    = "white"
    lgres@lgOrientation                       = "Horizontal"
    lgres@lgLabelJust                         = "CenterCenter"
    
    lgres@vpWidthF                            = 0.60
    lgres@vpHeightF                           = 0.10

    ; Create map legend object
    lbid = gsn_create_legend(wks,3,(/"RAOB Site","PIREP","METARs"/),lgres)

    ; Annotation resources (for the map legend object)
    amres = True
    amres@amParallelPosF = 0.50
    amres@amZone = 2

    ; Add legend object to map
    annoid = gsn_add_annotation(map,lbid,amres)
      
    ; Draw the map
    draw(map)

    ; Draw an NDC grid on the wks.  Uncomment this to help align text and plot objects
    ; within the NDC grid.
    ;drawNDCGrid(wks)

    ; Define resources for the sounding plot
    sres                                      = True
    sres@gsnFrame                             = False
    sres@gsnDraw                              = False
    
    sres@xyLineColors                         = (/"red","green","black"/)
    sres@xyLineThicknesses                    = (/2.5,2.5,2.5/)
    
    sres@tiYAxisString                        = "Altitude (km)"
    sres@tiXAxisString                        = "Temperature (C)"
    sres@tiYAxisFontHeightF                   = 0.014
    sres@tiXAxisFontHeightF                   = 0.014
    sres@tiMainString                         = hr+"Z Sounding for "+cname
    sres@tiMainFontHeightF                    = 0.014
    sres@tiMainOffsetYF                       = -0.015
    
    sres@trYMaxF                              = 12.0
    sres@trXMaxF                              = max(T)+5
    sres@trXMinF                              = min(Td)
    
    sres@tmXBFormat                           = "f"
    sres@tmYLLabelAngleF                      = 90
    sres@tmYLLabelJust                        = "CenterCenter"
    sres@tmXBLabelFontHeightF                 = 0.014
    sres@tmYLLabelFontHeightF                 = 0.014
    sres@tmXTOn                               = False
    sres@tmYROn                               = False
    
    ; Position the sounding on the RHS of the plot
    sres@vpXF = 0.74
    sres@vpWidthF = 0.25
    sres@vpHeightF = 0.8
    sres@vpYF = 0.925

    ; Combine the T/Td data into a single array
    lines = new((/3,dimsizes(T)/),float)
    lines(0,:) = T
    lines(1,:) = Td
    lines(2,:) = tec

    ; Now plot a simple line plot on the RHS of the map with the sounding
    if .not.isMonotonic(alt) then
      print("Error!  Height array not monotonic.  Skipping sounding for "+cname)
      
      ; Delete data
      delete([/sdata,pres,T,Td,dum,pdum,rdum,lines,alt,tec,rh,es,mr,smr,te,xcoords,ytop,ybot/])
      delete([/goodt/])
    
      ; Go to next sounding
      continue
    else
      ; Plot the sonde
      sonde = gsn_csm_xy(wks,lines,alt,sres)

      ; Add the lines and text labels for PIREP icing layer "TOP" and "BOT" levels
      ; only if the values for those levels were valid from the PIREP
      if topon then
        dl1 = gsn_add_polyline(wks,sonde,xcoords,ytop,lres)
        txdum1 = gsn_add_text(wks,sonde,"TOP",min(Td)+8,ytop(1)+0.15,txres2)
      else
        print("Error! PIREP TOP invalid.")
      end if
      if boton then
        dl2 = gsn_add_polyline(wks,sonde,xcoords,ybot,lres)
        txdum2 = gsn_add_text(wks,sonde,"BOT",min(Td)+8.2,ybot(1)-0.15,txres2)
      else
        print("Error! PIREP BOT invalid.")
      end if
    
      ; Add the PIREP intensity as text on the RHS (on the sonde plot)
      gsn_text_ndc(wks,"INT = "+pint,.95,.90,txres)

      ; Set resources for the sounding legend
      slgres                                  = True
      slgres@lgMonoItemType                   = False
      slgres@lgMonoDashIndex	              = False
      slgres@lgItemType                       = "Lines"
      slgres@lgDashIndexes                    = 0
      slgres@lgLineColors                     = "red"
      slgres@lgLineThicknessF                 = 2
      slgres@lgPerimOn                        = False
      slgres@lgLabelFontHeightF               = 0.075
      slgres@lgLabelOffsetF                   = 0.1

      slgres@vpWidthF                         = 0.10
      slgres@vpHeightF                        = 0.10

      ; Create sounding legend object for line 1 (Temperature)
      slbid = gsn_create_legend(wks,1,(/"T"/),slgres)

      ; Annotation resources for line 1 (Temperature)
      samres = True
      samres@amParallelPosF = -0.45
      samres@amOrthogonalPosF = 0.62

      ; Add legend object to sounding for line 1 (Temperature)
      annoid = gsn_add_annotation(sonde,slbid,samres)

      ; Reset certain resources and add line 2 to legend (Dew Point Temperature)
      samres@amParallelPosF = -0.09
      slgres@lgLineColors = "green"
      slgres@lgDashIndexes = 1
      slbid2 = gsn_create_legend(wks,1,(/"Td"/),slgres)
      annoid2 = gsn_add_annotation(sonde,slbid2,samres)

      ; Reset certain resources and add line 3 to legend (Theta-E)
      samres@amParallelPosF = 0.33
      slgres@lgLineColors = "black"
      slgres@lgDashIndexes = 2
      slbid3 = gsn_create_legend(wks,1,(/"Theta-E"/),slgres)
      annoid3 = gsn_add_annotation(sonde,slbid3,samres)
     
      ; Draw the sonde on the plot and advance the frame 
      draw(sonde)
      frame(wks)
      
      ; Delete data
      delete([/sdata,pres,T,Td,dum,pdum,rdum,lines,alt,tec,rh,es,mr,smr,te,xcoords,ytop,ybot/])
      delete([/goodt/])
    end if

  else
    ; Let the user know if the sounding file was missing
    print("File "+sfin+" not found")
  end if
  
end do
