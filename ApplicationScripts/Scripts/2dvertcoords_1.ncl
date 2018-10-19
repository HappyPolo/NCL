;**************************************************
; 2dvertcoords.ncl
;**************************************************
; Concepts illustrated:
;   - Reading a C format data file
;   - Reordering variable dimensions
;   - Using the new color model
;   - Using NCL OOP statements
;
;**************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"                      
;**************************************************


begin                                                                        
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
  wks   = gsn_open_wks("png","2dvertcoords"); send graphics to PNG file
  res                 = True                ; plot mods desired
  res@gsnMaximize     = True
  res@sfXArray        = range               ; could be reduced to 1D
  res@sfYArray        = depth               ; 2D                  
  res@cnInfoLabelOn   = False               ; turn off contour info label

  res@cnFillOn        = True                ; turn on color
  res@cnFillPalette   = "gui_default"       ; set color map
  res@cnLineLabelsOn  = False               ; turn off line labels
  res@cnLinesOn       = False               ; turn off contour lines

  res@tiMainString    = "original data (no tickmarks present)"     ; add title
  res@lbOrientation   = "vertical"

;
; This first plot will produce a warning, which you can ignore.
; The next plot will fix the problem.
;
  plot  = gsn_csm_contour(wks,d,res)         ; contour the variable       
          
;                                                   
; Linearize the plot by overlaying on a "logLinPlot" object. It's 
; important to use the "curvilinear" grid type instead of the default 
; 2D "spherical" grid type because the spherical grid type assumes 
; that the X coordinates are modular and that the Y coordinates only 
; range from -90 to 90.  
;                                                   
  setvalues plot                                                             
    "trGridType"    : "curvilinear" 
    "tiMainString"  : "linearized data"
    "tiXAxisString" : "Range across shelf (m)"   ; x-axis title
    "tiYAxisString" : "Depth up from bottom (m)" ; y-axis title
  end setvalues                                                              
                                                   
  ll = create "ll" logLinPlotClass wks                                       
    "trXMinF"      : min(range)
    "trXMaxF"      : max(range)
    "trYMinF"      : min(depth) 
    "trYMaxF"      : max(depth)
    "pmTickMarkDisplayMode" : "always" ; necessary in order to turn on tickmarks
  end create   
  gsnp_point_tickmarks_outward(ll,False,-1.,-1.,-1.,-1.,-1.,-1.,True)

;
; Overlaying the original plot on a "loglin" object will
; linearize the axes.
;
  overlay(ll, plot)                                                
                                                             
  draw(ll)                                                                   
  frame(wks)                                                                 
                                                   
end                                                                          
