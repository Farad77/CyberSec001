# Dashboard de Monitoring - Logs Virtualhosts

## 📋 Description

Ce dashboard permet de monitorer et analyser les logs de paramètres provenant de différents virtualhosts. Il parse automatiquement les fichiers `parameters_log.txt` et affiche les données de manière claire et dynamique.

## 🚀 Installation

1. **Placer les fichiers du dashboard** dans votre répertoire web
2. **Configurer les chemins des logs** dans `config/config.php`
3. **Assurer les permissions** de lecture sur les fichiers de logs
4. **Accéder au dashboard** via votre navigateur

## ⚙️ Configuration

### Éditer le fichier `config/config.php`

```php
$log_paths = [
    'orange-reunion' => '/path/to/orange-reunion/parameters_log.txt',
    'netflix-phishing' => '/path/to/netflix-phishing/parameters_log.txt',
    'site3' => '/path/to/site3/parameters_log.txt',
    // Ajouter d'autres virtualhosts ici
];
```

### Paramètres de configuration

- `refresh_interval`: Intervalle d'actualisation automatique (en secondes)
- `max_entries_per_page`: Nombre maximum d'entrées par page
- `timezone`: Fuseau horaire pour l'affichage des dates

## 📊 Fonctionnalités

### Interface principale
- **Statistiques globales** : Total entrées, IPs uniques, activité récente
- **Filtrage en temps réel** : Par virtualhost, méthode HTTP, IP
- **Pagination** : Navigation entre les pages de résultats
- **Actualisation automatique** : Mise à jour périodique des données

### Affichage des logs
- **Format structuré** : Timestamp, virtualhost, IP, méthode, paramètres
- **Coloration syntaxique** : Badges colorés pour les méthodes HTTP
- **Détails complets** : Modal avec informations détaillées
- **User Agent** : Affichage tronqué avec tooltip complet

### Fonctionnalités avancées
- **Détection d'activité suspecte** : Mise en évidence automatique
- **Export de données** : JSON, CSV
- **Recherche globale** : Dans tous les champs
- **Raccourcis clavier** : F5 (actualiser), Échap (fermer modal)

## 🔍 Format des logs analysés

Le parser reconnaît le format suivant :

```
=== ENREGISTREMENT 2025-07-11 09:10:36 ===
IP: 10.8.0.2
User Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
Referer: http://orange-reunion.re/index.php
Méthode: POST
Aucun paramètre GET
Paramètres POST:
  email = fdsfds
  password = azeazeaz
----------------------------------------
```

## 🛠️ Structure des fichiers

```
dashboard/
├── config/
│   └── config.php          # Configuration des chemins et paramètres
├── css/
│   └── dashboard.css       # Styles du dashboard
├── js/
│   └── dashboard.js        # Fonctionnalités JavaScript
├── index.php               # Page principale du dashboard
├── parser.php              # Classe de parsing des logs
├── api.php                 # API pour les requêtes AJAX
└── README.md               # Documentation
```

## 🌐 API Endpoints

### `/api.php?action=refresh`
Actualise les données et statistiques

### `/api.php?action=search&q=terme&vh=virtualhost`
Recherche dans les logs

### `/api.php?action=stats&period=1h&vh=virtualhost`
Statistiques pour une période donnée

### `/api.php?action=export&format=json&vh=virtualhost`
Export des données (JSON/CSV)

## 🔒 Sécurité

### Considérations importantes
- **Permissions de fichiers** : Le serveur web doit pouvoir lire les fichiers de logs
- **Accès au dashboard** : Protéger l'accès par authentification si nécessaire
- **Données sensibles** : Les paramètres POST peuvent contenir des mots de passe
- **Logs de production** : Ne pas exposer en production sans protection

### Recommandations
- Utiliser HTTPS pour l'accès au dashboard
- Implémenter une authentification basique
- Limiter l'accès par IP si possible
- Surveiller l'usage du dashboard

## 🎨 Personnalisation

### Thème sombre cybersécurité
- Couleurs : Noir/vert pour un aspect "hacker-friendly"
- Police monospace pour les données techniques
- Animations et transitions fluides
- Design responsive pour mobile/tablette

### Modifications possibles
- Changer les couleurs dans `css/dashboard.css`
- Ajouter de nouveaux filtres dans `js/dashboard.js`
- Personnaliser les alertes de sécurité
- Intégrer des graphiques supplémentaires

## 🚨 Dépannage

### Problèmes courants

**Aucune donnée affichée**
- Vérifier les chemins dans `config/config.php`
- Contrôler les permissions des fichiers de logs
- S'assurer que les fichiers existent

**Erreurs de parsing**
- Vérifier le format des logs
- Contrôler l'encodage des fichiers (UTF-8)
- Examiner les logs d'erreur PHP

**Performance lente**
- Réduire `max_entries_per_page`
- Optimiser les chemins d'accès aux fichiers
- Considérer la mise en cache

## 📈 Améliorations futures

- Graphiques en temps réel avec Chart.js
- Notifications push pour activité suspecte
- Intégration avec des outils de SIEM
- Base de données pour historique long terme
- Analyse comportementale avancée
- Export vers formats de sécurité (STIX, etc.)

## 📞 Support

Pour toute question ou amélioration, consulter la documentation du projet ou contacter l'équipe de développement.