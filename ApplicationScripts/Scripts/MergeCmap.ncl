;************************************************************
; Sylvia Murphy
; will merge two standard colormaps into a single colormap

undef("MergeCmap")
function MergeCmap(wks:graphic,cmap1:string,cmap2:string)

begin

  gsn_define_colormap(wks,cmap1)
  getvalues wks
    "wkColorMap"    : map1              ; get list of rgb values
    "wkColorMapLen" : nclr1             ; get size of color map    
  end getvalues

  gsn_define_colormap(wks,cmap2)
  getvalues wks
    "wkColorMap"    : map2 
    "wkColorMapLen" : nclr2    
  end getvalues
  
 
  newcmap = new((/nclr1+nclr2,3/),typeof(map1)) 

  newcmap(0:nclr1-1,:)           = map1
  newcmap(nclr1+2:nclr1+nclr2-1,:) = map2(2:,:)

  return(newcmap)
end
;*******************************************************************
