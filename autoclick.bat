@echo off

:loop

nircmd setcursor 855 285
nircmd sendmouse left click

ping 127.0.0.1 -n 6 > nul

goto loop