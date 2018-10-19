;*****************************************************
; taylor_7.ncl     **VERY BASIC** Model-to-Model comparison
; Concepts illustrated:
;   - Create a function that handles data accees
;     - Some variables are not on the file(s). They must be created.
;     - Create the appropriate month/season/annual variable.
;     - If regridding were needed, it should be done within the function.
;   - Specify the desired variables, seasons and cases to be plotted.
;     - Preallocate arrays for statistics to be plotted.
;   - Loop over each and store the results 
;     - Call 'taylor_stats' to get the necessary statistics.
;   - Plot the results.
;*****************************************************
load "./taylor_diagram.ncl"
load "./taylor_metrics_table.ncl"
    
;*****************************************************
; User function to read user specified data.
;*****************************************************
undef("getData")
function getData (f:file          \  ; file reference [pointer]
                 ,varName:string  \  ; variable name
                 ,monsea:string   \  ; month/season name
                 ,opt:logical)    \  ; opt arguments [not used]
;-----------------------------------------------------
;---READ FULL CLIMATOLOGY (12,:,:)
;-----------------------------------------------------
local vFlag, vClm, vClmx, vClmy
begin
    vFlag = False                    ; flag if variable found
    
;---These variables requires 'special' steps

    if (varName.eq."PRC") then
        vClm   = f->PRECL 
        vClm   = vClm + f->PRECC
        vClm@long_name = "Total prc: (PRECL + PRECC)"
        vFlag  = True
    end if

    if (varName.eq."U300") then
        vClm   = f->U(:,{300},:,:)
        vClm@long_name = "U300"
        vFlag  = True
    end if

    if (varName.eq."LHFLX_TropPac") then
        vClm   = f->LHFLX(:,{-10:10},{150:260})
        vClm@long_name = vClm@long_name+": 10S-10N , 150-260"
        vFlag  = True
    end if

    if (varName.eq."STRESS_SFC") then
        vClmx  = f->TAUX
        vClmy  = f->TAUY
        vClm   = sqrt(vClmx^2 + vClmy^2)
        vClm@long_name = "Total Surface Stress"
        vClm@units     = vClmx@units
        vFlag  = True
    end if

;---Variables on file that need no 'special' treatment

    if (isfilevar(f, varName) .and. .not.vFlag) then
        vClm = f->$varName$    
        vFlag  = True
    end if

    if (.not.vFlag) then
        print("-------------------------------------------------")
        print("-->TAYLOR: getDataUser: "+varName+" not found <--")
        print("-------------------------------------------------")
        vClm = 1e20
        vClm@_FillValue = 1e20
        return(vClm)
    end if             
                                      ; select appropriate month/season
                                      ; perform averaging ... if needed
    month = (/"JAN","FEB","MAR","APR","MAY","JUN" \
             ,"JUL","AUG","SEP","OCT","NOV","DEC" /)
 
    sea3  = (/"DJF","JFM","FMA","MAM","AMJ","MJJ" \
             ,"JJA","JAS","ASO","SON","OND","NDJ" /)
 
    i3    = (/(/12,1,2/),(/1,2,3/),(/2,3,4/),(/3,4,5/) \ 
             ,(/ 4,5,6/),(/5,6,7/),(/6,7,8/),(/7,8,9/) \ 
             ,(/ 8,9,10/),(/9,10,11/),(/10,11,12/),(/11,12,1/) /)
    i3    = i3-1    ; NCL is zero based
 
    if (any(month.eq.monsea)) then
        i    = ind(month.eq.monsea)
        data = vClm(i,:,:)          ; extract specified month
        return( data )
    end if
 
   ;dNam  = getvardims ( vClm )     ; get dimension names
 
    if (monsea.eq."ANN") then
        data = dim_avg_n_Wrap( vClm, 0 )
        data@long_name = "ANN: "+vClm@long_name
        return( data )
    end if
 
    i  = ind(sea3.eq.monsea)
    if (.not.ismissing(i)) then
        data = dim_avg_n_Wrap( vClm(i3(i,:),:,:), 0 )
        data@long_name = monsea+": "+vClm@long_name
        return( data )
    end if

    return(data)
end

;*****************************************************
;               MAIN DRIVER  
;*****************************************************

  CNTL_DIR      = "./b30.081/"
  TEST_DIR      = "./b30.081_di/"

  CNTL_CASE    =    "b30.081"                                ; names
  TEST_CASE    = (/ "b30.081_di" /)                          ; one or more TEST cases 

  SEASONS      = (/ "DJF", "JJA", "ANN" /) 
  VAR_TEST     = (/ "PSL", "CLDTOT" , "FLNTC" \
                   ,"PRC", "STRESS_SFC", "U300", "LHFLX_TropPac" /)
  CASES        = (/ TEST_CASE /)        ; possibly rename if TEST_CASE is long          

                                        ; OPTIONAL
  TEST_MARKERS = (/ 16 /)               ; one for each TEST_CASE
  TEST_COLORS  = (/ "magenta" /)     
  PRINT_MINMAX = True
  PLOT_TYPE    = "png"


  nSeason     = dimsizes( SEASONS )
  nVar        = dimsizes( VAR_TEST )
  nCase       = dimsizes( CASES )
                                        ; preallocate 
  ratio       = new ((/nCase, nVar/), "double" )  
  cc          = new ((/nCase, nVar/), "double" ) 
  bias        = new ((/nCase, nVar/), "double" ) 
  table       = new ((/nCase,nSeason,nVar/), typeof(ratio) )

;----------------------------------------------
; Generate one Taylor diagram per season
;----------------------------------------------
    CNTL_FILE   = CNTL_CASE+"_MONTHS_climo.nc"
    fc = addfile(CNTL_DIR+CNTL_FILE, "r") ; open control file with monthly files   
    gw = fc->gw                           ; gw(lat)

    do ns=0,nSeason-1                     ; loop over seasons
     do nc=0,nCase-1                      ; loop over all the test cases       
        ft = addfile(TEST_DIR(nc)+TEST_CASE(nc)+"_MONTHS_climo.nc", "r") ;      case/test
      do nv=0,nVar-1
                                          ; READ DATA
         refVar := getData( fc, VAR_TEST(nv), SEASONS(ns), False ) 
         tstVar := getData( ft, VAR_TEST(nv), SEASONS(ns), False ) 
 
         if (PRINT_MINMAX) then
             printVarSummary(refVar)
             printMinMax(refVar , True )
             print("===")
             printVarSummary(tstVar)
             printMinMax(tstVar , False)
             print("===")
         end if

         if (VAR_TEST(nv).eq."LHFLX_TropPac") then 
             stat_taylor = taylor_stats(tstVar, refVar, gw({-10:10}), 0)
         else
             stat_taylor     = taylor_stats(tstVar, refVar, gw, 0)
         end if
    
         cc(nc,nv)       = stat_taylor(0)
         ratio(nc,nv)    = stat_taylor(1)
         bias(nc,nv)     = stat_taylor(2)
         table(nc,ns,nv) = ratio(0,nv)

      end do                             ; end VARIABLE loop
     end do                              ; end CASE loop

     plot_root_name   = "taylor_"+SEASONS(ns)
     if (isvar("PLOT_TYPE")) then
         plot_type    = PLOT_TYPE
     else
         plot_type    = "png"
     end if
     plot_file        = plot_root_name +"."+plot_type

     opt              = True
     opt@varLabels    = VAR_TEST
     opt@varLabelsYloc= 0.70
     opt@caseLabels   = CASES
     opt@tiMainString = SEASONS(ns)+": ref case="+CNTL_CASE

     if (isvar("TEST_MARKERS")) then
         opt@Markers  = TEST_MARKERS 
     end if
     if (isvar("TEST_COLORS")) then
         opt@Colors   = TEST_COLORS
     end if
 
     wks              = gsn_open_wks(plot_type,plot_root_name) 
     plot             = taylor_diagram(wks,ratio,cc,opt)

    end do                              ; end SEASON loop

    tt_opt        = True
    tt_opt@pltType= "png"               ; "eps" [default], "pdf", "ps"
                                        ; "png", "gif" [if you have ImageMajik 'convert']
    taylor_metrics_table("taylor_7.table", VAR_TEST, CASES ,SEASONS, table, tt_opt)
