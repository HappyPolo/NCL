;-----------------------------------------------------------------------
;-- DKRZ NCL example: two_spinning_globes_Mean_Temperature_Change_max_16to9_less_tsteps.ncl
;--
;-- Description:      Mean temperature change animation of the CMIP5 
;--                   '2m temperature' data similar to the Avizo animation
;--                   http://www.dkrz.de/Klimaforschung/konsortial/ipcc-ar5/ergebnisse/2m-temperatur
;--
;-- Time range:		  1985 - 2096  (time step 940 - 1723) --> total time steps 782
;--
;-- Output format:    PNG
;-- Output size:      2500 x 2500  for 16:9 cropping in PhotoShop/Premiere 1920x1080 pixel
;-- Software:         Create Animation -> Photoshop/Premiere 
;-- Video:            Photoshop/Premiere
;--						1.	Open -> click on first picture -> turn on sequenz -> open
;--                 	2.	Framerate: 25 fps  -> ok   (if too fast than 15 fps)
;--                 	3.	click on cut range. upper left turn on 16:9 
;--                 	4.	move frame -> click cut range -> do it
;--                		3.	export -> render video  
;--                 					-> name:		insert
;--                 					-> format:		H.264
;--                 					-> default:		high quality
;--                 					-> size:		HDTV 1080p
;--                 					-> framerate:	25fps
;--                 					-> half frame sequenz:	Default (progressive)
;--                 					-> render
;--                   (iMovie: 'adjust to frame', no 'Ken Burns', 0.1s per frame
;--                             iMovie -> export -> Quicktime -> .mov file)
;--
;-- Path:             $HOME/Filme/DKRZ_mean_temp_change_CMIP5_*.mov
;--
;-- Karin Meier-Fleischer, DKRZ                                 20.04.14 
;-----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;-----------------------------------------------------------------------
;-- procedure add_labelbar
;-----------------------------------------------------------------------
undef("add_labelbar")
procedure add_labelbar(wks,map)
begin
;-- retrive values from plot
  getvalues map@contour
     "cnFillColors"              :   cols
     "cnLevels"                  :   levs
     "vpWidthF"                  :   vpw
     "vpHeightF"                 :   vph
     "vpXF"                      :   vpx
     "vpYF"                      :   vpy
  end getvalues
         
;-- set the labels and the labelbar width, height and position
  labs     = levs+""
  nlevs    = dimsizes(labs)
  lbwidth  = 0.5
  lbheight = 0.06
  lbx      = ((1.0-(lbwidth+vpx))/2) + vpx/2
  lby      = ((1.0-(vpy-vph))/2) - 0.01

;-- set labelbar resources
  lbres                       =  True
  lbres@gsnFrame              =  False                 ;-- don't advance frame
  lbres@vpWidthF              =  lbwidth               ;-- width of labelbar
  lbres@vpHeightF             =  lbheight              ;-- height of labelbar
  lbres@vpXF                  =  lbx                   ;-- labelbar x-position
  lbres@vpYF                  =  lby                   ;-- labelbar y-position
  lbres@lbPerimOn             =  False                 ;-- no label bar box
  lbres@lbOrientation         =  "Horizontal"          ;-- orientation
  lbres@lbLabelFontHeightF    =  0.015                 ;-- label font height
  lbres@lbLabelAlignment      =  "InteriorEdges"       ;-- where to label
  lbres@lbLabelPosition       = "Top"                  ;-- write labels on top of the labelbar
  lbres@lbMonoFillPattern     =  True                  ;-- fill solid
  lbres@lbFillColors          =  cols                  ;-- use colors
  lbres@lbFillPattern         =  0                     ;-- fill solid
  lbres@lbLabelFontColor      = "white"                ;-- label color
  lbres@lbMonoFillColor       =  False                 ;-- no mono fill color
  
  gsn_labelbar_ndc(wks,nlevs+1,labs,lbx,lby,lbres)     ;-- draw transparent labelbar
  
end

;-------------------------------------------------------
;-- function getDate
;-------------------------------------------------------
undef ("getDate")
function getDate(time)
local utc_date, year, mon, day, hours, mins, str_date
begin
   utc_date   = cd_calendar(time, 0)                        ;-- convert date to UT-referenced date
   year       = sprinti("%0.4i",tointeger(utc_date(:,0)))   ;-- get year as integer value
   mon        = sprinti("%0.2i",tointeger(utc_date(:,1)))   ;-- get month as integer value
   day        = sprinti("%0.2i",tointeger(utc_date(:,2)))   ;-- get day as integer value
   hours      = sprinti("%0.2i",tointeger(utc_date(:,3)))   ;-- get day as integer value
   mins       = sprinti("%0.2i",tointeger(utc_date(:,4)))   ;-- get day as integer value
   str_date   = year+"/"+mon+"/"+day+" "+hours+":"+mins     ;-- yyyy/mm/dd HH:MM
   
   return(year)      ;-- return only year string
   
end


;-----------------------------------------------------
;-- MAIN script
;-----------------------------------------------------
begin
  start_date = toint(systemfunc("date +%s"))        ;-- computing start time
  
;-- interpolate to half hour time steps to prevent leaps
  f26    = addfile("$HOME/data/AR5/rcp26_mean1-3_LR_dtemp2_ym_1850-2100vs1986-2005_n7.nc","r")
  f85    = addfile("$HOME/data/AR5/rcp85_mean1-3_LR_dtemp2_ym_1850-2100vs1986-2005_n7.nc","r")
  temp1  = f26->temp2                               ;-- temperature data 1st time step
  temp2  = f85->temp2                               ;-- temperature data 1st time step
  time   = f85->time                                ;-- time values

  varMin =  0.0
  varMax = 11.0
  varInt =  1.0
  npts   = ((varMax-varMin)/varInt)+1

;-- set plot output file name
  plotout = "./plots_min_2500x2500/plot_two_spinning_globes_Mean_Temp_Change_1degrot1985-2096"

;-- set workstation resources
  wks_type                 = "png"                  ;-- plot output type
  wks_type@wkBackgroundColor = "black"              ;-- set workstation background to black (or grey18)
  wks_type@wkWidth         =  2500                  ;-- for presentations
  wks_type@wkHeight        =  2500                  ;-- for presentations
  wks = gsn_open_wks(wks_type,plotout)
  gsn_define_colormap(wks,"NCL_temperature_difference") ;-- define colormap
  colors = gsn_retrieve_colormap(wks)               ;-- retrieve color map for common labelbar

;-- set resources
  res                      =  True                  ;-- set resources for plot
  res@gsnDraw              =  False                 ;-- don't draw plot yet
  res@gsnFrame             =  False                 ;-- don't advance frame
  res@gsnAddCyclic         =  True                  ;-- add cyclic point
  res@gsnRightString       = ""                     ;-- don't draw right string
  res@gsnLeftString        = ""                     ;-- don't draw left string

  res@cnFillOn             =  True                  ;-- enable color fill
  res@cnLinesOn            =  False                 ;-- disable contour lines
  res@cnLineLabelsOn       =  False                 ;-- disable contour lines
  res@cnFillMode           = "RasterFill"           ;-- set fill mode
  res@cnRasterSmoothingOn  =  True                  ;-- smooth contouring
  res@cnLevelSelectionMode = "ManualLevels"         ;-- use manual contour line levels
  res@cnMinLevelValF       =  varMin                ;-- contour min. value
  res@cnMaxLevelValF       =  varMax                ;-- contour max. value
  res@cnLevelSpacingF      =  varInt                ;-- contour interval

  res@lbLabelBarOn         =  False                 ;-- add common colorbar

  res@mpProjection         = "Orthographic"         ;-- use projection
  res@mpCenterLatF         =  35                    ;-- center latitude at 53 deg north
  res@mpOutlineOn          =  True                  ;-- outline map
  res@mpGridAndLimbOn      =  False                 ;-- draw grid lines
  res@mpGeophysicalLineColor = "black"              ;-- outline color
  res@mpGeophysicalLineThicknessF = 2.5             ;-- thickness of continental outlines
  res@mpPerimOn            =  False                 ;-- don't draw the box around the plot

  res@tiMainFontHeightF    =  0.02                  ;-- main title font size
  res@tiMainOffsetYF       =  0.06                  ;-- move title upward
  res@tiMainFontColor      = "white"                ;-- set font color to white

  res@vpYF                 =  0.95                  ;-- set viewport Y position
  res@vpHeightF            =  0.45                  ;-- set viewport width
  res@vpWidthF             =  0.8                   ;-- set viewport height

  res1                     =  res                   ;-- resource setting for left plot
  res1@vpXF                =  0.049                 ;-- set viewport X position 1. panel
  
  res2                     =  res                   ;-- resource setting for right plot
  res2@vpXF                =  0.503                 ;-- set viewport X position 2. panel

;-- text resources: labelbar units, copyright and year string
  tires1                   =  True                  ;-- text resources title string
  tires1@txFontColor       = "white"                ;-- change to white
  tires1@txFontHeightF     =  0.018                 ;-- text font size
  tires1@txJust            = "CenterCenter"         ;-- text justification

  tires2                   =  True                  ;-- text resources year string
  tires2@txFontColor       = "white"                ;-- change to white
  tires2@txFontHeightF     =  0.018                 ;-- text font size
  tires2@txJust            = "CenterCenter"         ;-- text justification
  tires2@txFont            =  30                    ;-- text font "courier-bold"

  tires3                   =  True                  ;-- text resources copyright string
  tires3@txFontColor       = "white"                ;-- change to white
  tires3@txJust            = "BottomRight"          ;-- text justification
  tires3@txFontHeightF     =  0.013                 ;-- make font size smaller
  
;-- create plots
  ntimes   = 1723                                   ;-- from 1st to 1723 time step (31.12.2096)
  incr     =  0.5                                   ;-- turn 0.5 degree to the east for each time step
  startlon = 15.0                                   ;-- start center longitude value
  tstart   =  940                                   ;-- year 1985 as starting point

;-- assign plot array for the data sets displayed on two globes
  plot = new(2,graphic)
  
;-- loop over time steps and rotate the globe 1 degrees per frame;
;-- don't use maximize_output()! To draw text on the plot use draw() 
;-- and frame() instead (see below)
  j=0
  do i=tstart,ntimes-1
     irot = where((j*incr).le.-180., (j*incr)+360., (j*incr)) ;-- rotation longitude step
     rlon = startlon - irot                                   ;-- define mpCenterLonF value
     res1@mpCenterLonF = rlon                                 ;-- center lon position
     res2@mpCenterLonF = rlon                                 ;-- center lon position
          
     plot(0) = gsn_csm_contour_map(wks,temp1(i,:,:),res1)     ;-- create the plots
     plot(1) = gsn_csm_contour_map(wks,temp2(i,:,:),res2)     ;-- create the plots
     
     draw(plot)                                               ;-- draw the plots yet to start text drawing on it

     add_labelbar(wks,plot)                                   ;-- add a common labelbar below the two globes
     
     gsn_text_ndc(wks,"Mean Temperature Change~C~           MPI-ESM LR",0.5,0.77,tires1) ;-- center title string
     gsn_text_ndc(wks,"RCP 2.6",0.06, 0.76, tires1)           ;-- center title string
     gsn_text_ndc(wks,"RCP8.5", 0.94, 0.76, tires1)           ;-- center title string
     gsn_text_ndc(wks,"~F35~c ~F21~~N~DKRZ / MPI-M", 0.98, 0.281, tires3) ;-- plot copyright info 
     gsn_text_ndc(wks,"[~S~o~N~C]", 0.77, 0.301, tires3)      ;-- plot units string
     gsn_text_ndc(wks,getDate(time(i)),0.50, 0.348, tires2)   ;-- plot year string
     
     frame(wks)                                               ;-- advance the frame of each plot
     
     print("Plot:  "+j+"   year: "+getDate((time(i)))+"   rlon: "+rlon)
     j = j+1
  end do

;-- print some computing time information
  end_date = toint(systemfunc("date +%s"))                    ;-- computing time 
  print("")
  print("Start Time:                         "+start_date)
  print("End Time:                           "+end_date)
  print("Time for "+(j)+"  time steps: "+(end_date-start_date)+"s")
  print("")
  
end
