@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Zuzalauncher

:: Запрос прав администратора
net session >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "ROOT=%~dp0"
set "LIST=%ROOT%listis"
set "BIN=%ROOT%bin"
set "PROFILES=%BIN%\profiles"
set "GENERAL=%LIST%\list-general.txt"

if not exist "%LIST%\" md "%LIST%"
if not exist "%BIN%\" md "%BIN%"
if not exist "%PROFILES%\" md "%PROFILES%"
if not exist "%GENERAL%" (
    >"%GENERAL%" echo # Добавляйте домены по одному на строку, например:
    >>"%GENERAL%" echo example.com
)

:MENU
cls
echo ==============================
echo          ZUZALAUNCHER
echo     version 1.9.7
echo ==============================
echo 1. Выбрать альт
echo 2. Удалить альт
echo 3. Проверить выбранный альт
echo 4. Проверить домены из list-general
echo 5. DNS
echo 6. Открыть папки
echo 7. Выход
echo.
choice /c 1234567 /n /m "Выберите пункт: "

if errorlevel 7 goto END
if errorlevel 6 goto OPENFOLDERS
if errorlevel 5 goto DNSMENU
if errorlevel 4 goto CHECKDOMAINS
if errorlevel 3 goto CHECKALT
if errorlevel 2 goto DELETEALT
if errorlevel 1 goto CHOOSEALT

:CHOOSEALT
cls
echo Выберите альт:
call :SHOWALTS
choice /c 123456789 /n /m "Номер: "
set "N=%errorlevel%"
>"%PROFILES%\active.txt" echo alt%N%
>"%PROFILES%\alt%N%.txt" echo Локальный профиль alt%N%
echo Выбран alt%N%.
pause
goto MENU

:DELETEALT
cls
echo Какой альт сбросить?
call :SHOWALTS
choice /c 123456789 /n /m "Номер: "
set "N=%errorlevel%"
if exist "%PROFILES%\alt%N%.txt" del "%PROFILES%\alt%N%.txt"
if exist "%PROFILES%\active.txt" (
    findstr /x /i "alt%N%" "%PROFILES%\active.txt" >nul
    if not errorlevel 1 del "%PROFILES%\active.txt"
)
echo alt%N% сброшен.
pause
goto MENU

:CHECKALT
cls
if exist "%PROFILES%\active.txt" (
    set /p ACTIVE=<"%PROFILES%\active.txt"
    echo Выбран локальный профиль: %ACTIVE%
) else (
    echo Альт не выбран.
)
pause
goto MENU

:CHECKDOMAINS
cls
echo Домены указывайте в "%GENERAL%"
echo По одному домену на строку, например: example.com
echo Не указывайте https:// или путь страницы.
echo.
echo Проверка DNS:
echo.

for /f "usebackq eol=# tokens=1" %%D in ("%GENERAL%") do (
    if not "%%D"=="" (
        echo ===== %%D =====
        nslookup %%D
        echo.
    )
)

echo Очищаю DNS-кэш Windows...
ipconfig /flushdns
echo.
echo Проверка завершена. Попробуйте открыть сайты снова.
echo Это не гарантирует доступ, если проблема не связана с DNS.
pause
goto MENU

:DNSMENU
cls
echo ==============================
echo              DNS
echo ==============================
echo 1. Установить DNS 208.67.222.222
echo 2. Вернуть автоматический DNS
echo 3. Назад
echo.
choice /c 123 /n /m "Выберите пункт: "
if errorlevel 3 goto MENU
if errorlevel 2 goto DNS_AUTO
if errorlevel 1 goto DNS_SET

:DNS_SET
cls
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$a = Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1; if ($a) { Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses '208.67.222.222'; Write-Host ('DNS установлен для адаптера: ' + $a.Name) } else { Write-Host 'Активный сетевой адаптер не найден.'; exit 1 }"
ipconfig /flushdns
pause
goto DNSMENU

:DNS_AUTO
cls
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$a = Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1; if ($a) { Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses; Write-Host ('Автоматический DNS восстановлен для адаптера: ' + $a.Name) } else { Write-Host 'Активный сетевой адаптер не найден.'; exit 1 }"
ipconfig /flushdns
pause
goto DNSMENU

:OPENFOLDERS
start "" "%LIST%"
start "" "%BIN%"
goto MENU

:SHOWALTS
for /l %%I in (1,1,9) do echo %%I. alt%%I
exit /b

:END
endlocal
exit /b
echo "# -" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/dfsfsdfsdfsdfgsdfds/-.git
git push -u origin main
git remote add origin https://github.com/dfsfsdfsdfsdfgsdfds/-.git
git branch -M main
git push -u origin main