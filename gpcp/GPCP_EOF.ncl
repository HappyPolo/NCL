;利用GPCP数据作EOF分析
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  
  f                               =addfile("/mnt/e/data/precip.mon.mean.nc", "r")
  prc                             =f->precip(0:360,:,:)

  lats                            =10
  latn                            =50
  lone                            =140
  lonw                            =60

  yrstrt                          =1979
  yrlast                          =2008

  season                          ="MAM" ;3、4、5月

  neof                            =3
  optEof                          =True
  optEof@jopt                     =0
  optEof@jopt                     =1

  optETS                          =False

  time                            =prc&time
  YYYYMM                          =cd_calendar(time,-1)
  ;print(YYYYMM)
  
  YYYY                            =floattointeger(YYYYMM/100)
  ;print(YYYY)
  ;prc                             =f->precip(YYYY,:,:)
;printVarSummary(prc)

  prc                             =lonFlip(prc)
printVarSummary(prc)


  PRC                             =month_to_season(prc, season)
  nyrs                            =dimsizes(PRC&time)
printVarSummary(PRC)
;创建权重系数
  rad                             =get_d2r("float")
  clat                            =f->lat
  clat                            =sqrt(cos(rad*clat))

  wPRC                            =PRC
  wPRC                            =PRC*conform(PRC,clat,1)
  wPRC@long_name                  ="Wgt:"+wPRC@long_name

  xw                              =wPRC(time|:,{lat|lats:latn},{lon|lonw:lone})

  eof                             =eofunc_n_Wrap(xw,neof,optEof,0)
  eof_ts                          =eofunc_ts_n_Wrap(xw,eof,optETS,0)

  printVarSummary(eof)
  printVarSummary(eof_ts)

  dimxw                           =dimsizes(xw)
  mln                             =dimxw(1)
  sumWgt                          =mln*sum(clat({lat|lats:latn}))
  eof_ts                          =eof_ts/sumWgt

  yyyymm                          =cd_calendar(eof_ts&time,-2)/100
;print(yyyymm)
  yrfrac                          =yyyymm_to_yyyyfrac(yyyymm,0.0)


  wks                             =gsn_open_wks("x11", "GPCP_EOF")
  res                             =True

end