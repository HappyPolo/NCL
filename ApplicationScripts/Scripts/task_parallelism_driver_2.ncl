;================================================;
;  task_parallelism_driver_1.ncl
;================================================;
;
; Concepts illustrated:
;   - Calling a python script from a NCL script
;   - Setting an environmental variable
;
;================================================;
;

wait_time = 10.              ; option that controls the 
num_tasks = 4                ; number of tasks that can run at once
outdir = "/work/project1/"   ; directory where NCL script output will be located
output = "png"               ; type of workstation to output to in NCL scripts. 

script_names = "script1.ncl script2.ncl script3.ncl script4.ncl script5.ncl" ; listing of scripts to be submitted, separated by a space

envvar_str = "   export OUTDIR="+outdir+";   export OUTPUT_TYPE="+output+";   "+\    ; set environmental variables for use in 
             "export WAIT_TIME="+wait_time+";   export MAX_TASKS="+num_tasks+";"     ; task_parallelism_2.ncl and script_list scripts.

system(envvar_str+" python task_parallelism_2.py "+script_names)	     ; call python script that will launch scripts specified 
                                                                             ; in script_names

