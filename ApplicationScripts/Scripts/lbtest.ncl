;***********************************************************************;
undef("create_test_labelbar")
function gsn_create_test_labelbar(wks:graphic, nbox:integer, labels:string, \
                                  lbres:logical )
local res2, lbres, wksname
begin
    lbid = create "labelbar" labelBarClass wks
      "vpWidthF"       : 0.88
      "vpHeightF"      : 0.02
      "lbBoxCount"     : nbox
      "lbLabelStrings" : labels
      "lbAutoManage"   : False
      "lbFillColors"   : lbres@lbFillColors
    end create

    attsetvalues_check(lbid,lbres)
    return(lbid)
end

begin
  levels  = ispan(1,10,1)
  nlevels = dimsizes(levels)
  labels  = "" + levels
  colors  = span_color_rgba("WhViBlGrYeOrRe",nlevels+1)

  wks = gsn_open_wks("x11","lbtest")

  nboxes = dimsizes(colors(:,0))

  lbres                    = True          ; labelbar only resources                                          
  lbres@lbOrientation      = "horizontal"
  lbres@lbFillColors       = colors
  lbres@lbMonoFillColor    = False
  lbres@lbMonoFillPattern  = True
  lbres@lbLabelFontHeightF = 0.008
  lbres@lbLabelJust        = "CenterCenter"  ; left justify labels                                            
  lbres@lbLabelAlignment   = "interioredges"
  lbid2 = gsn_create_test_labelbar(wks,nboxes,labels,lbres)

  draw(lbid2)
  frame(wks)
end
