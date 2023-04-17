<?php

$domain = $_POST["inputDomain"];
$output = shell_exec("/var/www/html/delete-php.sh --d=$domain");
echo "<pre>$output</pre>";

?>

