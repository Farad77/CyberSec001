# Script de basculement VPN Client
# Permet de changer rapidement entre différents profils VPN clients

param(
    [Parameter(Mandatory=$false)]
    [string]$ClientNumber,
    
    [Parameter(Mandatory=$false)]
    [switch]$List,
    
    [Parameter(Mandatory=$false)]
    [switch]$Current
)

$ConfigPath = "C:\Program Files\OpenVPN\config"
$VagrantConfig = "C:\vagrant\config"
$CurrentConfigFile = "$ConfigPath\client.ovpn"

function Show-Usage {
    Write-Host "=== Basculement Configuration VPN ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\switch-vpn.ps1 -ClientNumber X    # Bascule vers clientX"
    Write-Host "  .\switch-vpn.ps1 -List              # Liste les configs disponibles"
    Write-Host "  .\switch-vpn.ps1 -Current           # Affiche la config actuelle"
    Write-Host ""
    Write-Host "Exemples:" -ForegroundColor Yellow
    Write-Host "  .\switch-vpn.ps1 -ClientNumber 5    # Utilise client5.ovpn.txt"
    Write-Host "  .\switch-vpn.ps1 -List"
    Write-Host ""
}

function Get-AvailableConfigs {
    $configs = @()
    if (Test-Path $VagrantConfig) {
        $ovpnFiles = Get-ChildItem "$VagrantConfig\*.ovpn.txt" | Sort-Object Name
        foreach ($file in $ovpnFiles) {
            $configs += $file.BaseName -replace '\.ovpn$', ''
        }
    }
    return $configs
}

function Show-CurrentConfig {
    Write-Host "=== Configuration VPN Actuelle ===" -ForegroundColor Cyan
    
    if (Test-Path $CurrentConfigFile) {
        # Tenter de déterminer quel client est utilisé
        $content = Get-Content $CurrentConfigFile -Raw
        $configs = Get-AvailableConfigs
        
        $matchedConfig = "Inconnu"
        foreach ($config in $configs) {
            $sourceFile = "$VagrantConfig\$config.ovpn.txt"
            if (Test-Path $sourceFile) {
                $sourceContent = Get-Content $sourceFile -Raw
                if ($content -eq $sourceContent) {
                    $matchedConfig = $config
                    break
                }
            }
        }
        
        Write-Host "Configuration active: $matchedConfig" -ForegroundColor Green
        Write-Host "Fichier: $CurrentConfigFile" -ForegroundColor Gray
    } else {
        Write-Host "Aucune configuration VPN active" -ForegroundColor Red
    }
}

function Show-AvailableConfigs {
    Write-Host "=== Configurations VPN Disponibles ===" -ForegroundColor Cyan
    
    $configs = Get-AvailableConfigs
    
    if ($configs.Count -eq 0) {
        Write-Host "Aucune configuration trouvée dans $VagrantConfig" -ForegroundColor Red
        return
    }
    
    Write-Host "Configurations disponibles:" -ForegroundColor Yellow
    foreach ($config in $configs) {
        $sourceFile = "$VagrantConfig\$config.ovpn.txt"
        $size = (Get-Item $sourceFile).Length
        Write-Host "  - $config ($size bytes)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Total: $($configs.Count) configurations" -ForegroundColor Green
}

function Switch-VPNConfig {
    param([string]$ClientNum)
    
    Write-Host "=== Basculement vers Client $ClientNum ===" -ForegroundColor Cyan
    
    $sourceFile = "$VagrantConfig\client$ClientNum.ovpn.txt"
    
    # Vérifier que le fichier source existe
    if (!(Test-Path $sourceFile)) {
        Write-Host "✗ Configuration client$ClientNum.ovpn.txt non trouvée" -ForegroundColor Red
        Write-Host "Fichier recherché: $sourceFile" -ForegroundColor Gray
        return $false
    }
    
    # Vérifier que le dossier de destination existe
    if (!(Test-Path $ConfigPath)) {
        Write-Host "Création du dossier OpenVPN config..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null
    }
    
    try {
        # Arrêter OpenVPN s'il est en cours d'exécution
        $openvpnProcess = Get-Process -Name "openvpn-gui" -ErrorAction SilentlyContinue
        if ($openvpnProcess) {
            Write-Host "Arrêt d'OpenVPN en cours..." -ForegroundColor Yellow
            $openvpnProcess | Stop-Process -Force
            Start-Sleep -Seconds 2
        }
        
        # Sauvegarder la configuration actuelle si elle existe
        if (Test-Path $CurrentConfigFile) {
            $backupFile = "$ConfigPath\client_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').ovpn"
            Copy-Item $CurrentConfigFile -Destination $backupFile -Force
            Write-Host "Configuration précédente sauvegardée: $(Split-Path $backupFile -Leaf)" -ForegroundColor Gray
        }
        
        # Copier la nouvelle configuration
        Copy-Item $sourceFile -Destination $CurrentConfigFile -Force
        
        Write-Host "✓ Configuration client$ClientNum activée" -ForegroundColor Green
        Write-Host "Fichier: $CurrentConfigFile" -ForegroundColor Gray
        
        # Optionnel: Redémarrer OpenVPN GUI
        if (Test-Path "C:\Program Files\OpenVPN\bin\openvpn-gui.exe") {
            Write-Host "Redémarrage d'OpenVPN GUI..." -ForegroundColor Yellow
            Start-Process "C:\Program Files\OpenVPN\bin\openvpn-gui.exe" -WindowStyle Hidden
            Write-Host "✓ OpenVPN GUI redémarré" -ForegroundColor Green
        }
        
        return $true
        
    } catch {
        Write-Host "✗ Erreur lors du basculement: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Script principal
if ($List) {
    Show-AvailableConfigs
} elseif ($Current) {
    Show-CurrentConfig
} elseif ($ClientNumber) {
    $success = Switch-VPNConfig -ClientNum $ClientNumber
    if ($success) {
        Write-Host ""
        Show-CurrentConfig
    }
} else {
    Show-Usage
    Write-Host ""
    Show-AvailableConfigs
    Write-Host ""
    Show-CurrentConfig
}