<?php if ($_SERVER["REQUEST_METHOD"] == "POST") {
	$domain = $_POST["domain"];
	$package = $_POST["package"];
	$tipessl = $_POST["tipessl"];
  	$crttext = $_POST["crttext"];
	$keytext = $_POST["keytext"];

	$crtfile = "{$domain}.crt";
	$keyfile = "{$domain}.key";

	$filecrt_path = "/var/www/html/{$domain}.crt";
	$filekey_path = "/var/www/html/{$domain}.key";

  	file_put_contents($crtfile, $crttext);
	file_put_contents($keyfile, $keytext);


	if (file_exists($filecrt_path) && file_exists($filekey_path)) {
		$command = shell_exec("sh /var/www/html/setup-php.sh --d=$domain --p=$package --ssl=mandiri --crtpath=$filecrt_path --keypath=$filekey_path 2>&1");
	} else {
		$command = shell_exec("sh /var/www/html/setup-php.sh --d=$domain --p=$package --ssl=$tipessl 2>&1");
	}
}
echo "<pre>$command</pre>";
?>
