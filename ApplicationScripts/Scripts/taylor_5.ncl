;*********************************************************************
; taylor_5.ncl
;*********************************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;
; This file still has to be loaded manually
load "./taylor_metrics_table.ncl"

begin
	vars = (/"RESTOM","RESSURF","CLDTOT_ISCCP","FLDS_ISCCP","FLNS_ISCCP" \
                ,"FLUT_CERES","FLUT_ERBE","FLUTC_CERES","FLUTC_ERBE"         \
                ,"FSDS_ISCCP","FSNS_ISCCP","FSNTOA_CERES","FSNTOA_ERBE"      \
                ,"FSNTOAC_CERES","FSNTOAC_ERBE","LHFLX_ECMWF","LWCF_CERES"   \
                ,"LWCF_ERBE","PRECT_GPCP","PREH2O_NVAP","PSL_NCEP"           \
                ,"RESTOA_ERBE","SHFLX_NCEP","STRESS_MAG_ERS","SWCF_CERES"    \
                ,"SWCF_ERBE","TREFHT_LEGATES","TS_NCEP","TS_LAND_NCEP"       \
                ,"U_200_NCEP","Z3_500_NCEP"/)
        nVar    = dimsizes(vars)

	opt = True
	opt@pltType = "png"
	opt@color0  = "dodgerblue"
; *******************************************************************
; Table 1
; *******************************************************************
	cases1       = (/"Case A", "Case B"/)	
	season1      = (/"ANN","DJF","JJA"/)
        nCase        = dimsizes( cases1  )
        nSea         = dimsizes( season1 )
        tabValues1   = random_normal( 1.0, 0.25, (/nCase, nSea, nVar/) )

        taylor_metrics_table("taylor.000001", vars, cases1, season1, tabValues1, opt)

; *******************************************************************
; Table 2
; *******************************************************************
	cases2       = (/"Case A", "Case B", "Case C"/)
	season2      = (/"ANN","DJF","JJA","Nov-Mar"/)
        nCase        = dimsizes( cases2  )
        nSea         = dimsizes( season2 )
        tabValues2   = random_normal( 1.0, 0.25, (/nCase, nSea, nVar/) )

        taylor_metrics_table("taylor.000002", vars, cases2, season2, tabValues2, opt)

; *******************************************************************
; Table 3
; *******************************************************************
	cases3       = (/"Case A", "Case B", "Case C", "Case D", "Case E"/)
	season3      = (/"ANN","DJF","JJA","Nov-Mar"/)
        nCase        = dimsizes( cases3  )
        nSea         = dimsizes( season3 )
        tabValues3   = random_normal( 1.0, 0.25, (/nCase, nSea, nVar/) )

        taylor_metrics_table("taylor.000003", vars, cases3, season3, tabValues3, opt)
	
; *******************************************************************
; Table 4
; *******************************************************************
	cases4       = (/"Case A", "Case B"/)	
	season4      = (/"J","F","M","A","M","J","J","A","S","O","N","D","ANN"/)
        var4         = vars
        nCase        = dimsizes( cases4  )
        nSea         = dimsizes( season4 )
        nVar         = dimsizes( var4    )
	table4       = random_normal( 1.0, 0.25,(/nCase, nSea, nVar/))

	taylor_metrics_table("taylor.000004", var4, cases4, season4, table4, opt)	
end 
