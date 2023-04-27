<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST' && $_SERVER['CONTENT_TYPE'] == 'application/json') {
  $data = file_get_contents('php://input');
  $params = json_decode($data, true);
  $cmd = 'sh /var/www/html/setup-php.sh';
  if (isset($params['--d'])) {
    $cmd .= ' --d=' . escapeshellarg($params['--d']);
  }
  if (isset($params['--p'])) {
    $cmd .= ' --p=' . escapeshellarg($params['--p']);
  }
  if (isset($params['--ssl'])) {
    $cmd .= ' --ssl=' . escapeshellarg($params['--ssl']);
  }
  if (isset($params['--crtpath'])) {
    $cmd .= ' --crtpath=' . escapeshellarg($params['--crtpath']);
  }
  if (isset($params['--keypath'])) {
    $cmd .= ' --keypath=' . escapeshellarg($params['--keypath']);
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
?>
