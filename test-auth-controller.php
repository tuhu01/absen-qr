<?php
// Test script untuk cek apakah AuthController bisa diakses
require __DIR__ . '/vendor/autoload.php';

$path = __DIR__ . '/vendor/myth/auth/src/Controllers/AuthController.php';
if (file_exists($path)) {
    echo "✓ AuthController.php exists\n";
    require $path;
    if (class_exists('Myth\Auth\Controllers\AuthController')) {
        echo "✓ AuthController class exists\n";
    } else {
        echo "✗ AuthController class NOT found\n";
    }
} else {
    echo "✗ AuthController.php NOT found at: $path\n";
}

