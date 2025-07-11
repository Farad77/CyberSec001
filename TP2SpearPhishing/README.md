# 🎯 TP Spear Phishing - Simulateur de Client Mail

## 📋 Objectif Pédagogique

Ce TP de sensibilisation à la cybersécurité permet d'apprendre à identifier les tentatives de spear phishing ciblé à travers des simulations réalistes d'interfaces Gmail et Outlook.

## 🚀 Lancement Rapide

### Option 1 : Lancement automatique (Windows)
```bash
# Double-cliquez sur le fichier
launch.bat
```

### Option 2 : Lancement manuel
```bash
# Installer les dépendances
pip install flask

# Lancer l'application
python app.py
```

## 🌐 Accès aux Interfaces

- **Page d'accueil** : http://localhost:5000
- **Interface Gmail** : http://localhost:5000/gmail
- **Interface Outlook** : http://localhost:5000/outlook
- **Résultats** : http://localhost:5000/results

## 📚 Contenu du TP

### 📧 Emails Inclus

1. **Spear Phishing Netflix** (Moyen)
   - Typosquatting netflik.re
   - Urgence de suspension de compte
   - Credential harvesting
   - Usurpation d'identité Netflix

2. **Spear Phishing Orange Réunion** (Difficile)
   - Domaine orange-reunion.re suspect
   - Faux incident de sécurité
   - Demande de vérification d'identité
   - Technique sophistiquée de credential harvesting

### 🔍 Indices de Détection

#### Niveau Évident
- ❌ Fautes d'orthographe et de grammaire
- ⚠️ Urgence artificielle ("Agissez maintenant!")
- 🔐 Demande d'informations personnelles
- 👤 Expéditeur inconnu ou suspect

#### Niveau Technique
- 📧 Adresse email douteuse
- 🔗 Liens suspects (vérifiez la destination)
- 📎 Pièces jointes non attendues
- 🎨 Formatage inhabituel

#### Niveau Avancé
- 🌐 Domaines suspects (.ru, .tk, etc.)
- 🎭 Usurpation d'identité sophistiquée
- 🔗 Mélange de liens légitimes/malveillants
- 📊 Techniques de social engineering

## 🎓 Déroulement du TP

### Étape 1 : Exploration
- Choisissez une interface (Gmail ou Outlook)
- Parcourez la liste des emails
- Observez les indices visuels

### Étape 2 : Analyse Détaillée
- Cliquez sur un email pour l'ouvrir
- Examinez l'expéditeur, le contenu, les liens
- Utilisez les conseils d'analyse fournis

### Étape 3 : Quiz Interactif
- Cliquez sur "Analyser cet email"
- Répondez aux questions de sécurité
- Obtenez votre score et les explications

### Étape 4 : Résultats
- Consultez vos performances globales
- Apprenez de vos erreurs
- Recommencez pour améliorer votre score

## 🛠️ Structure Technique

```
TPPhishing/
├── app.py                 # Serveur Flask
├── launch.bat            # Lanceur Windows
├── templates/            # Templates HTML
│   ├── base.html
│   ├── index.html
│   ├── gmail.html
│   ├── outlook.html
│   ├── email_detail.html
│   ├── analyze.html
│   └── results.html
├── static/              # Ressources statiques
│   ├── css/
│   │   ├── gmail.css
│   │   ├── outlook.css
│   │   └── email_detail.css
│   ├── js/
│   └── images/
├── emails/              # Base de données emails
│   └── phishing_emails.json
└── README.md
```

## 🔒 Sécurité

- ❌ **Aucun email réel n'est envoyé**
- ❌ **Aucune donnée personnelle n'est collectée**
- ❌ **Aucun lien malveillant n'est réellement actif**
- ✅ **Environnement totalement sécurisé**

## 📖 Utilisation Pédagogique

### Pour les Formateurs
- Utilisez ce TP en début de formation cybersécurité
- Adaptez les emails selon votre public
- Ajoutez vos propres exemples dans `emails/phishing_emails.json`

### Pour les Apprenants
- Prenez votre temps pour analyser chaque email
- N'hésitez pas à recommencer le TP
- Partagez vos découvertes avec le groupe

## 🎯 Objectifs d'Apprentissage

À la fin de ce TP, vous devriez être capable de :
- ✅ Identifier les signes évidents de spear phishing
- ✅ Reconnaître les techniques de typosquatting
- ✅ Détecter les tentatives de credential harvesting
- ✅ Analyser techniquement un email ciblé
- ✅ Vérifier la légitimité d'un expéditeur
- ✅ Adopter les bons réflexes de sécurité

## 🔧 Personnalisation

### Ajouter des Emails
Éditez le fichier `emails/phishing_emails.json` pour ajouter vos propres exemples.

### Modifier l'Interface
- Personnalisez les CSS dans `static/css/`
- Adaptez les templates HTML dans `templates/`

### Configurer le Serveur
Modifiez les paramètres dans `app.py` :
```python
PORT = 5000  # Port d'écoute
```

## 🏆 Gamification

- **Score de détection** : Calculé selon vos bonnes réponses
- **Niveaux de difficulté** : Facile, Moyen, Difficile
- **Badges** : À implémenter selon vos besoins
- **Classement** : Comparez vos scores avec d'autres apprenants

## 📞 Support

En cas de problème :
1. Vérifiez que Python est installé
2. Vérifiez que Flask est installé (`pip install flask`)
3. Consultez les logs dans la console
4. Redémarrez l'application

---

**🎯 Bonne formation en cybersécurité !**