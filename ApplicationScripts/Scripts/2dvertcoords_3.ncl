;*************************************************
; 2dvertcoords.ncl
;*************************************************
; Concepts illustrated:
;   - Using the new color model
;   - Shading areas with missing data
;   - Reordering dimensions in an array
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"                      


begin                                                                        
;
; This script is similar to 2dvertcoords_1.ncl, except it shows
; how to shade the terrain area in gray.
;
;**************************************************
; read in binary data
;**************************************************
; This setfileoption call assures the file is read
; as a big endian file. This will happen by default
; on a big endian machine.
;**************************************************
  setfileoption("bin","ReadByteOrder","BigEndian")

  dims  = (/3,4000,62/)
  data_array   = cbinread("bin_output15_bigEndian",dims,"float") 
;**************************************************
; name variable dimensions, so we can reorder variable
; and subscript.
;************************************************** 
  data_array!0 = "vars"  ; variables (x-coord,z-coord,values)
  data_array!1 = "range" ; range off the shelf
  data_array!2 = "depth" ; depth

  d            = data_array(vars|2,depth|:,range|:)
;  d!0          = "depth"
;  d!1          = "cross_shelf"
;**************************************************
; read in coordinates
;************************************************** 
  dims      = (/2,4000,62/)            
  coords    = cbinread("bin_vgrid_bigEndian",dims,"float")
  coords!0  = "vcoords"   ; name dimensions so we can reorder
  coords!1  = "range"                                                        
  coords!2  = "depth"                                                        
                                             
  range            = coords(vcoords|0,depth|:,range|:)
; the challenge with this type of data is a two-dimensional vertical
; coordinate. The gsn_csm high-level graphical interfaces can handle 2D 
; lat/lon coordinates but are not currently adpated for 2D vertical coords.   
  depth            = coords(vcoords|1,depth|:,range|:)
;**************************************************
; assign variable metadata
;************************************************** 
  wks   = gsn_open_wks("png","2dvertcoords") ; send graphics to PNG file

  res                 = True                 ; plot mods desired
  res@gsnDraw         = False                ; don't draw plot
  res@gsnFrame        = False                ; don't advance frame

  res@gsnMaximize     = True                 ; make large PNG file  
;
; This resource is necessary if you use gsn_csm_contour,
; because this function wants to modify the tickmarks to point
; outward. Because this plot is overlaid on an irregular domain,
; tickmarks essentially don't exist, and hence we can't modify
; them. By setting gsnScale to False, we're telling gsn_csm_contour
; not to attempt to "scale" the tickmarks. We'll scale the 
; tickmarks later.
;
  res@gsnScale        = False 

  res@sfXArray        = range               ; could be reduced to 1D
  res@sfYArray        = depth               ; 2D                  
  res@cnInfoLabelOn   = False               ; turn off contour info label

  res@cnFillOn          = True                ; turn on color
  res@cnFillPalette     = "gui_default"       ; set color map
  res@cnLineLabelsOn    = False               ; turn off line labels
  res@cnLinesOn         = False               ; turn off contour lines

  res@tiMainString    = "original data"     ; add title


  plot  = gsn_csm_contour(wks,d,res)         ; contour the variable       
          
; Linearize the plot by overlaying on a logLinPlot. It's important to use the
; "curvilinear" gridType instead of the default 2D "spherical" grid type 
; because the spherical grid type assumes that the X coordinates are modular 
; and that the Y coordinates only range from -90 to 90.  
                                                   
  setvalues plot                                                             
    "trGridType"    : "curvilinear" 
    "tiMainString"  : "linearized data"
    "tiXAxisString" : "Range across shelf (m)"   ; x-axis title
    "tiYAxisString" : "Depth up from bottom (m)" ; y-axis title
  end setvalues                                                              
                                                   
  min_range = min(range)
  max_range = max(range)
  min_depth = min(depth) 
  max_depth = max(depth)

;
; Create the irregular domain on which to overlay the contours.
; Here's where we can force the tickmarks to point outward.

  ll = create "ll" logLinPlotClass wks                                       
    "trXMinF"                 : min_range
    "trXMaxF"                 : max_range
    "trYMinF"                 : min_depth 
    "trYMaxF"                 : max_depth

    "pmTickMarkDisplayMode"   : "always"                                       
    "tmYLMajorOutwardLengthF" : 0.02
    "tmXBMajorOutwardLengthF" : 0.02
    "tmYLMinorOutwardLengthF" : 0.01
    "tmXBMinorOutwardLengthF" : 0.01
    "tmYLMajorLengthF"        : 0.02
    "tmXBMajorLengthF"        : 0.02
    "tmYLMinorLengthF"        : 0.01
    "tmXBMinorLengthF"        : 0.01
  end create   

  overlay(ll, plot)                                                
                                                             
;
; Shade the terrain area in gray.
;
  dimsr  = dimsizes(range)
  ndepth = dimsr(0)
  nrange = dimsr(1)

;
; Create arrays to hold the points that will outline the
; terrain area to be shaded in gray.
;
  npoly = nrange + 3    ; The terrain line plus 3 points to 
                        ; close the polygon

  xpoly = new(npoly,typeof(range))
  ypoly = new(npoly,typeof(range))

  xpoly(0:nrange-1) = (/range(0,:)/)    ; The terrain
  ypoly(0:nrange-1) = (/depth(0,:)/)

  xpoly(nrange)     = max_range         ; Bottom right corner of plot
  ypoly(nrange)     = min_depth

  xpoly(nrange+1)   = min_range         ; Bottom left corner of plot
  ypoly(nrange+1)   = min_depth

  xpoly(nrange+2)   = range(0,0)        ; Start of terrain. This closes
  ypoly(nrange+2)   = depth(0,0)        ; the polygon.

;
; Resources for both the terrain fill and outlining the terrain.
;
  pres                  = True
  pres@gsFillColor      = "gray"
  pres@gsLineThicknessF = 2.0          ; twice as thick
; pres@gsFillIndex      = 17           ; stipple, if desired

;
; Attaching the line and polygon allows us to resize the plot
; later, if needed.
;
  dum0 = gsn_add_polygon(wks,plot,xpoly,ypoly,pres)
  dum1 = gsn_add_polyline(wks,plot,xpoly(0:nrange-1),ypoly(0:nrange-1),pres)

;
; Resize the plot so that it maximally fits on the PS page.
;
; This call also draws everything on the workstation, including
; the line and polygon.
;
  draw(ll)
  frame(wks)
                                                   
end                                                                          
