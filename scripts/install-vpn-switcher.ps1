# Installation du programme de basculement VPN
Write-Host "=== Installation du programme de basculement VPN ===" -ForegroundColor Green

try {
    # Créer le dossier outils s'il n'existe pas
    $ToolsPath = "C:\CyberTools"
    if (!(Test-Path $ToolsPath)) {
        New-Item -ItemType Directory -Path $ToolsPath -Force
        Write-Host "Dossier C:\CyberTools créé" -ForegroundColor Yellow
    }
    
    # Copier les scripts de basculement VPN
    $ScriptSource = "C:\vagrant\scripts"
    
    if (Test-Path "$ScriptSource\switch-vpn.ps1") {
        Copy-Item "$ScriptSource\switch-vpn.ps1" -Destination "$ToolsPath\switch-vpn.ps1" -Force
        Write-Host "✓ Script switch-vpn.ps1 installé" -ForegroundColor Green
    }
    
    if (Test-Path "$ScriptSource\switch-vpn-gui.ps1") {
        Copy-Item "$ScriptSource\switch-vpn-gui.ps1" -Destination "$ToolsPath\switch-vpn-gui.ps1" -Force
        Write-Host "✓ Interface graphique switch-vpn-gui.ps1 installée" -ForegroundColor Green
    }
    
    # Créer raccourci sur le bureau pour l'interface graphique
    $Desktop = [System.Environment]::GetFolderPath('Desktop')
    $WshShell = New-Object -ComObject WScript.Shell
    
    $Shortcut = $WshShell.CreateShortcut("$Desktop\Basculement VPN.lnk")
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$ToolsPath\switch-vpn-gui.ps1`""
    $Shortcut.WorkingDirectory = $ToolsPath
    $Shortcut.IconLocation = "C:\Windows\System32\netshell.dll,0"
    $Shortcut.Description = "Basculer entre les configurations VPN"
    $Shortcut.Save()
    Write-Host "✓ Raccourci 'Basculement VPN' créé sur le bureau" -ForegroundColor Green
    
    # Créer aussi un raccourci dans le menu Démarrer
    $StartMenu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
    $StartShortcut = $WshShell.CreateShortcut("$StartMenu\Basculement VPN.lnk")
    $StartShortcut.TargetPath = "powershell.exe"
    $StartShortcut.Arguments = "-ExecutionPolicy Bypass -File `"$ToolsPath\switch-vpn-gui.ps1`""
    $StartShortcut.WorkingDirectory = $ToolsPath
    $StartShortcut.IconLocation = "C:\Windows\System32\netshell.dll,0"
    $StartShortcut.Description = "Basculer entre les configurations VPN"
    $StartShortcut.Save()
    Write-Host "✓ Raccourci ajouté au menu Démarrer" -ForegroundColor Green
    
    # Ajouter le dossier CyberTools au PATH pour faciliter l'exécution
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$ToolsPath*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$ToolsPath", "Machine")
        Write-Host "✓ Dossier C:\CyberTools ajouté au PATH système" -ForegroundColor Green
    }
    
    # Créer un fichier de documentation
    $DocContent = @"
=== BASCULEMENT CONFIGURATION VPN ===

Cet outil permet de basculer rapidement entre différentes configurations VPN clients.

UTILISATION EN LIGNE DE COMMANDE :
----------------------------------
switch-vpn.ps1 -ClientNumber X    # Bascule vers clientX
switch-vpn.ps1 -List              # Liste les configs disponibles  
switch-vpn.ps1 -Current           # Affiche la config actuelle

EXEMPLES :
----------
switch-vpn.ps1 -ClientNumber 5    # Utilise client5.ovpn.txt
switch-vpn.ps1 -List              # Affiche toutes les configurations

INTERFACE GRAPHIQUE :
--------------------
Double-cliquez sur le raccourci "Basculement VPN" sur le bureau
ou exécutez : switch-vpn-gui.ps1

LOCALISATION DES FICHIERS :
--------------------------
- Scripts : C:\CyberTools\
- Configurations VPN : C:\vagrant\config\
- Configuration active : C:\Program Files\OpenVPN\config\client.ovpn

NOTES :
-------
- OpenVPN sera automatiquement redémarré lors du basculement
- La configuration précédente est sauvegardée automatiquement
- Toutes les configurations doivent être au format .ovpn.txt
"@
    
    $DocContent | Out-File -FilePath "$ToolsPath\VPN-Switcher-README.txt" -Encoding UTF8
    Write-Host "✓ Documentation créée : $ToolsPath\VPN-Switcher-README.txt" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "=== Installation terminée ===" -ForegroundColor Green
    Write-Host "Utilisez le raccourci 'Basculement VPN' sur le bureau" -ForegroundColor Yellow
    Write-Host "ou exécutez 'switch-vpn.ps1 -List' pour voir les configurations disponibles" -ForegroundColor Yellow
    
} catch {
    Write-Host "✗ Erreur installation basculement VPN: $($_.Exception.Message)" -ForegroundColor Red
}