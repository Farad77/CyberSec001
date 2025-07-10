# Interface graphique pour le basculement VPN
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$VagrantConfig = "C:\vagrant\config"
$ConfigPath = "C:\Program Files\OpenVPN\config"
$CurrentConfigFile = "$ConfigPath\client.ovpn"

function Get-AvailableConfigs {
    $configs = @()
    if (Test-Path $VagrantConfig) {
        $ovpnFiles = Get-ChildItem "$VagrantConfig\*.ovpn.txt" | Sort-Object Name
        foreach ($file in $ovpnFiles) {
            $configName = $file.BaseName -replace '\.ovpn$', ''
            $configs += $configName
        }
    }
    return $configs
}

function Get-CurrentConfig {
    if (Test-Path $CurrentConfigFile) {
        $content = Get-Content $CurrentConfigFile -Raw
        $configs = Get-AvailableConfigs
        
        foreach ($config in $configs) {
            $sourceFile = "$VagrantConfig\$config.ovpn.txt"
            if (Test-Path $sourceFile) {
                $sourceContent = Get-Content $sourceFile -Raw
                if ($content -eq $sourceContent) {
                    return $config
                }
            }
        }
    }
    return "Aucune"
}

function Switch-VPNConfig {
    param([string]$ClientConfig)
    
    $sourceFile = "$VagrantConfig\$ClientConfig.ovpn.txt"
    
    if (!(Test-Path $sourceFile)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Configuration $ClientConfig non trouvée !",
            "Erreur",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return $false
    }
    
    if (!(Test-Path $ConfigPath)) {
        New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null
    }
    
    try {
        # Arrêter OpenVPN
        $openvpnProcess = Get-Process -Name "openvpn-gui" -ErrorAction SilentlyContinue
        if ($openvpnProcess) {
            $openvpnProcess | Stop-Process -Force
            Start-Sleep -Seconds 2
        }
        
        # Copier la nouvelle configuration
        Copy-Item $sourceFile -Destination $CurrentConfigFile -Force
        
        # Redémarrer OpenVPN GUI
        if (Test-Path "C:\Program Files\OpenVPN\bin\openvpn-gui.exe") {
            Start-Process "C:\Program Files\OpenVPN\bin\openvpn-gui.exe" -WindowStyle Hidden
        }
        
        [System.Windows.Forms.MessageBox]::Show(
            "Configuration $ClientConfig activée avec succès !",
            "Succès",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        
        return $true
        
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Erreur lors du basculement: $($_.Exception.Message)",
            "Erreur",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return $false
    }
}

# Création de la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Basculement Configuration VPN"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# Label titre
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Location = New-Object System.Drawing.Point(10, 10)
$labelTitle.Size = New-Object System.Drawing.Size(360, 20)
$labelTitle.Text = "Sélectionnez une configuration VPN :"
$labelTitle.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelTitle)

# Configuration actuelle
$labelCurrent = New-Object System.Windows.Forms.Label
$labelCurrent.Location = New-Object System.Drawing.Point(10, 40)
$labelCurrent.Size = New-Object System.Drawing.Size(360, 20)
$currentConfig = Get-CurrentConfig
$labelCurrent.Text = "Configuration actuelle : $currentConfig"
$labelCurrent.ForeColor = [System.Drawing.Color]::Blue
$form.Controls.Add($labelCurrent)

# Liste des configurations
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 70)
$listBox.Size = New-Object System.Drawing.Size(360, 120)
$listBox.Font = New-Object System.Drawing.Font("Consolas", 9)

$configs = Get-AvailableConfigs
foreach ($config in $configs) {
    $listBox.Items.Add($config) | Out-Null
}

$form.Controls.Add($listBox)

# Bouton Basculer
$buttonSwitch = New-Object System.Windows.Forms.Button
$buttonSwitch.Location = New-Object System.Drawing.Point(50, 210)
$buttonSwitch.Size = New-Object System.Drawing.Size(100, 30)
$buttonSwitch.Text = "Basculer"
$buttonSwitch.BackColor = [System.Drawing.Color]::LightGreen
$buttonSwitch.Add_Click({
    if ($listBox.SelectedItem) {
        $success = Switch-VPNConfig -ClientConfig $listBox.SelectedItem
        if ($success) {
            $currentConfig = Get-CurrentConfig
            $labelCurrent.Text = "Configuration actuelle : $currentConfig"
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show(
            "Veuillez sélectionner une configuration !",
            "Attention",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }
})
$form.Controls.Add($buttonSwitch)

# Bouton Actualiser
$buttonRefresh = New-Object System.Windows.Forms.Button
$buttonRefresh.Location = New-Object System.Drawing.Point(170, 210)
$buttonRefresh.Size = New-Object System.Drawing.Size(100, 30)
$buttonRefresh.Text = "Actualiser"
$buttonRefresh.BackColor = [System.Drawing.Color]::LightBlue
$buttonRefresh.Add_Click({
    $listBox.Items.Clear()
    $configs = Get-AvailableConfigs
    foreach ($config in $configs) {
        $listBox.Items.Add($config) | Out-Null
    }
    $currentConfig = Get-CurrentConfig
    $labelCurrent.Text = "Configuration actuelle : $currentConfig"
})
$form.Controls.Add($buttonRefresh)

# Bouton Fermer
$buttonClose = New-Object System.Windows.Forms.Button
$buttonClose.Location = New-Object System.Drawing.Point(290, 210)
$buttonClose.Size = New-Object System.Drawing.Size(80, 30)
$buttonClose.Text = "Fermer"
$buttonClose.BackColor = [System.Drawing.Color]::LightCoral
$buttonClose.Add_Click({
    $form.Close()
})
$form.Controls.Add($buttonClose)

# Afficher la fenêtre
$form.ShowDialog() | Out-Null