<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $domain = $_POST['domain'];
    $package = $_POST['package'];
    $content= file_get_contents ('/var/www/html/2setup.sh');
echo shell_exec ($content $domain $package 2>&1);
}
?>

