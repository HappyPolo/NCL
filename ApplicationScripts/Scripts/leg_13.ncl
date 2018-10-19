;----------------------------------------------------------------------
; leg_13.ncl
;
; Concepts illustrated:
;   - Drawing a custom legend based on XY plot settings
;   - Drawing an XY plot with multiple curves
;   - Changing the line color for multiple curves in an XY plot
;   - Drawing XY plot curves with both lines and markers
;   - Changing the default markers in an XY plot
;   - Making all curves in an XY plot solid
;   - Using "getvalues" to retrieve resource values
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This function takes an existing XY plot and constructs a legend
; from it. This is so you can further customize the legend as 
; desired.
;
; If "opt" is set to True, then it can have two attributes:
;
;    LegendLabels - an array of strings to use for the legend labels
;    NumberLegendItems - the number of items you want to display. 
;       The default will be however many legend labels there are.
;----------------------------------------------------------------------
function create_legend_from_plot(wks:graphic,plot:graphic,opt:logical)
local lgres, classname
begin

;---Make sure we have an XY plot!
  classname = NhlClassName(plot)
  if(classname.ne."xyPlotClass") then
    print("create_legend_from_plot: input must be an XY plot")
    return(new(1,graphic))
  end if  

  lgres = True

;---Retrieve some resource values from the XY plot.
  getvalues plot@dataspec
    "xyMonoDashPattern"     : mono_dashindex
    "xyMonoMarkLineMode"    : mono_itemtype
    "xyMonoLineColor"       : mono_linecolor
    "xyMonoLineThickness"   : mono_linethickness
    "xyMonoMarkerColor"     : mono_markercolor
    "xyMonoMarker"          : mono_markerindex
    "xyMonoMarkerSize"      : mono_markersize
    "xyMonoMarkerThickness" : mono_markerthickness

    "xyDashPattern"         : DashIndex
    "xyDashPatterns"        : DashIndexes
    "xyMarkLineMode"        : ItemType
    "xyMarkLineModes"       : ItemTypes
    "xyLineColor"           : LineColor
    "xyLineColors"          : LineColors
    "xyLineThicknessF"      : LineThicknessF
    "xyLineThicknesses"     : LineThicknesses
    "xyMarkerColor"         : MarkerColor
    "xyMarkerColors"        : MarkerColors
    "xyMarker"              : MarkerIndex
    "xyMarkers"             : MarkerIndexes
    "xyMarkerSizeF"         : MarkerSizeF
    "xyMarkerSizes"         : MarkerSizes
    "xyMarkerThicknessF"    : MarkerThicknessF
    "xyMarkerThicknesses"   : MarkerThicknesses
  end getvalues

  if(mono_dashindex.or.all(ismissing(DashIndexes))) then
    lgres@lgDashIndex     = DashIndex
    lgres@lgMonoDashIndex = True
  else
    lgres@lgDashIndexes   = DashIndexes
    lgres@lgMonoDashIndex = False
  end if
  if(mono_itemtype.or.all(ismissing(ItemTypes))) then
    lgres@lgItemType     = ItemType
    lgres@lgMonoItemType = True
  else
    lgres@lgItemTypes    = ItemTypes
    lgres@lgMonoItemType = False
  end if
  if(mono_linecolor.or.all(ismissing(LineColors))) then
    lgres@lgLineColor     = LineColor
    lgres@lgMonoLineColor = True
  else
    lgres@lgLineColors    = LineColors
    lgres@lgMonoLineColor = False
  end if
  if(mono_linethickness.or.all(ismissing(LineThicknesses))) then
    lgres@lgLineThicknessF    = LineThicknessF
    lgres@lgMonoLineThickness = True
  else
    lgres@lgLineThicknesses   = LineThicknesses
    lgres@lgMonoLineThickness = False
  end if
  if(mono_markercolor.or.all(ismissing(MarkerColors))) then
    lgres@lgMarkerColor     = MarkerColor
    lgres@lgMonoMarkerColor = True
  else
    lgres@lgMarkerColors    = MarkerColors
    lgres@lgMonoMarkerColor = False
  end if
  if(mono_markerindex.or.all(ismissing(MarkerIndexes))) then
    lgres@lgMarkerIndex     = MarkerIndex
    lgres@lgMonoMarkerIndex = True
  else
    lgres@lgMarkerIndexes   = MarkerIndexes
    lgres@lgMonoMarkerIndex = False
  end if
  if(mono_markersize.or.all(ismissing(MarkerSizes))) then
    lgres@lgMarkerSizeF    = MarkerSizeF
    lgres@lgMonoMarkerSize = True
  else
    lgres@lgMarkerSizes    = MarkerSizes
    lgres@lgMonoMarkerSize = False
  end if
  if(mono_markerthickness.or.all(ismissing(MarkerThicknesses))) then
    lgres@lgMarkerThicknessF    = MarkerThicknessF
    lgres@lgMonoMarkerThickness = True
  else
    lgres@lgMarkerThicknesses   = MarkerThicknesses
    lgres@lgMonoMarkerThickness = False
  end if

;---Get possible labels for legend
  getvalues plot@dataspec
    "xyExplicitLegendLabels" : exp_legend_labels
    "xyExplicitLabels"       : exp_labels
  end getvalues

;---Figure out which legend labels to use.
  if(.not.all(ismissing(exp_legend_labels))) then
    legend_labels = exp_legend_labels
  else if(.not.all(ismissing(exp_labels))) then
    legend_labels = exp_labels
  else if(opt.and.isatt(opt,"LegendLabels")) then
    legend_labels = opt@LegendLabels
  else
    print("create_legend_from_plot: warning: no labels provided for legend")
    legend_labels = ""
  end if
  end if
  end if

;---Set the width and height of legend based on XY plot size
  getvalues plot
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues
  lgres@vpWidthF  = vpw/4.
  lgres@vpHeightF = vph/5.

;  lgres@lgLabelFontHeightF = 0.05

;---Get desired number of legend items
  nitems = dimsizes(legend_labels)
  if(opt.and.isatt(opt,"NumberLegendItems")) then
    if(opt@NumberLegendItems.gt.dimsizes(legend_labels)) then
      print("create_legend_from_plot: you don't have enough legend labels specified. Resetting.")
    else
      nitems = opt@NumberLegendItems
    end if
  end if

;---Create the legend
  lbid = gsn_create_legend(wks,nitems,legend_labels,lgres)         ; create legend

;---Attach lower right corner of legend to lower right corner of XY plot.
  amres                  = True
  amres@amParallelPosF   = 0.50    ; move legend to the right
  amres@amOrthogonalPosF = 0.50    ; move the legend down
  amres@amJust           = "BottomRight"

;---Add the legend to the plot
  annoid = gsn_add_annotation(plot,lbid,amres)   ; add legend to plot

;---Return the id so it "lives" outside this function.
  return(annoid)
end

;----------------------------------------------------------------------
; Main Code
;----------------------------------------------------------------------

begin
;---Read in data
  f     = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u     = f->U

;---Array of longitudes that we want to subscript "u" by.
  lons  = (/-69, 0, 10, 82/)
  nlons = dimsizes(lons)

  data = new((/nlons,dimsizes(u&lat)/),float)

  do i=0,nlons-1
    data(i,:) = u(0,:,{lons(i)})
  end do

  line_colors   = (/"chartreuse","coral","cyan","darkorchid1"/)
  marker_colors = (/"chartreuse4","coral4","cyan4","darkorchid4"/)
  
  all_colors            = new(2+dimsizes(line_colors)*2,string)
  all_colors(0:1)       = (/"white","black"/)
  all_colors(2:nlons+1) = line_colors
  all_colors(nlons+2:)  = marker_colors

;---Start the graphics
  wks   = gsn_open_wks ("png","leg") ; send graphics to PNG file
  gsn_define_colormap(wks,all_colors)

;---Set up resources for XY plot
  res                     = True

  res@gsnMaximize         = True                      ; Maximize size of plot in frame.
  res@gsnDraw             = False                     ; We will draw and advance
  res@gsnFrame            = False                     ; frame later.

  res@tiMainString        = "Mulitple XY plot"        ; add title

  res@xyLineThicknessF    = 2.5                       ; Default is 1.0
  res@xyMarkerThicknessF  = 1.5

  res@xyMonoDashPattern   = True                      ; Make all lines solid

  res@xyMarkLineMode      = "MarkLines"               ; Markers *and* lines

  res@xyMonoMarker        = False
  res@xyMarkers           = (/4,9,15,14/)

  res@xyMonoLineColor     = False
  res@xyLineColors        = line_colors

  res@xyMonoMarkerColor   = False
  res@xyMarkerColors      = marker_colors

  res@tiMainString        = "XY plot with four curves and only 2 legend items"

  plot  = gsn_csm_xy (wks,u&lat,data,res) ; create plot

;---Call function to add a custom legend
  opt                   = True
  opt@NumberLegendItems = 2
  opt@LegendLabels      = "lon = " + lons(0:1)    ; The first two longitudes we selected.

  annoid = create_legend_from_plot(wks,plot,opt)

;---Drawing the plot will also draw the legend.
  draw(plot)
  frame(wks)
end
