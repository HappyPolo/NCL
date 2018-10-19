;*************************************************
; table_7.ncl
;
; Concepts illustrated:
;   - Drawing a table using gsn_csm_blank_plot and filled polygons
;   - Adding tickmark labels to a table using gsn_csm_blank_plot
;   - Attaching a labelbar to a plot
;   - Attaching text strings to a plot
;   - Explicitly setting tickmarks and labels on the bottom X axis
;   - Explicitly setting tickmarks and labels on the left Y axis
;   - Turning off the top and right tickmarks
;   - Using "getvalues" to retrieve the size of a plot
;   - Using functions for cleaner code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This script shows how to draw a grid filled in different colors
;; based on an array of integer values that each data point is closest
;; to.
;;
;; The function gsn_csm_blank_plot is used to create a "canvas" for
;; drawing filled boxes with gsn_add_polygon. The tmX(Y)MajorGrid 
;; resources are used to outline the boxes. 
;;
;; This script is based on one written by Yang Zhao(CAMS)
;; (Chinese Academy of Meteorological Sciences)
;; email:409360946@qq.com 11/11/2016 Thank you! 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add filled boxes to an existing plot based on a range of levels
;; and their associated colors.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undef("add_filled_boxes")
procedure add_filled_boxes(wks,plot,data,levels,colors)
local dims,gnid, gnres, ii, jj, nrows, ncols, boxx, boxy, index
begin
        dims = dimsizes(data)
        nrows = dims(0)
        ncols = dims(1)
	gnid = new((/nrows,ncols/),"graphic")
        gnres = True     ; resource list for filled polygons
        do jj = 0,nrows-1
          do ii = 0,ncols-1
                boxx = (/ii,ii,ii+1,ii+1,ii/)
                boxy = (/jj,jj+1,jj+1,jj,jj/)
		index = closest_val(data(jj,ii),levels)
                gnres@gsFillColor = colors(index,:)
                gnid(jj,ii) = gsn_add_polygon(wks,plot,boxx,boxy,gnres)
        end do
      end do
      plot@gnid = gnid
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add text strings to every filled box showing the data value.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undef("add_text_strings")
procedure add_text_strings(wks,plot,data)
local txres, xpos, ypos, dims, nrows, cols
begin
      dims = dimsizes(data)
      nrows = dims(0)
      ncols = dims(1)
      txres               = True
      txres@txFontHeightF = 0.009
      txres@txJust        = "CenterCenter"
      xpos = conform_dims((/nrows,ncols/),ispan(0,nrows-1,1),0) + 0.5
      ypos = conform_dims((/nrows,ncols/),ispan(0,ncols-1,1),1) + 0.5
      plot@txid = gsn_add_text(wks,plot,sprintf("%0.1f",data),ypos,xpos,txres)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attach a horizontal labelbar to the bottom of a plot.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undef("add_labelbar")
procedure add_labelbar(wks,plot,colors,labels)
local nboxes, vph, vpw, nboxes, lbres, lbid, amres, annoid
begin
  nboxes = dimsizes(colors)

  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False         ; Necessary to control sizes
  lbres@lbFillColors       = colors        ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.02          ; font height. Default is small
  lbres@lbLabelAlignment   = "BoxCenters"
  lbres@lbOrientation      = "horizontal"
  lbres@lbPerimOn          = False

  lbres@vpWidthF           = vpw * 0.95   ; Make labelbar slightly shorter than width of plot
  lbres@vpHeightF          = vph * 0.25

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
;
; Set some annotation resources indicating how we want to attach
; the labelbar to the plot. Here, we are using the top right
; corner of the labelbar as the point which we are going to position
; it, and then we use amParallelPosF and amOrthogonalPosF to
; indicate where we want to place it.
;
; amParallelPosF/amOrthogonalPosF                                       ;
;    0.0/ 0.0  -  annotation in dead center of plot
;    0.5/ 0.5  -  annotation at bottom right of plot
;    0.5/-0.5  -  annotation at top right of plot
;   -0.5/-0.5  -  annotation at top left of plot
;   -0.5/ 0.5  -  annotation at bottom left of plot
;                                                                 
  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   = 0.0     ; Centered about X axis
  amres@amOrthogonalPosF = 0.9     ; Move labelbar down

  plot@annoid = gsn_add_annotation(plot,lbid,amres)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
begin
;---Create some dummy data
        nrows   = 10
	ncols   = 20
	MINdata = 0.
	MAXdata = 10.
	data = random_uniform(MINdata,MAXdata,(/nrows,ncols/))

;---Set levels and colors to use
        levels = ispan(toint(floor(MINdata)),toint(ceil(MAXdata)),1)
        rgba   = read_colormap_file("BkBlAqGrYeOrReViWh200")
        colors = span_color_rgba(rgba(25:185,:),dimsizes(levels))
        colors(0,3) = 0.0   ; make the first color transparent

;---Set workspace and base resources
	wks = gsn_open_wks("png","table")
	res = True

	res@gsnDraw     = False
	res@gsnFrame    = False
        res@gsnScale    = True
        res@gsnMaximize = True

        res@vpWidthF    = 0.8     ; Change aspect ratio such that
        res@vpHeightF   = 0.4     ; boxes are square

;---Set the min/max for X axis
	res@trXMinF                 = 0 
	res@trXMaxF                 = ncols
	res@trYMinF                 = 0
	res@trYMaxF                 = nrows

;---Turn on X and Y grid lines
        res@tmXMajorGrid            = True
        res@tmYMajorGrid            = True

;---Turn off tick marks only (not the labels)
	res@tmXBMajorOutwardLengthF = 0.
	res@tmXBMajorLengthF        = 0.
	res@tmYLMajorOutwardLengthF = 0.
	res@tmYLMajorLengthF        = 0.

;---Turn off top and right tickmarks and labels
	res@tmXTOn                  = False
	res@tmYROn                  = False

;---Customize X and Y axis tickmark labels
	res@tmXBMode                = "Explicit"
	res@tmXBValues              = ispan(res@trXMinF,res@trXMaxF,1)
	res@tmXBLabels              = (/"A","B","C","D","E","F","G","H","I",\
                                        "J","K","L","M","N","O","P","Q","R",\
                                        "S","T","U"/)

	res@tmYLMode               = "Explicit"
	res@tmYLValues             = ispan(res@trYMinF,res@trYMaxF,1)
	res@tmYLLabels             = ispan(0,nrows,1)+"M"

	res@tmXBLabelFontHeightF   = 0.015
	res@tmYLLabelFontHeightF   = 0.015

        res@tiMainString           = "Boxes colored according to closest integer value"
        res@tiMainFontHeightF      = 0.028

;---Create a blank plot so gsn_add_polygon function can be used
	plot = gsn_csm_blank_plot(wks,res)

;---Fill each grid box according to which level value it is closest to.
        add_filled_boxes(wks,plot,data,levels,colors)

        draw(plot)
        frame(wks)

;---Add text strings and labelbar and draw plot again
        add_text_strings(wks,plot,data)
        add_labelbar(wks,plot,colors,""+levels)
        draw(plot)
        frame(wks)
end
