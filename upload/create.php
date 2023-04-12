<?php if ($_SERVER["REQUEST_METHOD"] == "POST") {
	$domain = $_POST["domain"];
	$package = $_POST["package"];
	$tipessl = $_POST["tipessl"];
  	$crttext = $_POST["crttext"];
	$keytext = $_POST["keytext"];

	$crtfile = "{$domain}-crt.crt";
	$keyfile = "{$domain}-key.key";
  	file_put_contents($crtfile, $crttext);
	file_put_contents($keyfile, $keytext);

	$command = "/var/www/html/3setup.sh $domain $package $tipessl 2>&1";
    	// Execute the command and display output
    	$output = shell_exec($command); echo "<pre>$output</pre>";
}
?>
