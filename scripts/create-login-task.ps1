# Script pour créer une tâche qui s'exécute au premier login utilisateur
Write-Host "=== Création tâche de login ===" -ForegroundColor Green

try {
    # Créer le répertoire de scripts s'il n'existe pas
    $scriptsDir = "C:\vagrant\scripts"
    if (!(Test-Path $scriptsDir)) {
        New-Item -ItemType Directory -Path $scriptsDir -Force
    }
    
    # Copier le script removedef.ps1 vers la VM
    $removeDefContent = @"
# Script pour supprimer Windows Security UI au login
Write-Host "=== Suppression de Windows Security UI au login ===" -ForegroundColor Green

try {
    `$remove_appx = @("SecHealthUI")
    `$provisioned = Get-AppxProvisionedPackage -Online
    `$appxpackage = Get-AppxPackage -AllUsers
    `$store = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore'
    `$users = @('S-1-5-18')
    
    if (Test-Path `$store) {
        `$users += (Get-ChildItem `$store -ErrorAction SilentlyContinue | Where-Object {`$_.Name -like '*S-1-5-21*'}).PSChildName
    }

    foreach (`$choice in `$remove_appx) {
        if ([string]::IsNullOrEmpty(`$choice.Trim())) { continue }
        
        Write-Host "Recherche de packages contenant: `$choice" -ForegroundColor Yellow
        
        # Supprimer les packages provisionnés
        foreach (`$appx in (`$provisioned | Where-Object {`$_.PackageName -like "*`$choice*"})) {
            `$PackageName = `$appx.PackageName
            `$PackageFamilyName = (`$appxpackage | Where-Object {`$_.Name -eq `$appx.DisplayName}).PackageFamilyName
            
            Write-Host "Suppression du package provisionné: `$PackageName" -ForegroundColor Yellow
            
            if (`$PackageFamilyName) {
                `$deprovPath = "`$store\Deprovisioned\`$PackageFamilyName"
                if (!(Test-Path `$deprovPath)) {
                    New-Item -Path `$deprovPath -Force | Out-Null
                }
                
                foreach (`$sid in `$users) {
                    `$eolPath = "`$store\EndOfLife\`$sid\`$PackageName"
                    if (!(Test-Path `$eolPath)) {
                        New-Item -Path `$eolPath -Force | Out-Null
                    }
                }
                
                & dism /online /set-nonremovableapppolicy /packagefamily:`$PackageFamilyName /nonremovable:0
                
                try {
                    Remove-AppxProvisionedPackage -PackageName `$PackageName -Online -AllUsers -ErrorAction Stop
                    Write-Host "Package provisionné supprimé avec succès" -ForegroundColor Green
                } catch {
                    Write-Host "Package protégé, suppression via registre uniquement" -ForegroundColor Yellow
                }
            }
        }
        
        # Supprimer les packages installés pour l'utilisateur courant
        foreach (`$appx in (Get-AppxPackage -Name "*`$choice*")) {
            `$PackageFullName = `$appx.PackageFullName
            `$PackageFamilyName = `$appx.PackageFamilyName
            
            Write-Host "Suppression du package utilisateur: `$PackageFullName" -ForegroundColor Yellow
            
            try {
                Remove-AppxPackage -Package `$PackageFullName -ErrorAction Stop
                Write-Host "Package utilisateur supprimé avec succès" -ForegroundColor Green
            } catch {
                Write-Host "Erreur suppression package utilisateur: `$(`$_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    
    # Supprimer cette tâche après exécution
    Write-Host "Suppression de la tâche de login..." -ForegroundColor Yellow
    try {
        Unregister-ScheduledTask -TaskName "RemoveDefenderLogin" -Confirm:`$false -ErrorAction SilentlyContinue
        Write-Host "Tâche de login supprimée" -ForegroundColor Green
    } catch {
        Write-Host "Erreur suppression tâche: `$(`$_.Exception.Message)" -ForegroundColor Yellow
    }
    
    Write-Host "Suppression de SecHealthUI terminée" -ForegroundColor Green
    
} catch {
    Write-Host "Erreur lors de la suppression: `$(`$_.Exception.Message)" -ForegroundColor Red
}
"@
    
    # Écrire le script sur la VM
    Set-Content -Path "C:\vagrant\scripts\removedef-login.ps1" -Value $removeDefContent -Encoding UTF8
    
    # Créer une tâche planifiée qui s'exécute au login
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File C:\vagrant\scripts\removedef-login.ps1"
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    $Principal = New-ScheduledTaskPrincipal -UserID "vagrant" -LogonType Interactive -RunLevel Highest
    
    # Enregistrer la tâche
    Register-ScheduledTask -TaskName "RemoveDefenderLogin" -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description "Suppression Windows Security UI au login"
    
    Write-Host "Script de login créé: C:\vagrant\scripts\removedef-login.ps1" -ForegroundColor Green
    Write-Host "Tâche de login créée avec succès" -ForegroundColor Green
    Write-Host "La suppression se lancera automatiquement au prochain login" -ForegroundColor Yellow
    
} catch {
    Write-Host "Erreur création tâche de login: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Configuration terminée" -ForegroundColor Green