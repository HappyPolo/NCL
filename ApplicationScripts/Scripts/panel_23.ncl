;*************************************************
; panel_23.ncl
;
; Concepts illustrated:
;   - Paneling 12 plots with shared axes
;   - Adding a common labelbar to paneled plots
;   - Adding a common title to paneled plots
;   - Generating dummy data using "generate_2d_array"
;   - Drawing a custom labelbar
;   - Removing the border, tickmarks, and labels from a contour plot
;   - Retrieving contour resource values to create a labelbar
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;********************************************************************
; This function draws a title at the top of the page
;********************************************************************
function main_title(wks,title)
local txres
begin
  txres               = True
  txres@txFontHeightF = 0.03
  txres@txFont        = "Helvetica-bold"
  txres@txPosXF       = 0.50
  txres@txPosYF       = 0.97

  txid = gsn_create_text(wks,title,txres)

  draw(txid)
  return(txid)
end

;********************************************************************
; This function creates and draws a labelbar based on a given 
; contour plot.
;********************************************************************
function labelbar(wks,plot)
local colors, levels, labels, nboxes
begin

; Retrieve the contour levels and their associated colors.
  getvalues plot
    "cnLevels"     : levels
    "cnFillColors" : colors
  end getvalues

  nboxes = dimsizes(colors)

  labels                   = ""+levels    ; labels for the labelbar

; Set some labelbar resources.
  lbres                    = True
  lbres@vpXF               = 0.15         ; Position labelbar at         
  lbres@vpYF               = 0.08         ; bottom center of frame.
  lbres@vpWidthF           = 0.70
  lbres@vpHeightF          = 0.10

  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF = 0.013            ; Label font height
  lbres@lbLabelAlignment   = "InteriorEdges"

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)

  draw(lbid)     ; Draw labelbar

  return(lbid)   ; Return it so we can maximize later if desired.
end

;********************************************************************
; Main code.
;********************************************************************

begin
  nx     = 100
  ny     = 100
  nplots = 12
;
; Generate "nplots" dummy data sets. This script is set up
; specifically for 4 x 3 plots.
;
  data = new((/nplots,ny,nx/),float)

  data(0,:,:) = generate_2d_array(10, 10, -19.,16., 0, (/ny,nx/))
  data(1,:,:) = generate_2d_array(10, 10, -28.,15., 1, (/ny,nx/))
  data(2,:,:) = generate_2d_array(10, 10, -25.,18., 2, (/ny,nx/))
  data(3,:,:) = generate_2d_array(10, 10, -24.,17., 3, (/ny,nx/))

  data(4,:,:) = generate_2d_array(10, 10, -21.,16., 4, (/ny,nx/))
  data(5,:,:) = generate_2d_array(10, 10, -23.,14., 5, (/ny,nx/))
  data(6,:,:) = generate_2d_array(10, 10, -27.,18., 6, (/ny,nx/))
  data(7,:,:) = generate_2d_array(10, 10, -26.,16., 7, (/ny,nx/))

  data(8,:,:)  = generate_2d_array(10, 10, -22.,15., 8, (/ny,nx/))
  data(9,:,:)  = generate_2d_array(10, 10, -21.,19., 9, (/ny,nx/))
  data(10,:,:) = generate_2d_array(10, 10, -24.,18.,10, (/ny,nx/))
  data(11,:,:) = generate_2d_array(10, 10, -23.,15.,11, (/ny,nx/))

;
; Calculate some "nice" contour intervals for all plots.
  mnmxlvl = nice_mnmxintvl(min(data),max(data),16,False)

;
; Start the graphics.
;
  contour = new(nplots,graphic)  ; Array to hold plots

  wks = gsn_open_wks("png","panel")  ; send graphics to PNG file

  res                           = True

  res@gsnFrame                  = False

; Force all plots to have same contour levels. Allows us to have
; one common labelbar.
  res@cnLevelSelectionMode      = "ManualLevels"
  res@cnMinLevelValF            = mnmxlvl(0)
  res@cnMaxLevelValF            = mnmxlvl(1)
  res@cnLevelSpacingF           = mnmxlvl(2)

  res@cnFillOn                  = True  ; Turn on contour fill
  res@cnFillPalette             = "StepSeq25" ; set color map

  res@cnInfoLabelOn             = False  ; Turn off info label
  res@lbLabelBarOn              = False  ; Turn off individual labelbars

  res@tmXBLabelFontHeightF      = 0.01   ; Make slightly larger
  res@tmYLLabelFontHeightF      = 0.01

  res@vpWidthF                  = 0.2  ; So they can all fit on same page.
  res@vpHeightF                 = 0.2

  xpos = (/0.2,0.4,0.6/)       ; X positions for plots
  ypos = (/0.9,0.7,0.5,0.3/)   ; Y positions for plots

;
; Loop through plots. Depending on which plot it is, turn on/off
; various tickmarks and their labels. Also set the X and Y positions.
;
  do i=0,nplots-1

; Top three plots.
    if(any(i.eq.(/0,1,2/))) then
      res@vpYF         = ypos(0)
      res@vpXF         = xpos(i)
      res@tmXTOn       = True
      res@tmXTLabelsOn = True
    else
      res@tmXTOn       = False
      res@tmXTLabelsOn = False
    end if

; Bottom three plots.
    if(any(i.eq.(/9,10,11/))) then
      res@vpYF         = ypos(3)
      res@vpXF         = xpos(i-9)
      res@tmXBOn       = True
      res@tmXBLabelsOn = True
    else
      res@tmXBOn       = False
      res@tmXBLabelsOn = False
    end if

; Rightmost four plots.
    if(any(i.eq.(/0,3,6,9/))) then
      res@vpYF         = ypos(i/3)
      res@vpXF         = xpos(0)
      res@tmYLOn       = True
      res@tmYLLabelsOn = True
    else
      res@tmYLOn       = False
      res@tmYLLabelsOn = False
    end if

; Leftmost four plots.
    if(any(i.eq.(/2,5,8,11/))) then
      res@vpYF         = ypos(i/3)
      res@vpXF         = xpos(2)
      res@tmYROn       = True
      res@tmYRLabelsOn = True
    else
      res@tmYROn       = False
      res@tmYRLabelsOn = False
    end if

; Center plots.
    if(any(i.eq.(/4,7/))) then
      res@vpYF         = ypos(i/3)
      res@vpXF         = xpos(i%3)
      res@tmXBOn       = False
      res@tmXBLabelsOn = False
      res@tmXTOn       = False
      res@tmXTLabelsOn = False
      res@tmYROn       = False
      res@tmYRLabelsOn = False
      res@tmYLOn       = False
      res@tmYLLabelsOn = False
    end if

; Create and draw contour plot
    contour(i) = gsn_csm_contour(wks,data(i,:,:),res)

  end do

; Create and draw a labelbar and main title.
  lb = labelbar(wks,contour(0))
  tx = main_title(wks,"This is a main title")

  frame(wks)                     ; Advance frame

; See what happens in PS file when you maximize all the plots.
  psres = True   
  maximize_output(wks,psres) 

end

