; ***********************************************
; barb_4.ncl
;
; Concepts illustrated:
;   - Drawing wind barbs
;   - Drawing a wind profile plot
;   - Reversing the Y axis in a wind profile plot
;   - Changing the thickness of a wind barb tick
;   - Turning off the vector reference annotation label
;   - Explicitly setting wind barb levels
;   - Changing the length of the wind barbs
;   - Making the labelbar be vertical
;   - Linearizing the Y axis
;   - Creating a LogLin object
;   - Retrieving the axes mins and maxs of a plot
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  a = addfile("windbarb.nc","r")
  u = a->U			; (time, lev)
  v = a->V		     ; (time, lev)
  wspd = u
  wspd = (/ sqrt(u^2+v^2) /)
;===========================================================
  wks = gsn_open_wks("png","barb")    ; send graphics to PNG file
  gsn_define_colormap(wks,"WhBlGrYeRe")

  res                = True                    
  res@gsnDraw        = False          ; do not draw
  res@gsnFrame       = False          ; do not advance the frame
  res@tiMainString   = "Wind Profile" ; add title
  res@vcGlyphStyle   = "WindBarb"     ; select wind barbs 
  res@vcRefLengthF   = 0.045          ; define length of vec ref
  res@vcRefAnnoOn    = False          ; turn off ref wind barb
  res@trYReverse     = True           ; reverse the Y-axis
  res@vcMonoWindBarbColor     = False            ; color barbs by scalar
  res@lbOrientation           = "vertical"       ; vertical labelbar
  res@vcLevelSelectionMode    = "ExplicitLevels" ; will explicitly set the levels
  res@vcWindBarbLineThicknessF= 1.5              ; set the wind barb thickness
  res@vcLevels                = ispan(5,65,5)    ; set the levels 
  res@vcLevelColors           = (/20,30,40,45,50,55,60,65,70,75,80,85,90,95/)   ; set the colors associated with the wind speed
  
  res@vcMapDirection = False			; needed to disassociate the map from the vectors
  res@gsnAddCyclic = False              ; data is not cyclic
  res@gsnLeftString = ""
  plot = gsn_csm_vector_scalar(wks,u(lev|:,time|:),v(lev|:,time|:),wspd(lev|:,time|:),res)

  getvalues plot                        ; get the X/Y axis min/max for use in the loglin plot
    "trXMinF"    : trxmin
    "trXMaxF"    : trxmax
    "trYMinF"    : trymin
    "trYMaxF"    : trymax
  end getvalues

  loglin = create "logling" logLinPlotClass wks     ; draw a loglin plot, with expanded X/Y axis
    "trXMinF"        : trxmin-1
    "trXMaxF"        : trxmax+1
    "trYMinF"        : trymin-40
    "trYMaxF"        : trymax+50
    "trYReverse"     : True
    "vpXF"           : .15            ; set the X-axis NDC starting point
    "vpYF"           : .8             ; set the Y-axis NDC starting point
    "vpWidthF"       : .7             ; set the width of the plot in NDC units
    "vpHeightF"      : .45            ; set the height of the plot in NDC units
  end create
  overlay(loglin,plot)              ; overlay plot with the loglin plot
  draw(loglin)                      ; draw the plot
  frame(wks)                        ; advance the frame
end
