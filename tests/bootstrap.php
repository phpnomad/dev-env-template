<?php
define('ABSPATH', '/var/www/html/');

require_once ABSPATH . 'wp-load.php'; // The path may vary depending on your setup

require_once 'vendor/autoload.php';

require dirname(dirname(__FILE__)) . '/wp-content/plugins/phpnomad/plugin.php';