#!/bin/bash
ncl bash.ncl #运行ncl脚本，生成bash.pdf
convert -delay 100 bash.pdf bash.gif # 转换
rm bash.pdf
exit 0
