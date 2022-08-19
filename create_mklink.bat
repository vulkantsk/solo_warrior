@echo off
@REM Благодарность dark123us
@REM название аддона
set NAMECUSTOM=solo_warrior
@REM гит папка вашего аддона
set PATHGIT=D:\documents\github\solo_warrior
@REM путь к доте
set PATHGAME=D:\games\steam\steamapps\common\dota 2 beta
@REM добавочный путь для папки доты
set SUFFIX=\content\dota_addons\
set SUFFIX2=\game\dota_addons\
@REM добавочный путь для папки гита
set PREFIX=\content\
set PREFIX2=\game\
@REM вывод инфо
echo %PATHGIT%
echo %PATHGAME%
echo -----------
echo %PATHGAME%%SUFFIX%%NAMECUSTOM%
echo %PATHGAME%%SUFFIX2%%NAMECUSTOM%
echo -----------
@REM создаем структуру в гит папке
mkdir "%PATHGIT%%PREFIX%"
mkdir "%PATHGIT%%PREFIX2%"
@REM связываем папку гит и аддон
mklink /J "%PATHGIT%%PREFIX%%NAMECUSTOM%" "%PATHGAME%%SUFFIX%%NAMECUSTOM%"
mklink /J "%PATHGIT%%PREFIX2%%NAMECUSTOM%" "%PATHGAME%%SUFFIX2%%NAMECUSTOM%"

pause
