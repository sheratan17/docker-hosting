<?php if ($_SERVER["REQUEST_METHOD"] == "POST") {
	$domain = $_POST["domain"];
	$package = $_POST["package"];
	$tipessl = $_POST["tipessl"];
  	$crttext = $_POST["crttext"];
	$keytext = $_POST["keytext"];

	$crtfile = "{$domain}.crt";
	$keyfile = "{$domain}.key";
  	file_put_contents($crtfile, $crttext);
	file_put_contents($keyfile, $keytext);

	$command = "/var/www/html/setup-php.sh $domain $package $tipessl 2>&1";
    	// Execute the command and display output
    	$output = shell_exec($command); echo "<pre>$output</pre>";
}
?>
