<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST' && $_SERVER['CONTENT_TYPE'] == 'application/json') {
  $data = file_get_contents('php://input');
  $params = json_decode($data, true);
  $cmd = 'sh /var/www/html/delete-php.sh';
  if (isset($params['--d'])) {
    $cmd .= ' --d=' . escapeshellarg($params['--d']);
  } else {
    header('HTTP/1.1 400 Bad Request');
    echo json_encode(array(
      'error' => 'Missing required parameter --d'
    ));
    exit();
  }
  exec($cmd, $output, $return);
  echo json_encode(array(
    'return_code' => $return,
    'output' => $output
  ));
} else {
  header('HTTP/1.1 400 Bad Request');
  echo 'Invalid request';
}
