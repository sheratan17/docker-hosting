<?php if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $domain = $_POST["domain"];
        $package = $_POST["package"];

$output = shell_exec("sh /var/www/html/changepkg-php.sh --d=$domain --p=$package");
echo "<pre>$output</pre>";
}

echo "<a href='http://docker.fastcloud.id'>Kembali</a>";

?>
