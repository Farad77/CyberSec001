<?php
header('Content-Type: application/json');
require_once 'config/config.php';
require_once 'parser.php';

$action = $_GET['action'] ?? '';

switch ($action) {
    case 'refresh':
        $all_logs = [];
        foreach ($log_paths as $virtualhost => $log_path) {
            $entries = LogParser::parseLogFile($log_path);
            foreach ($entries as $entry) {
                $entry['virtualhost'] = $virtualhost;
                $all_logs[] = $entry;
            }
        }
        
        usort($all_logs, function($a, $b) {
            return strtotime($b['timestamp']) - strtotime($a['timestamp']);
        });
        
        $stats = LogParser::getLogStats($all_logs);
        
        echo json_encode([
            'success' => true,
            'logs' => array_slice($all_logs, 0, $config['max_entries_per_page']),
            'stats' => $stats,
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        break;
        
    case 'search':
        $query = $_GET['q'] ?? '';
        $virtualhost = $_GET['vh'] ?? '';
        
        $all_logs = [];
        foreach ($log_paths as $vh => $log_path) {
            if ($virtualhost && $vh !== $virtualhost) continue;
            
            $entries = LogParser::parseLogFile($log_path);
            foreach ($entries as $entry) {
                $entry['virtualhost'] = $vh;
                
                // Filtrage par recherche
                if ($query) {
                    $searchText = strtolower(
                        $entry['ip'] . ' ' . 
                        $entry['user_agent'] . ' ' . 
                        implode(' ', $entry['get_params']) . ' ' . 
                        implode(' ', $entry['post_params'])
                    );
                    
                    if (strpos($searchText, strtolower($query)) === false) {
                        continue;
                    }
                }
                
                $all_logs[] = $entry;
            }
        }
        
        usort($all_logs, function($a, $b) {
            return strtotime($b['timestamp']) - strtotime($a['timestamp']);
        });
        
        echo json_encode([
            'success' => true,
            'logs' => $all_logs,
            'count' => count($all_logs)
        ]);
        break;
        
    case 'stats':
        $period = $_GET['period'] ?? '1h';
        $virtualhost = $_GET['vh'] ?? '';
        
        $all_logs = [];
        foreach ($log_paths as $vh => $log_path) {
            if ($virtualhost && $vh !== $virtualhost) continue;
            
            $entries = LogParser::parseLogFile($log_path);
            foreach ($entries as $entry) {
                $entry['virtualhost'] = $vh;
                $all_logs[] = $entry;
            }
        }
        
        $time_filter = time();
        switch ($period) {
            case '15m': $time_filter -= 900; break;
            case '1h': $time_filter -= 3600; break;
            case '6h': $time_filter -= 21600; break;
            case '24h': $time_filter -= 86400; break;
            case '7d': $time_filter -= 604800; break;
        }
        
        $filtered_logs = array_filter($all_logs, function($log) use ($time_filter) {
            return strtotime($log['timestamp']) > $time_filter;
        });
        
        $stats = LogParser::getLogStats($filtered_logs);
        
        // Statistiques par heure
        $hourly_stats = [];
        foreach ($filtered_logs as $log) {
            $hour = date('H:00', strtotime($log['timestamp']));
            if (!isset($hourly_stats[$hour])) {
                $hourly_stats[$hour] = 0;
            }
            $hourly_stats[$hour]++;
        }
        
        echo json_encode([
            'success' => true,
            'stats' => $stats,
            'hourly' => $hourly_stats,
            'period' => $period
        ]);
        break;
        
    case 'export':
        $format = $_GET['format'] ?? 'json';
        $virtualhost = $_GET['vh'] ?? '';
        
        $all_logs = [];
        foreach ($log_paths as $vh => $log_path) {
            if ($virtualhost && $vh !== $virtualhost) continue;
            
            $entries = LogParser::parseLogFile($log_path);
            foreach ($entries as $entry) {
                $entry['virtualhost'] = $vh;
                $all_logs[] = $entry;
            }
        }
        
        switch ($format) {
            case 'csv':
                header('Content-Type: text/csv');
                header('Content-Disposition: attachment; filename="logs_export.csv"');
                
                echo "Timestamp,Virtualhost,IP,Method,User_Agent,GET_Params,POST_Params\n";
                foreach ($all_logs as $log) {
                    echo sprintf(
                        '"%s","%s","%s","%s","%s","%s","%s"' . "\n",
                        $log['timestamp'],
                        $log['virtualhost'],
                        $log['ip'],
                        $log['method'],
                        str_replace('"', '""', $log['user_agent']),
                        json_encode($log['get_params']),
                        json_encode($log['post_params'])
                    );
                }
                break;
                
            default:
                echo json_encode([
                    'success' => true,
                    'logs' => $all_logs,
                    'export_time' => date('Y-m-d H:i:s')
                ]);
        }
        break;
        
    default:
        echo json_encode(['error' => 'Action non reconnue']);
}
?>