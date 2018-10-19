#!/bin/bash
ncl air_tmp_201801.ncl #运行ncl脚本，生成bash.pdf
convert  -delay 50 tmp.pdf tmp.gif # 转换
#rm bash.pdf
exit 0
