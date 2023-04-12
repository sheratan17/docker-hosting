<!DOCTYPE html>
<html>
<head>
<title>WP Docker</title>
  <script type="text/javascript">
    window.addEventListener('DOMContentLoaded', function() {
      const inputDomain = document.getElementById('inputDomain');
      const checkbox = document.getElementById('myCheckbox');
      const submitButton = document.getElementById('submitButton');
      const crttext = document.getElementById('crttext');

      inputDomain.addEventListener('input', function() {
        if (inputDomain.value !== '' && checkbox.checked) {
          submitButton.disabled = false;
        } else {
          submitButton.disabled = true;
        }
      });

      checkbox.addEventListener('change', function() {
        if (inputDomain.value !== '' && checkbox.checked) {
          submitButton.disabled = false;
        } else {
          submitButton.disabled = true;
        }
      });
    });
  </script>
</head>

<body>
<h1>Buat WP Docker baru</h1>
    <form action="create.php" method="POST">
        <label for="domain">Domain:</label>
        <input type="text" name="domain" id="domain" required><br><br>
        <label for="package">Package:</label>
        <select name="package" id="package">
            <option value="p1">p1</option>
            <option value="p2">p2</option>
        </select><br><br>
	<label for="tipessl">SSL:</label>
	<select name="tipessl" id="tipessl">
		<option value="le">le</option>
		<option value="mandiri">mandiri</option>
		<option value="nossl">nossl</option>
	</select><br><br>
	<label for="crt">SSL Mandiri. Input CRT</label><br>
	<textarea name="crttext"></textarea><br><br>
	<label for="crt">SSL Mandiri. Input key</label><br>
        <textarea name="keytext"></textarea><br>
  	<input type="submit" value="Submit">
	</form>
<br>
<br>
<h1>Hapus WP Docker</h1>
	<form method="post" action="delete.php">
    <label for="inputDomain">Domain:</label>
    <input type="text" id="inputDomain" name="inputDomain" required>
    <br><br>
    <input type="checkbox" id="myCheckbox" name="myCheckbox">
    <label for="myCheckbox">Saya 100% yakin domain sudah benar</label>
    <br><br>
    <button type="submit" id="submitButton" name="submitButton" disabled>Submit</button>
  </form>
