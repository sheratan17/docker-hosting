<?php

$data = json_decode(file_get_contents('php://input'), true);

$arg1 = $data['argument1'];
$arg2 = $data['argument2'];
$arg3 = $data['argument3'];

$command = './setup-php.sh ' . escapeshellarg($arg1) . ' ' . escapeshellarg($arg2) . ' ' . escapeshellarg($arg3);

$output = shell_exec($command);

$response = array('output' => $output);
echo json_encode($response);

?>

