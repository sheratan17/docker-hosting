<?php

$domain = $_POST["domain"];
$output = shell_exec("/var/www/html/delete-php.sh --d=$domain");
echo "<pre>$output</pre>";

echo "<a href='http://docker.fastcloud.id'>Kembali</a>";
?>

