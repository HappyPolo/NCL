#!/bin/bash
ncl pres_vec.ncl #运行ncl脚本，生成bash.pdf
convert  -delay 50 v-w.pdf v-w.gif # 转换
#rm bash.pdf
exit 0
