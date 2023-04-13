<?php

$data = json_decode(file_get_contents('php://input'), true);

$arg1 = $data['argument1'];
$arg2 = $data['argument2'];

$output = shell_exec("./changepkg-php.sh '$arg1' '$arg2'");

$response = array('output' => $output);
echo json_encode($response);

?>

