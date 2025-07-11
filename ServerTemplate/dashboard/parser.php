<?php
class LogParser {
    
    public static function parseLogFile($filePath) {
        if (!file_exists($filePath)) {
            return [];
        }
        
        $content = file_get_contents($filePath);
        $entries = [];
        
        // Diviser le contenu par les séparateurs d'enregistrement
        $records = explode('=== ENREGISTREMENT', $content);
        
        foreach ($records as $record) {
            if (trim($record) === '') continue;
            
            $entry = self::parseRecord($record);
            if ($entry) {
                $entries[] = $entry;
            }
        }
        
        // Trier par date décroissante (plus récent en premier)
        usort($entries, function($a, $b) {
            return strtotime($b['timestamp']) - strtotime($a['timestamp']);
        });
        
        return $entries;
    }
    
    private static function parseRecord($record) {
        $lines = explode("\n", trim($record));
        $entry = [
            'timestamp' => '',
            'ip' => '',
            'user_agent' => '',
            'referer' => '',
            'method' => '',
            'get_params' => [],
            'post_params' => []
        ];
        
        $currentSection = '';
        
        foreach ($lines as $line) {
            $line = trim($line);
            if ($line === '' || $line === '----------------------------------------') continue;
            
            // Extraire le timestamp de la première ligne
            if (preg_match('/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/', $line, $matches)) {
                $entry['timestamp'] = $matches[1];
                continue;
            }
            
            // Parser les différents champs
            if (strpos($line, 'IP:') === 0) {
                $entry['ip'] = trim(substr($line, 3));
            } elseif (strpos($line, 'User Agent:') === 0) {
                $entry['user_agent'] = trim(substr($line, 11));
            } elseif (strpos($line, 'Referer:') === 0) {
                $entry['referer'] = trim(substr($line, 8));
            } elseif (strpos($line, 'Méthode:') === 0) {
                $entry['method'] = trim(substr($line, 8));
            } elseif (strpos($line, 'Paramètres GET:') === 0) {
                $currentSection = 'get';
            } elseif (strpos($line, 'Paramètres POST:') === 0) {
                $currentSection = 'post';
            } elseif (strpos($line, 'Aucun paramètre GET') === 0) {
                $currentSection = '';
            } elseif (strpos($line, 'Aucun paramètre POST') === 0) {
                $currentSection = '';
            } elseif ($currentSection === 'get' && strpos($line, '=') !== false) {
                $parts = explode(' = ', $line, 2);
                if (count($parts) == 2) {
                    $entry['get_params'][trim($parts[0])] = trim($parts[1]);
                }
            } elseif ($currentSection === 'post' && strpos($line, '=') !== false) {
                $parts = explode(' = ', $line, 2);
                if (count($parts) == 2) {
                    $entry['post_params'][trim($parts[0])] = trim($parts[1]);
                }
            }
        }
        
        return $entry['timestamp'] ? $entry : null;
    }
    
    public static function getLogStats($entries) {
        $stats = [
            'total_entries' => count($entries),
            'unique_ips' => [],
            'methods' => [],
            'recent_activity' => 0
        ];
        
        $oneHourAgo = time() - 3600;
        
        foreach ($entries as $entry) {
            // IPs uniques
            if (!in_array($entry['ip'], $stats['unique_ips'])) {
                $stats['unique_ips'][] = $entry['ip'];
            }
            
            // Méthodes
            if (!isset($stats['methods'][$entry['method']])) {
                $stats['methods'][$entry['method']] = 0;
            }
            $stats['methods'][$entry['method']]++;
            
            // Activité récente
            if (strtotime($entry['timestamp']) > $oneHourAgo) {
                $stats['recent_activity']++;
            }
        }
        
        $stats['unique_ip_count'] = count($stats['unique_ips']);
        
        return $stats;
    }
}
?>