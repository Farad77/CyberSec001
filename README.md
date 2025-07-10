# 🛡️ CyberSec001 - Environnement de Formation Cybersécurité

Plateforme de formation interactive pour la sensibilisation aux menaces cybersécurité, incluant le phishing, spear phishing et les malwares.

## 📋 Vue d'ensemble

Ce projet fournit un environnement complet de formation cybersécurité avec :

- **VM Windows 11** configurée automatiquement via Vagrant
- **3 modules de formation** interactifs
- **Interfaces email réalistes** (Gmail/Outlook)  
- **Système de quiz** avec progression
- **Basculement VPN** entre différents clients

## 🎯 Modules de Formation

### 📧 TPPhishing
Formation générale sur la détection du phishing avec :
- 6 emails d'exemple (4 phishing, 2 légitimes)
- Quiz interactifs avec explications
- Interfaces Gmail et Outlook réalistes
- Système de progression et scores

### 🎣 TP2SpearPhishing  
Module spécialisé sur le spear phishing *(en préparation)*

### 🦠 TP3Malware
Formation sur les pièces jointes malveillantes :
- 2 emails avec attachments suspects
- Focus sur les fichiers `.exe` et `.pdf.exe`
- URLs de test vers `http://10.8.0.3/payload.exe`
- Sensibilisation aux bonnes pratiques

## 🚀 Installation Rapide

### Prérequis
- **VirtualBox** 6.1+
- **Vagrant** 2.3+
- **Git**

### 1. Cloner le projet
```bash
git clone https://github.com/Farad77/CyberSec001.git
cd CyberSec001
```

### 2. ⚠️ Configuration VPN (REQUIS)
Avant de démarrer, vous devez ajouter vos fichiers de configuration VPN :

```bash
# Créer le dossier config
mkdir -p config

# Ajouter vos fichiers .ovpn
# Exemples de noms attendus :
config/client1.ovpn.txt
config/client2.ovpn.txt
# ... jusqu'à client11.ovpn.txt
```

**Important :** Les fichiers VPN ne sont pas inclus dans ce repository pour des raisons de sécurité. Contactez votre administrateur réseau pour obtenir les configurations VPN appropriées.

### 3. Démarrer la VM
```bash
# Démarrer la VM principale
vagrant up

# Accéder via RDP
vagrant rdp
```

### 4. Lancer un module de formation
Dans la VM Windows :
```bash
# TP Phishing General
cd C:\vagrant\TPPhishing
python app.py

# TP Malware
cd C:\vagrant\TP3Malware  
python app.py
```

## 🔧 Configuration

### Structure du projet
```
CyberSec001/
├── Vagrantfile              # Configuration VM Windows 11
├── config/                  # ⚠️ Fichiers VPN (à ajouter)
│   ├── client1.ovpn.txt
│   └── ...
├── scripts/                 # Scripts PowerShell d'automatisation
├── TPPhishing/             # Module phishing général
├── TP2SpearPhishing/       # Module spear phishing
└── TP3Malware/            # Module malware/attachments
```

### Ports utilisés
- **TPPhishing :** `http://localhost:5000`
- **TP3Malware :** `http://localhost:5000` (modifier si exécution simultanée)
- **RDP VM :** Port 3389 (forwarded)


## 🛠️ Développement

### Modifier un module
1. Éditer les emails dans `*/emails/phishing_emails.json`
2. Adapter les templates dans `*/templates/`
3. Ajuster les styles dans `*/static/css/`

### Ajouter un client VPN
1. Placer le fichier `.ovpn.txt` dans `config/`
2. Le script `switch-vpn-gui.ps1` le détectera automatiquement

### Tests
```bash
# Tester les interfaces
cd TPPhishing && python app.py
# Ouvrir http://localhost:5000

# Vérifier la VM
vagrant status
vagrant reload --provision  # Si changements scripts
```

## 📖 Utilisation Pédagogique

### Déroulement type d'une session
1. **Briefing** - Présentation des objectifs
2. **Formation** - Navigation dans les interfaces email  
3. **Quiz** - Analyse des emails suspects
4. **Débriefing** - Discussion des résultats et bonnes pratiques

### Conseils formateur
- Encourager la discussion sur les indices détectés
- Utiliser les "red flags" comme points d'apprentissage
- Adapter la difficulté selon le niveau des apprenants

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit vos changements (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push sur la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est destiné à un usage éducatif en cybersécurité. Utilisation à des fins pédagogiques uniquement.

## ⚠️ Avertissement Légal

Cet environnement est conçu pour la **formation et la sensibilisation** uniquement. Toute utilisation malveillante est strictement interdite et de la responsabilité de l'utilisateur.

---

🛡️ **Formation Cybersécurité - Ensemble, plus forts face aux menaces !**