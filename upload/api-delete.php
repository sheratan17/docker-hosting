<?php

$data = json_decode(file_get_contents('php://input'), true);

$arg = $data['argument1'];
$output = shell_exec('./delete-php.sh ' . escapeshellarg($arg));

$response = array('output' => $output);
echo json_encode($response);

?>

