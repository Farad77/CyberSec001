// Système de graphiques natif sans dépendances externes

class SimpleChart {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        this.width = 300;
        this.height = 200;
    }
    
    createBarChart(data, options = {}) {
        const { title = '', color = '#00ff88' } = options;
        
        if (!this.container) return;
        
        const maxValue = Math.max(...Object.values(data));
        
        let html = `
            <div class="chart-container">
                <h3 class="chart-title">${title}</h3>
                <div class="chart-bars">
        `;
        
        for (const [label, value] of Object.entries(data)) {
            const height = (value / maxValue) * 100;
            html += `
                <div class="chart-bar-wrapper">
                    <div class="chart-bar" style="height: ${height}%; background: ${color};" title="${label}: ${value}"></div>
                    <span class="chart-label">${label}</span>
                    <span class="chart-value">${value}</span>
                </div>
            `;
        }
        
        html += `
                </div>
            </div>
        `;
        
        this.container.innerHTML = html;
    }
    
    createPieChart(data, options = {}) {
        const { title = '', colors = ['#00ff88', '#66ccff', '#4a90e2', '#e2a04a'] } = options;
        
        if (!this.container) return;
        
        const total = Object.values(data).reduce((sum, val) => sum + val, 0);
        let currentAngle = 0;
        
        let html = `
            <div class="chart-container">
                <h3 class="chart-title">${title}</h3>
                <div class="pie-chart-wrapper">
                    <svg class="pie-chart" viewBox="0 0 200 200">
        `;
        
        Object.entries(data).forEach(([label, value], index) => {
            const percentage = (value / total) * 100;
            const angle = (value / total) * 360;
            const largeArcFlag = angle > 180 ? 1 : 0;
            
            const x1 = 100 + 80 * Math.cos((currentAngle * Math.PI) / 180);
            const y1 = 100 + 80 * Math.sin((currentAngle * Math.PI) / 180);
            const x2 = 100 + 80 * Math.cos(((currentAngle + angle) * Math.PI) / 180);
            const y2 = 100 + 80 * Math.sin(((currentAngle + angle) * Math.PI) / 180);
            
            const pathData = [
                `M 100 100`,
                `L ${x1} ${y1}`,
                `A 80 80 0 ${largeArcFlag} 1 ${x2} ${y2}`,
                `Z`
            ].join(' ');
            
            html += `
                <path d="${pathData}" 
                      fill="${colors[index % colors.length]}" 
                      stroke="#1a1a1a" 
                      stroke-width="2"
                      title="${label}: ${value} (${percentage.toFixed(1)}%)">
                </path>
            `;
            
            currentAngle += angle;
        });
        
        html += `
                    </svg>
                    <div class="pie-legend">
        `;
        
        Object.entries(data).forEach(([label, value], index) => {
            const percentage = ((value / total) * 100).toFixed(1);
            html += `
                <div class="legend-item">
                    <span class="legend-color" style="background: ${colors[index % colors.length]}"></span>
                    <span class="legend-text">${label}: ${value} (${percentage}%)</span>
                </div>
            `;
        });
        
        html += `
                    </div>
                </div>
            </div>
        `;
        
        this.container.innerHTML = html;
    }
    
    createLineChart(data, options = {}) {
        const { title = '', color = '#00ff88', xLabel = '', yLabel = '' } = options;
        
        if (!this.container) return;
        
        const values = Object.values(data);
        const labels = Object.keys(data);
        const maxValue = Math.max(...values);
        const minValue = Math.min(...values);
        const range = maxValue - minValue || 1;
        
        let html = `
            <div class="chart-container">
                <h3 class="chart-title">${title}</h3>
                <div class="line-chart-wrapper">
                    <svg class="line-chart" viewBox="0 0 400 200">
        `;
        
        // Grille
        for (let i = 0; i <= 5; i++) {
            const y = (i / 5) * 180 + 10;
            html += `<line x1="40" y1="${y}" x2="390" y2="${y}" stroke="#333" stroke-width="1"/>`;
        }
        
        for (let i = 0; i < labels.length; i++) {
            const x = 40 + (i / (labels.length - 1)) * 350;
            html += `<line x1="${x}" y1="10" x2="${x}" y2="190" stroke="#333" stroke-width="1"/>`;
        }
        
        // Ligne de données
        let pathData = '';
        labels.forEach((label, index) => {
            const x = 40 + (index / (labels.length - 1)) * 350;
            const y = 190 - ((values[index] - minValue) / range) * 180;
            
            if (index === 0) {
                pathData += `M ${x} ${y}`;
            } else {
                pathData += ` L ${x} ${y}`;
            }
            
            // Points
            html += `
                <circle cx="${x}" cy="${y}" r="4" fill="${color}" stroke="#1a1a1a" stroke-width="2" 
                        title="${label}: ${values[index]}"/>
            `;
        });
        
        html += `<path d="${pathData}" stroke="${color}" stroke-width="3" fill="none"/>`;
        
        html += `
                    </svg>
                </div>
            </div>
        `;
        
        this.container.innerHTML = html;
    }
}

// Fonctions utilitaires pour créer des graphiques rapides
function createMethodsChart() {
    if (typeof globalStats === 'undefined') return;
    
    const chart = new SimpleChart('methods-chart');
    chart.createPieChart(globalStats.methods, {
        title: 'Répartition des méthodes HTTP',
        colors: ['#00ff88', '#66ccff', '#4a90e2', '#e2a04a']
    });
}

function createHourlyChart() {
    // Simuler des données horaires basées sur les logs
    const hourlyData = {};
    for (let i = 0; i < 24; i++) {
        const hour = i.toString().padStart(2, '0') + ':00';
        hourlyData[hour] = Math.floor(Math.random() * 20); // Données simulées
    }
    
    const chart = new SimpleChart('hourly-chart');
    chart.createLineChart(hourlyData, {
        title: 'Activité par heure',
        color: '#66ccff'
    });
}

function createIPChart() {
    if (typeof globalStats === 'undefined') return;
    
    // Prendre les 5 IPs les plus fréquentes
    const ipCounts = {};
    // Cette logique devrait être alimentée par les vraies données
    globalStats.unique_ips.slice(0, 5).forEach((ip, index) => {
        ipCounts[ip] = Math.floor(Math.random() * 10) + 1;
    });
    
    const chart = new SimpleChart('ip-chart');
    chart.createBarChart(ipCounts, {
        title: 'Top 5 IPs',
        color: '#e2a04a'
    });
}