let currentFilters = {
    virtualhost: '',
    method: '',
    ip: ''
};

function filterLogs() {
    const virtualhostFilter = document.getElementById('virtualhost-filter').value;
    const methodFilter = document.getElementById('method-filter').value;
    const ipFilter = document.getElementById('ip-filter').value.toLowerCase();
    
    currentFilters = {
        virtualhost: virtualhostFilter,
        method: methodFilter,
        ip: ipFilter
    };
    
    const rows = document.querySelectorAll('.log-entry');
    
    rows.forEach(row => {
        const virtualhost = row.dataset.virtualhost;
        const method = row.dataset.method;
        const ip = row.dataset.ip.toLowerCase();
        
        let show = true;
        
        if (virtualhostFilter && virtualhost !== virtualhostFilter) {
            show = false;
        }
        
        if (methodFilter && method !== methodFilter) {
            show = false;
        }
        
        if (ipFilter && !ip.includes(ipFilter)) {
            show = false;
        }
        
        if (show) {
            row.classList.remove('hidden');
        } else {
            row.classList.add('hidden');
        }
    });
    
    updateVisibleCount();
}

function updateVisibleCount() {
    const visibleRows = document.querySelectorAll('.log-entry:not(.hidden)');
    const totalRows = document.querySelectorAll('.log-entry');
    
    let countDisplay = document.getElementById('count-display');
    if (!countDisplay) {
        countDisplay = document.createElement('div');
        countDisplay.id = 'count-display';
        countDisplay.style.cssText = 'margin: 10px 0; color: #888; font-size: 0.9em;';
        document.querySelector('.logs-container').insertBefore(countDisplay, document.querySelector('.logs-table'));
    }
    
    countDisplay.textContent = `Affichage de ${visibleRows.length} sur ${totalRows.length} entrées`;
}

function showDetails(index) {
    const log = logsData[index];
    if (!log) return;
    
    const modal = document.getElementById('detail-modal');
    const content = document.getElementById('detail-content');
    
    let detailHtml = `
        <div style="margin-bottom: 20px;">
            <h3 style="color: #00ff88; margin-bottom: 15px;">📋 Informations détaillées</h3>
            
            <div style="display: grid; gap: 15px;">
                <div class="detail-section">
                    <strong style="color: #66ccff;">🕒 Timestamp:</strong>
                    <span style="font-family: monospace; color: #e0e0e0;">${log.timestamp}</span>
                </div>
                
                <div class="detail-section">
                    <strong style="color: #66ccff;">🌐 Virtualhost:</strong>
                    <span class="virtualhost-badge">${log.virtualhost}</span>
                </div>
                
                <div class="detail-section">
                    <strong style="color: #66ccff;">📍 Adresse IP:</strong>
                    <span style="font-family: monospace; color: #66ccff;">${log.ip}</span>
                </div>
                
                <div class="detail-section">
                    <strong style="color: #66ccff;">🔧 Méthode HTTP:</strong>
                    <span class="method-badge method-${log.method.toLowerCase()}">${log.method}</span>
                </div>
                
                <div class="detail-section">
                    <strong style="color: #66ccff;">🔗 Referer:</strong>
                    <span style="font-family: monospace; color: #e0e0e0; word-break: break-all;">${log.referer || 'N/A'}</span>
                </div>
                
                <div class="detail-section">
                    <strong style="color: #66ccff;">🖥️ User Agent:</strong>
                    <div style="background: #2a2a2a; padding: 10px; border-radius: 5px; margin-top: 5px; font-family: monospace; word-break: break-all;">
                        ${log.user_agent}
                    </div>
                </div>
    `;
    
    if (Object.keys(log.get_params).length > 0) {
        detailHtml += `
                <div class="detail-section">
                    <strong style="color: #66ccff;">📤 Paramètres GET:</strong>
                    <div style="background: #2a2a2a; padding: 10px; border-radius: 5px; margin-top: 5px;">
        `;
        for (const [key, value] of Object.entries(log.get_params)) {
            detailHtml += `<div style="margin: 5px 0;"><span style="color: #00ff88; font-weight: bold;">${key}:</span> <span style="font-family: monospace;">${value}</span></div>`;
        }
        detailHtml += `</div></div>`;
    }
    
    if (Object.keys(log.post_params).length > 0) {
        detailHtml += `
                <div class="detail-section">
                    <strong style="color: #66ccff;">📥 Paramètres POST:</strong>
                    <div style="background: #2a2a2a; padding: 10px; border-radius: 5px; margin-top: 5px;">
        `;
        for (const [key, value] of Object.entries(log.post_params)) {
            detailHtml += `<div style="margin: 5px 0;"><span style="color: #00ff88; font-weight: bold;">${key}:</span> <span style="font-family: monospace;">${value}</span></div>`;
        }
        detailHtml += `</div></div>`;
    }
    
    detailHtml += `
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 20px;">
            <button onclick="exportLogEntry(${index})" style="background: #00ff88; color: #0a0a0a; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin-right: 10px;">📊 Exporter</button>
            <button onclick="closeModal()" style="background: #666; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer;">Fermer</button>
        </div>
    `;
    
    content.innerHTML = detailHtml;
    modal.style.display = 'block';
}

function closeModal() {
    document.getElementById('detail-modal').style.display = 'none';
}

function exportLogEntry(index) {
    const log = logsData[index];
    const exportData = {
        timestamp: log.timestamp,
        virtualhost: log.virtualhost,
        ip: log.ip,
        method: log.method,
        referer: log.referer,
        user_agent: log.user_agent,
        get_params: log.get_params,
        post_params: log.post_params
    };
    
    const dataStr = JSON.stringify(exportData, null, 2);
    const dataBlob = new Blob([dataStr], {type: 'application/json'});
    
    const link = document.createElement('a');
    link.href = URL.createObjectURL(dataBlob);
    link.download = `log_entry_${log.timestamp.replace(/[:\s]/g, '_')}.json`;
    link.click();
}

function refreshData() {
    location.reload();
}

function searchLogs() {
    const searchTerm = document.getElementById('search-input').value.toLowerCase();
    const rows = document.querySelectorAll('.log-entry');
    
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        if (text.includes(searchTerm)) {
            row.classList.remove('hidden');
        } else {
            row.classList.add('hidden');
        }
    });
    
    updateVisibleCount();
}

function highlightSuspiciousActivity() {
    const rows = document.querySelectorAll('.log-entry');
    
    rows.forEach(row => {
        const params = row.querySelector('.params').textContent.toLowerCase();
        const userAgent = row.querySelector('.user-agent').textContent.toLowerCase();
        
        let suspicious = false;
        
        // Détection de patterns suspects
        const suspiciousPatterns = [
            'script', 'alert', 'eval', 'javascript:',
            'union select', 'drop table', 'insert into',
            '<script>', 'onerror=', 'onload=',
            'admin', 'password', 'login'
        ];
        
        suspiciousPatterns.forEach(pattern => {
            if (params.includes(pattern) || userAgent.includes(pattern)) {
                suspicious = true;
            }
        });
        
        if (suspicious) {
            row.style.borderLeft = '4px solid #dc3545';
            row.style.backgroundColor = 'rgba(220, 53, 69, 0.1)';
        }
    });
}

function addRealTimeUpdates() {
    const indicator = document.createElement('div');
    indicator.id = 'realtime-indicator';
    indicator.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: #00ff88;
        color: #0a0a0a;
        padding: 8px 15px;
        border-radius: 20px;
        font-size: 0.8em;
        font-weight: bold;
        z-index: 1000;
        display: none;
    `;
    indicator.textContent = '🔄 Mise à jour...';
    document.body.appendChild(indicator);
}

// Fermer le modal en cliquant à l'extérieur
window.onclick = function(event) {
    const modal = document.getElementById('detail-modal');
    if (event.target === modal) {
        modal.style.display = 'none';
    }
}

// Raccourcis clavier
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeModal();
    }
    if (e.key === 'F5' || (e.ctrlKey && e.key === 'r')) {
        e.preventDefault();
        refreshData();
    }
});

function showCharts(type) {
    // Mettre à jour les boutons actifs
    document.querySelectorAll('.chart-btn').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    // Vider la section graphiques
    const chartsSection = document.getElementById('charts-section');
    chartsSection.innerHTML = '';
    
    switch(type) {
        case 'overview':
            chartsSection.innerHTML = `
                <div id="methods-chart"></div>
                <div id="hourly-chart"></div>
                <div id="ip-chart"></div>
            `;
            setTimeout(() => {
                createMethodsChart();
                createHourlyChart();
                createIPChart();
            }, 100);
            break;
            
        case 'activity':
            chartsSection.innerHTML = `
                <div id="timeline-chart"></div>
                <div id="requests-chart"></div>
            `;
            setTimeout(() => {
                createTimelineChart();
                createRequestsChart();
            }, 100);
            break;
            
        case 'security':
            chartsSection.innerHTML = `
                <div id="threats-chart"></div>
                <div id="suspicious-chart"></div>
            `;
            setTimeout(() => {
                createThreatsChart();
                createSuspiciousChart();
            }, 100);
            break;
    }
}

function createTimelineChart() {
    // Graphique de timeline d'activité
    const timelineData = {};
    const now = new Date();
    for (let i = 23; i >= 0; i--) {
        const hour = new Date(now.getTime() - i * 60 * 60 * 1000);
        const label = hour.getHours().toString().padStart(2, '0') + ':00';
        timelineData[label] = Math.floor(Math.random() * 15);
    }
    
    const chart = new SimpleChart('timeline-chart');
    chart.createLineChart(timelineData, {
        title: 'Activité des dernières 24h',
        color: '#00ff88'
    });
}

function createRequestsChart() {
    // Graphique des types de requêtes
    const requestData = {
        'Login': Math.floor(Math.random() * 50) + 20,
        'Search': Math.floor(Math.random() * 30) + 10,
        'Upload': Math.floor(Math.random() * 20) + 5,
        'Download': Math.floor(Math.random() * 25) + 8
    };
    
    const chart = new SimpleChart('requests-chart');
    chart.createBarChart(requestData, {
        title: 'Types de requêtes',
        color: '#66ccff'
    });
}

function createThreatsChart() {
    // Graphique des menaces détectées
    const threatsData = {
        'XSS': Math.floor(Math.random() * 10) + 2,
        'SQL Injection': Math.floor(Math.random() * 8) + 1,
        'Brute Force': Math.floor(Math.random() * 15) + 5,
        'Suspicious UA': Math.floor(Math.random() * 12) + 3
    };
    
    const chart = new SimpleChart('threats-chart');
    chart.createPieChart(threatsData, {
        title: 'Menaces détectées',
        colors: ['#dc3545', '#e2a04a', '#ffc107', '#ff6b6b']
    });
}

function createSuspiciousChart() {
    // Graphique d'évolution des activités suspectes
    const suspiciousData = {};
    for (let i = 6; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        const label = date.toLocaleDateString('fr-FR', { month: 'short', day: 'numeric' });
        suspiciousData[label] = Math.floor(Math.random() * 20) + 5;
    }
    
    const chart = new SimpleChart('suspicious-chart');
    chart.createLineChart(suspiciousData, {
        title: 'Activités suspectes (7 derniers jours)',
        color: '#dc3545'
    });
}

// Initialisation
document.addEventListener('DOMContentLoaded', function() {
    updateVisibleCount();
    highlightSuspiciousActivity();
    addRealTimeUpdates();
    
    // Initialiser les graphiques
    setTimeout(() => {
        createMethodsChart();
        createHourlyChart();
        createIPChart();
    }, 500);
    
    // Focus sur le premier champ de filtre
    document.getElementById('virtualhost-filter').focus();
});

// Fonction pour animer les nouvelles entrées
function animateNewEntries() {
    const newEntries = document.querySelectorAll('.log-entry');
    newEntries.forEach((entry, index) => {
        entry.style.opacity = '0';
        entry.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            entry.style.transition = 'all 0.3s ease';
            entry.style.opacity = '1';
            entry.style.transform = 'translateY(0)';
        }, index * 50);
    });
}