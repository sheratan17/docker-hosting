<?php if ($_SERVER['REQUEST_METHOD'] == 'POST') {
	$domain = $_POST['domain'];
	$command = "/var/www/html/2delete.sh $domain 2>&1";
    	// Execute the command and display output
    	$output = shell_exec($command); echo "<pre>$output</pre>";
}
?>
