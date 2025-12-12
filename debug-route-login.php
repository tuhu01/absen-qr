<?php
// Debug script untuk cek route login
require __DIR__ . '/vendor/autoload.php';

// Bootstrap CodeIgniter
$pathsConfig = new \Config\Paths();
$pathsConfig->systemDirectory = __DIR__ . '/vendor/codeigniter4/framework/system';
$pathsConfig->appDirectory = __DIR__ . '/app';
$pathsConfig->writableDirectory = __DIR__ . '/writable';
$pathsConfig->viewDirectory = __DIR__ . '/app/Views';

define('ROOTPATH', __DIR__ . DIRECTORY_SEPARATOR);
define('SYSTEMPATH', $pathsConfig->systemDirectory . DIRECTORY_SEPARATOR);
define('APPPATH', $pathsConfig->appDirectory . DIRECTORY_SEPARATOR);
define('WRITEPATH', $pathsConfig->writableDirectory . DIRECTORY_SEPARATOR);
define('FCPATH', __DIR__ . '/public' . DIRECTORY_SEPARATOR);

// Load routes
$routes = \Config\Services::routes();
require APPPATH . 'Config/Routes.php';

echo "=== Route Login Debug ===\n\n";

// Cek route login
$routesList = $routes->getRoutes('get');
echo "Total GET routes: " . count($routesList) . "\n";

if (isset($routesList['login'])) {
    echo "✓ Route 'login' ditemukan\n";
    echo "  Handler: " . (is_string($routesList['login']) ? $routesList['login'] : get_class($routesList['login'])) . "\n";
} else {
    echo "✗ Route 'login' TIDAK ditemukan\n";
    echo "\nRoutes yang ada:\n";
    foreach (array_slice($routesList, 0, 10, true) as $name => $handler) {
        echo "  - $name\n";
    }
}

echo "\n=== Selesai ===\n";

