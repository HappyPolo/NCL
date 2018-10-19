;================================================;
;  task_parallelism_driver_1.ncl
;================================================;
;
; Concepts illustrated:
;   - Calling a python script from a NCL script
;
;================================================;
;
script_names = "script1.ncl script2.ncl script3.ncl script4.ncl script5.ncl" ; listing of scripts to be submitted, separated by a space

system("python task_parallelism_1.py "+script_names)    ; call python script that will launch scripts specified 
                                                        ; in script_names

