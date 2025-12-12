<?php
// Test akses langsung ke AuthController
require __DIR__ . '/vendor/autoload.php';

// Bootstrap minimal CodeIgniter
define('ROOTPATH', __DIR__ . DIRECTORY_SEPARATOR);
define('SYSTEMPATH', __DIR__ . '/vendor/codeigniter4/framework/system' . DIRECTORY_SEPARATOR);
define('APPPATH', __DIR__ . '/app' . DIRECTORY_SEPARATOR);
define('WRITEPATH', __DIR__ . '/writable' . DIRECTORY_SEPARATOR);
define('FCPATH', __DIR__ . '/public' . DIRECTORY_SEPARATOR);

// Load bootstrap
require SYSTEMPATH . 'bootstrap.php';

// Cek apakah bisa instansiasi AuthController
try {
    $controller = new \Myth\Auth\Controllers\AuthController();
    echo "✓ AuthController bisa diinstansiasi\n";
    
    // Cek method login
    if (method_exists($controller, 'login')) {
        echo "✓ Method login() ada\n";
    } else {
        echo "✗ Method login() TIDAK ada\n";
    }
} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
}


