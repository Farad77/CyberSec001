# Installation et configuration OpenVPN
Write-Host "=== Configuration VPN ===" -ForegroundColor Green

# 0. Configuration du clavier francais
Write-Host "Configuration du clavier francais..." -ForegroundColor Yellow
try {
    # Supprimer toutes les langues existantes et ajouter seulement le francais
    $FrenchLanguage = New-WinUserLanguageList "fr-FR"
    Set-WinUserLanguageList $FrenchLanguage -Force
    
    # Definir le francais comme langue d'affichage par defaut
    Set-WinUILanguageOverride -Language "fr-FR"
    
    # Configurer le clavier francais comme methode d'entree par defaut
    Set-WinDefaultInputMethodOverride -InputTip "040C:0000040C"
    
    # Forcer la mise a jour des parametres regionaux
    Set-WinSystemLocale -SystemLocale "fr-FR"
    Set-WinHomeLocation -GeoId 84  # France
    
    Write-Host "Clavier francais configure comme langue par defaut" -ForegroundColor Green
} catch {
    Write-Host "Erreur configuration clavier: $($_.Exception.Message)" -ForegroundColor Red
}

# 1. Téléchargement et installation OpenVPN
Write-Host "Installation d'OpenVPN..." -ForegroundColor Yellow
try {
    $url = "https://swupdate.openvpn.org/community/releases/OpenVPN-2.6.8-I001-amd64.msi"
    $output = "C:\temp\openvpn.msi"
    
    Write-Host "Création du dossier temp..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path C:\temp
    
    Write-Host "Téléchargement depuis $url..." -ForegroundColor Yellow  
    Invoke-WebRequest -Uri $url -OutFile $output
    
    Write-Host "Installation en cours..." -ForegroundColor Yellow
    $process = Start-Process msiexec.exe -Wait -ArgumentList '/i C:\temp\openvpn.msi /quiet /norestart' -PassThru
    Write-Host "Code de retour installation: $($process.ExitCode)" -ForegroundColor Yellow
    
    # Attendre que l'installation soit terminée
    Start-Sleep -Seconds 10
    
    # Vérifier l'installation
    if (Test-Path "C:\Program Files\OpenVPN\bin\openvpn-gui.exe") {
        Write-Host "✓ OpenVPN installé avec succès" -ForegroundColor Green
    } else {
        Write-Host "✗ OpenVPN non trouvé après installation" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "✗ Erreur installation OpenVPN: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Configuration du fichier VPN
Write-Host "Configuration du profil VPN..." -ForegroundColor Yellow
$ConfigPath = "C:\Program Files\OpenVPN\config"
$VagrantConfig = "C:\vagrant\config"

# Créer le dossier config si nécessaire
if (!(Test-Path $ConfigPath)) {
    New-Item -ItemType Directory -Path $ConfigPath -Force
}

# Copier le fichier de configuration VPN client1 par défaut
if (Test-Path "$VagrantConfig\client1.ovpn.txt") {
    Copy-Item "$VagrantConfig\client1.ovpn.txt" -Destination "$ConfigPath\client.ovpn" -Force
    Write-Host "Configuration VPN client1 copiee par defaut" -ForegroundColor Green
} else {
    Write-Host "Fichier client1.ovpn.txt non trouve" -ForegroundColor Red
    exit 1
}

# 3. Créer raccourci OpenVPN sur le bureau
Write-Host "Création du raccourci..." -ForegroundColor Yellow
try {
    $Desktop = [System.Environment]::GetFolderPath('Desktop')
    $WshShell = New-Object -ComObject WScript.Shell
    
    if (Test-Path "C:\Program Files\OpenVPN\bin\openvpn-gui.exe") {
        $Shortcut = $WshShell.CreateShortcut("$Desktop\OpenVPN.lnk")
        $Shortcut.TargetPath = "C:\Program Files\OpenVPN\bin\openvpn-gui.exe"
        $Shortcut.Save()
        Write-Host "✓ Raccourci OpenVPN créé" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Erreur création raccourci: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "Configuration VPN terminée !" -ForegroundColor Green