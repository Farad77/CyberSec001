<?php
require_once 'config/config.php';
require_once 'parser.php';

// Récupérer tous les logs de tous les virtualhosts
$all_logs = [];
foreach ($log_paths as $virtualhost => $log_path) {
    $entries = LogParser::parseLogFile($log_path);
    foreach ($entries as $entry) {
        $entry['virtualhost'] = $virtualhost;
        $all_logs[] = $entry;
    }
}

// Trier tous les logs par timestamp
usort($all_logs, function($a, $b) {
    return strtotime($b['timestamp']) - strtotime($a['timestamp']);
});

// Pagination
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$per_page = $config['max_entries_per_page'];
$offset = ($page - 1) * $per_page;
$total_pages = ceil(count($all_logs) / $per_page);
$logs_page = array_slice($all_logs, $offset, $per_page);

// Statistiques globales
$global_stats = LogParser::getLogStats($all_logs);
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard de Monitoring - Logs Virtualhosts</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container">
        <header>
            <h1>🛡️ Dashboard de Monitoring</h1>
            <div class="refresh-info">
                Dernière mise à jour: <span id="last-update"><?= date('H:i:s') ?></span>
                <button onclick="refreshData()" class="refresh-btn">🔄 Actualiser</button>
            </div>
        </header>

        <!-- Statistiques globales -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Entrées</h3>
                <span class="stat-number"><?= $global_stats['total_entries'] ?></span>
            </div>
            <div class="stat-card">
                <h3>IPs Uniques</h3>
                <span class="stat-number"><?= $global_stats['unique_ip_count'] ?></span>
            </div>
            <div class="stat-card">
                <h3>Activité (1h)</h3>
                <span class="stat-number"><?= $global_stats['recent_activity'] ?></span>
            </div>
            <div class="stat-card">
                <h3>Virtualhosts</h3>
                <span class="stat-number"><?= count($log_paths) ?></span>
            </div>
        </div>

        <!-- Filtres -->
        <div class="filters">
            <select id="virtualhost-filter" onchange="filterLogs()">
                <option value="">Tous les virtualhosts</option>
                <?php foreach ($log_paths as $vh => $path): ?>
                    <option value="<?= htmlspecialchars($vh) ?>"><?= htmlspecialchars($vh) ?></option>
                <?php endforeach; ?>
            </select>
            
            <select id="method-filter" onchange="filterLogs()">
                <option value="">Toutes les méthodes</option>
                <option value="GET">GET</option>
                <option value="POST">POST</option>
            </select>
            
            <input type="text" id="ip-filter" placeholder="Filtrer par IP..." onkeyup="filterLogs()">
        </div>

        <!-- Table des logs -->
        <div class="logs-container">
            <table class="logs-table" id="logs-table">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Virtualhost</th>
                        <th>IP</th>
                        <th>Méthode</th>
                        <th>Paramètres</th>
                        <th>User Agent</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($logs_page as $index => $log): ?>
                        <tr class="log-entry" 
                            data-virtualhost="<?= htmlspecialchars($log['virtualhost']) ?>" 
                            data-method="<?= htmlspecialchars($log['method']) ?>" 
                            data-ip="<?= htmlspecialchars($log['ip']) ?>">
                            <td class="timestamp"><?= date('d/m/Y H:i:s', strtotime($log['timestamp'])) ?></td>
                            <td><span class="virtualhost-badge"><?= htmlspecialchars($log['virtualhost']) ?></span></td>
                            <td class="ip"><?= htmlspecialchars($log['ip']) ?></td>
                            <td><span class="method-badge method-<?= strtolower($log['method']) ?>"><?= htmlspecialchars($log['method']) ?></span></td>
                            <td class="params">
                                <?php if (!empty($log['get_params'])): ?>
                                    <div class="param-section">
                                        <strong>GET:</strong>
                                        <?php foreach ($log['get_params'] as $key => $value): ?>
                                            <span class="param"><?= htmlspecialchars($key) ?>=<?= htmlspecialchars($value) ?></span>
                                        <?php endforeach; ?>
                                    </div>
                                <?php endif; ?>
                                <?php if (!empty($log['post_params'])): ?>
                                    <div class="param-section">
                                        <strong>POST:</strong>
                                        <?php foreach ($log['post_params'] as $key => $value): ?>
                                            <span class="param"><?= htmlspecialchars($key) ?>=<?= htmlspecialchars($value) ?></span>
                                        <?php endforeach; ?>
                                    </div>
                                <?php endif; ?>
                            </td>
                            <td class="user-agent" title="<?= htmlspecialchars($log['user_agent']) ?>">
                                <?= htmlspecialchars(substr($log['user_agent'], 0, 50)) ?>...
                            </td>
                            <td>
                                <button class="detail-btn" onclick="showDetails(<?= $index ?>)">📋 Détails</button>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <?php if ($total_pages > 1): ?>
            <div class="pagination">
                <?php for ($i = 1; $i <= $total_pages; $i++): ?>
                    <a href="?page=<?= $i ?>" class="<?= $i === $page ? 'active' : '' ?>"><?= $i ?></a>
                <?php endfor; ?>
            </div>
        <?php endif; ?>
    </div>

    <!-- Modal pour les détails -->
    <div id="detail-modal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2>Détails de l'entrée</h2>
            <div id="detail-content"></div>
        </div>
    </div>

    <script src="js/dashboard.js"></script>
    <script>
        // Données des logs pour JavaScript
        const logsData = <?= json_encode($logs_page) ?>;
        
        // Auto-refresh
        setInterval(function() {
            refreshData();
        }, <?= $config['refresh_interval'] * 1000 ?>);
    </script>
</body>
</html>