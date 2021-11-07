@echo off
rmdir /s /q Build
pyro -i SE-Chickens.ppj
pyro -i SE-HideChildren.ppj
pyro -i LE-Chickens.ppj
pyro -i LE-HideChildren.ppj
pause