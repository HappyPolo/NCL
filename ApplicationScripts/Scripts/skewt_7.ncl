;**************************************************
; skewt_7.ncl
;
; Concepts illustrated:
;   - Reading ds336.0 netCDF files
;   - Specifying desired station id(s) and extracting desired data
;   - Changing non-standard units associated with the time coordinate variable
;   - Adding an _FillValue attribute to a variable
;   - Looping over files, stations and times
;   - Drawing Skew-T plots 
;   - Creating simple ascii (text) files of each sounding
;**************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"

  diri    = "./"                                       ; directory containing input file(s)
  fili    = systemfunc("cd "+diri+" ; ls Upperair*nc") ; all file names
  nfili   = dimsizes(fili)                             ; number of files to be used
  print(fili)

  idkey   = (/78016/)                 ; desired station(s): (/ id1, id2,.../)
  nidkey  = dimsizes(idkey)
                                      ; user names for station(s), one per 'idkey'
  idName  = (/"Bermuda"/)             ; used in plots and text files
 
  txtFile = True                      ; Is a text file to be created? True=>>Yes, False==>No
  txtDir  = "./"                      ; directory for text files if txtFile=True
  
  pltType = "png"                     ; png, ps, eps, pdf, x11
  pltDir  = "./"                      ; directory for plots
 
;====================>                ; end of generic specifications
                                      ; skewT options
  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False

  dataOpts           = True           ; options describing data and ploting
  dataOpts@HspdHdir  = True           ; wind speed and dir [else: u,v]
  
                                      ; text file header(s)
  varHead = [/"     P      HGT     T     TDEW    WSPD    WDIR  "/]
  untHead = [/"    mb       m      C       C      m/s          "/]


  do nf=0,nfili-1                            ; loop over each file
     f        = addfile(diri+fili(nf), "r")
     idnum   := f->wmoStaNum
     synTime := f->synTime
     synTime@units = "seconds since 1970-1-1 00:00:0.0" ; replace: "seconds since (1970-1-1 00:00:0.0)"
     ymdh    := cd_calendar(synTime, -3)
     print(ymdh)
  
    do id=0,nidkey-1                         ; loop over each station
       ii     := ind(idnum.eq.idkey(id))     ; may be multiple times (eg,00,06,12,18)
       nii     = dimsizes(ii)                ; for each station

       ii0     = ii(0)                       ; convenience: use info associated with 1st
       staLat  = f->staLat(ii0)
       staLon  = f->staLon(ii0)
       staElev = f->staElev(ii0)
       staName = tostring(f->staName(ii0,:)) ; char staName(recNum, staNameLen)
       
      do i=0,nii-1                           ; loop over time(s) (eg, 00,06,12,18)
                                             ; for current station
         if (.not.ismissing(ii(i))) then
             iii    = ii(i)                  ; convenience
	     
             prMan  = f->prMan(iii,:)        ; 'Man' =" Mandatory levels
             wdMan  = f->wdMan(iii,:)        ; (recNum, manLevel) ==> (:) ==> hPa 
             wsMan  = f->wsMan(iii,:) 
	     htMan  = f->htMan(iii,:)
 
             tpMan  = f->tpMan(iii,:)
             tdMan  = f->tdMan(iii,:)
 	     
	     tpMan  = tpMan-273.15           ; skewT expects degC
   	     tpMan@units = "degC"
	     
	     tdMan  = tpMan-tdMan
	     tdMan@units = "degC"
	     	     
             numSigW= f->numSigW(iii)        ; 'SigW' = Significant Wind levels
             numSigW@_FillValue = 99999      ; _FillValue not on file
           
             if (.not.ismissing(numSigW) .and. numSigW.gt.0) then
                 dataOpts@PlotWindH = True                ; plot wind barbs at height lvls
                 dataOpts@Height    = f->htSigW(iii,:)    ; height of wind reports
                 dataOpts@Hspd      = f->wsSigW(iii,:)    ; speed [or u component]
                 dataOpts@Hdir      = f->wdSigW(iii,:)    ; dir   [or v component]
             else
                 dataOpts@PlotWindH = False      ; No pibal winds to plot
             end if

             pltName = "skewt."+idName(id)+"_"+idkey(id)+"."+ymdh(iii)  ; eg: skewt.Bermuda_78016.2013030612.png
	     pltPath = pltDir+pltName
	     wks     = gsn_open_wks (pltType, pltPath)
	     
             skewtOpts@tiMainString    = idName(id)+": "+idkey(id)+":  "+ymdh(iii)

	     skewt_bkgd = skewT_BackGround (wks, skewtOpts)
             skewt_data = skewT_PlotData   (wks, skewt_bkgd, prMan,tpMan,tdMan,htMan \
                                    , wsMan,wdMan, dataOpts)
             draw (skewt_bkgd)
             draw (skewt_data)
             frame(wks)
	     
	     if (txtFile) then
  	         varList = [/prMan, htMan, tpMan, tdMan, wsMan, wdMan/]
	         txtName = idName(id)+"_"+ymdh(iii)+".ManLevels.txt"    ; eg: Bermuda_2013030612.ManLevels.txt
		 txtPath = txtDir+txtName
	         write_table(txtPath, "w", varHead, "%s")   ; "w" => create or overwrite
	         write_table(txtPath, "a", untHead, "%s")   ; "a" => append
	         write_table(txtPath, "a", varList, "%7.0f%7.0f%7.1f%7.1f%7.1f%7.0f")
	     end if
	     
         end if  ; .not.ismissing(ii(i))
      end do     ; i     (time)

    end do       ; id    (station id)
  end do         ; nf    (file)
