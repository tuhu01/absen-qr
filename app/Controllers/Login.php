<?php

namespace App\Controllers;

use Myth\Auth\Controllers\AuthController as MythAuthController;
use CodeIgniter\HTTP\RedirectResponse;

class Login extends MythAuthController
{
    /**
     * Displays the login form
     * 
     * @return RedirectResponse|string
     */
    public function login()
    {
        return parent::login();
    }

    /**
     * Attempts to log the user in
     * 
     * @return RedirectResponse|string
     */
    public function attemptLogin()
    {
        return parent::attemptLogin();
    }

    /**
     * Log the user out
     * 
     * @return RedirectResponse
     */
    public function logout()
    {
        return parent::logout();
    }
}

