<?php if ($_SERVER['REQUEST_METHOD'] == 'POST') {
	$domain = $_POST['domain'];
	$package = $_POST['package']; 
	$command = "/var/www/html/2setup.sh $domain $package 2>&1";
    	// Execute the command and display output
    	$output = shell_exec($command); echo "<pre>$output</pre>";
}
?>
