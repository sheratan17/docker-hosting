<?php

$domain = $_POST["inputDomain"];
$output = shell_exec("/var/www/html/2delete.sh $domain");
echo "<pre>$output</pre>";

?>

