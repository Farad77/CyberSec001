@echo off
title TP Phishing - Simulateur de Client Mail
color 0A

echo.
echo ========================================
echo    TP PHISHING - SIMULATEUR CLIENT MAIL
echo ========================================
echo.

REM Vérifier si Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Python n'est pas installé ou n'est pas dans le PATH
    echo.
    echo Veuillez installer Python depuis https://www.python.org/
    echo.
    pause
    exit /b 1
)

echo Python detecte : 
python --version

REM Vérifier si Flask est installé
python -c "import flask" 2>nul
if errorlevel 1 (
    echo.
    echo Flask n'est pas installé. Installation en cours...
    echo.
    pip install flask
    if errorlevel 1 (
        echo ERREUR: Impossible d'installer Flask
        pause
        exit /b 1
    )
)

echo Flask detecte : OK
echo.

REM Changer vers le répertoire du script
cd /d "%~dp0"

echo Demarrage du serveur TP Phishing...
echo.
echo Interface disponible sur :
echo   - http://localhost:5000
echo   - Gmail: http://localhost:5000/gmail  
echo   - Outlook: http://localhost:5000/outlook
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur
echo.

REM Lancer l'application Flask
python app.py

pause