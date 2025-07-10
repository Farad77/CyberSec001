# Installation complète des outils de cybersécurité
Write-Host "=== Installation des outils de cybersécurité ===" -ForegroundColor Green

# Configuration du clavier français
Write-Host "Configuration du clavier français..." -ForegroundColor Yellow
try {
    $FrenchLanguage = New-WinUserLanguageList "fr-FR"
    Set-WinUserLanguageList $FrenchLanguage -Force
    Set-WinUILanguageOverride -Language "fr-FR"
    Set-WinDefaultInputMethodOverride -InputTip "040C:0000040C"
    Set-WinSystemLocale -SystemLocale "fr-FR"
    Set-WinHomeLocation -GeoId 84  # France
    Write-Host "✓ Clavier français configuré" -ForegroundColor Green
} catch {
    Write-Host "⚠ Erreur configuration clavier: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Installation de Chocolatey
Write-Host "Installation de Chocolatey..." -ForegroundColor Yellow
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "✓ Chocolatey installé" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur installation Chocolatey: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Actualiser les variables d'environnement
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Liste des outils à installer
$tools = @(
    @{Name="7zip"; Package="7zip"},
    @{Name="Google Chrome"; Package="googlechrome"},
    @{Name="Mozilla Firefox"; Package="firefox"},
    @{Name="Visual Studio Code"; Package="vscode"},
    @{Name="Notepad++"; Package="notepadplusplus"},
    @{Name="Wireshark"; Package="wireshark"},
    @{Name="Nmap"; Package="nmap"},
    @{Name="Burp Suite Community"; Package="burp-suite-free-edition"},
    @{Name="OWASP ZAP"; Package="zap"},
    @{Name="Process Hacker"; Package="processhacker"},
    @{Name="SysInternals Suite"; Package="sysinternals"},
    @{Name="TCPView"; Package="tcpview"},
    @{Name="NetworkMiner"; Package="networkminer"},
    @{Name="Git"; Package="git"},
    @{Name="Python 3"; Package="python3"},
    @{Name="Node.js"; Package="nodejs"},
    @{Name="VLC Media Player"; Package="vlc"},
    @{Name="PuTTY"; Package="putty"},
    @{Name="WinSCP"; Package="winscp"},
    @{Name="HashCheck"; Package="hashcheck"}
)

Write-Host "Installation des outils via Chocolatey..." -ForegroundColor Yellow
Write-Host "Nombre d'outils à installer: $($tools.Count)" -ForegroundColor Cyan

$successful = 0
$failed = 0

foreach ($tool in $tools) {
    try {
        Write-Host "Installation de $($tool.Name)..." -ForegroundColor Yellow
        $result = choco install $tool.Package -y --ignore-checksums 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $($tool.Name) installé avec succès" -ForegroundColor Green
            $successful++
        } else {
            Write-Host "✗ Échec de l'installation de $($tool.Name)" -ForegroundColor Red
            Write-Host "Détails: $result" -ForegroundColor Gray
            $failed++
        }
    } catch {
        Write-Host "✗ Erreur lors de l'installation de $($tool.Name): $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

# Créer les raccourcis sur le bureau
Write-Host "Création des raccourcis sur le bureau..." -ForegroundColor Yellow
$Desktop = [System.Environment]::GetFolderPath('Desktop')
$WshShell = New-Object -ComObject WScript.Shell

# Raccourcis des outils principaux
$shortcuts = @(
    @{Name="Wireshark"; Path="C:\Program Files\Wireshark\Wireshark.exe"},
    @{Name="Burp Suite"; Path="C:\Users\Public\Desktop\Burp Suite Community Edition.lnk"},
    @{Name="OWASP ZAP"; Path="C:\Program Files\ZAP\Zed Attack Proxy\zap.exe"},
    @{Name="Process Hacker"; Path="C:\Program Files\Process Hacker 2\ProcessHacker.exe"},
    @{Name="NetworkMiner"; Path="C:\ProgramData\chocolatey\lib\networkminer\tools\NetworkMiner.exe"}
)

foreach ($shortcut in $shortcuts) {
    try {
        if (Test-Path $shortcut.Path) {
            $lnk = $WshShell.CreateShortcut("$Desktop\$($shortcut.Name).lnk")
            $lnk.TargetPath = $shortcut.Path
            $lnk.Save()
            Write-Host "✓ Raccourci $($shortcut.Name) créé" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠ Erreur création raccourci $($shortcut.Name): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Créer un dossier de travail
$WorkDir = "C:\CyberWork"
if (!(Test-Path $WorkDir)) {
    New-Item -ItemType Directory -Path $WorkDir -Force
    Write-Host "✓ Dossier de travail créé: $WorkDir" -ForegroundColor Green
}

# Créer un fichier de documentation
$DocContent = @"
=== OUTILS DE CYBERSÉCURITÉ INSTALLÉS ===

Cette VM contient les outils suivants pour la formation en cybersécurité :

ANALYSE RÉSEAU :
---------------
- Wireshark : Analyseur de protocoles réseau
- Nmap : Scanner de ports et découverte réseau
- NetworkMiner : Analyseur de trafic réseau forensique
- TCPView : Visualisation des connexions TCP/UDP en temps réel

TESTS DE SÉCURITÉ :
------------------
- Burp Suite Community : Proxy d'interception web
- OWASP ZAP : Scanner de vulnérabilités web

ANALYSE SYSTÈME :
----------------
- Process Hacker : Gestionnaire de processus avancé
- SysInternals Suite : Outils système Microsoft

DÉVELOPPEMENT :
--------------
- Visual Studio Code : Éditeur de code
- Git : Contrôle de version
- Python 3 : Langage de programmation
- Node.js : Runtime JavaScript

UTILITAIRES :
------------
- 7zip : Archiveur de fichiers
- Notepad++ : Éditeur de texte avancé
- PuTTY : Client SSH/Telnet
- WinSCP : Client SFTP/SCP
- HashCheck : Vérification d'intégrité de fichiers

DOSSIERS IMPORTANTS :
--------------------
- C:\CyberWork\ : Dossier de travail principal
- C:\CyberTools\ : Scripts et outils personnalisés

NAVIGATION VPN :
---------------
Utilisez le raccourci "Basculement VPN" pour changer de configuration client.

Installation terminée le : $(Get-Date)
Outils installés avec succès : $successful
Échecs d'installation : $failed
"@

$DocContent | Out-File -FilePath "$Desktop\Outils-Installés.txt" -Encoding UTF8
Write-Host "✓ Documentation créée sur le bureau" -ForegroundColor Green

Write-Host ""
Write-Host "=== RÉSUMÉ DE L'INSTALLATION ===" -ForegroundColor Cyan
Write-Host "Outils installés avec succès : $successful" -ForegroundColor Green
Write-Host "Échecs d'installation : $failed" -ForegroundColor $(if($failed -gt 0){"Red"}else{"Green"})
Write-Host "Installation terminée !" -ForegroundColor Green