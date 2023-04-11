<!DOCTYPE html>
<html>
<head>
    <title>WP Docker</title>
  <script type="text/javascript">
    window.addEventListener('DOMContentLoaded', function() {
      const domain = document.getElementById('domain');
      const checkbox = document.getElementById('myCheckbox');
      const submitButton = document.getElementById('submitButton');
      
      domain.addEventListener('input', function() {
        if (domain.value !== '' && checkbox.checked) {
          submitButton.disabled = false;
        } else {
          submitButton.disabled = true;
        }
      });
      
      checkbox.addEventListener('change', function() {
        if (domain.value !== '' && checkbox.checked) {
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
        <input type="submit" value="Submit">
    </form>
<br>
    <h1>Hapus WP Docker</h1>
  <form method="post" action="delete.php">
    <label for="domain">Domain:</label>
    <input type="text" id="domain" name="domain" required>
    <br><br>
    <input type="checkbox" id="myCheckbox" name="myCheckbox">
    <label for="myCheckbox">Saya 100% yakin domain sudah benar</label>
    <br><br>
    <button type="submit" id="submitButton" name="submitButton" disabled>Submit</button>
  </form>







</body>
</html>
