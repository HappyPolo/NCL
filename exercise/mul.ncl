;批
量读取
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
   
   yyyy                      =ispan(1979,2015,1)

   diro                      ="/mnt/e/data/GPCP_precip_DATA/"
   filos                     =systemfunc("ls"+diro+"*.nc")
   f                         =addfiles(filos,"r")
   ListSetType(f,"join")
   prcip                     =f[:]->Precip
   printVarSummary(precip)

end