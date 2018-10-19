#!/bin/bash
ncl geo_850.ncl #运行ncl脚本，生成bash.pdf
convert  -delay 50 geo_500.pdf geo_500.gif # 转换
#rm bash.pdf
exit 0
