# Script pour activer le routage entre clients VPN
Write-Host "=== Activation routage client-to-client ===" -ForegroundColor Green

# Ajouter une route statique pour le réseau VPN
Write-Host "Ajout route réseau VPN..." -ForegroundColor Yellow
try {
    # Route vers le réseau VPN complet
    route add 10.8.0.0 mask 255.255.255.0 10.8.0.1 metric 1
    Write-Host "Route ajoutée avec succès" -ForegroundColor Green
} catch {
    Write-Host "Erreur ajout route: $($_.Exception.Message)" -ForegroundColor Red
}

# Désactiver le pare-feu Windows pour le réseau VPN
Write-Host "Configuration pare-feu..." -ForegroundColor Yellow
try {
    netsh advfirewall set allprofiles state off
    Write-Host "Pare-feu désactivé" -ForegroundColor Green
} catch {
    Write-Host "Erreur pare-feu: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Configuration terminée" -ForegroundColor Green