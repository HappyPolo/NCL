#!/bin/bash
ncl tmp_850.ncl #运行ncl脚本，生成bash.pdf
convert  -delay 50 tmp_850.pdf tmp_850.gif # 转换
#rm bash.pdf
exit 0
