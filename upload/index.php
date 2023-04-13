<!DOCTYPE html>
<html>
<head>
<title>WP Docker</title>
</head>
	<script>
	document.addEventListener("DOMContentLoaded", function() {
		const dropdown = document.getElementById("tipessl");
		const crttext = document.getElementById("crttext");
		const keytext = document.getElementById("keytext");
		const checkbox = document.getElementById("checkbox");
		const submitBtn = document.getElementById("submitBtn");

		dropdown.addEventListener("change", function() {
			if (dropdown.value === "mandiri") {
			crttext.disabled = false;
			keytext.disabled = false;
			crttext.style.backgroundColor = "white";
			keytext.style.backgroundColor = "white";
			} else {
			crttext.disabled = true;
			keytext.disabled = true;
			crttext.style.backgroundColor = "lightgray";
			keytext.style.backgroundColor = "lightgray";
			}
		});

		checkbox.addEventListener("change", function() {
			if (checkbox.checked) {
			submitBtn.disabled = false;
			} else {
			submitBtn.disabled = true;
			}
		});
	});

</script>

<body>
<h1>Buat WP Docker baru</h1>
Pastikan DNS: <br>
- domain, www.domain<br>
- pma.domain, www.pma.domain<br>
- file.domain, www.file.domain<br><br>
Mengarah ke IP: 103.102.153.32<br><br>
Untuk login ke file.domain, gunakan admin:admin lalu ubah password nya melalui menu "Settings"<br><br>
Apabila punya SSL sendiri, pastikan SSL nya wildcard atau memiliki hostname pma.domain dan file.domain di SSL nya.<br><br>
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
		<option value="" selected disabled>Pilih tipe</option>
		<option value="le">Let's Encrypt</option>
		<option value="mandiri">Punya SSL sendiri</option>
		<option value="nossl">Tidak pakai SSL</option>
	</select><br><br>
	<label for="crt">Punya SSL sendiri. Input CRT:</label><br>
	<textarea name="crttext" id="crttext" required></textarea><br><br>
	<label for="crt">Punya SSL sendiri. Input key:</label><br>
        <textarea name="keytext" id="keytext" required></textarea><br>
  	<input type="submit" value="Submit">
	</form>
<br>
<br>
<hr>
<h1>Hapus WP Docker</h1>
PERINGATAN! Pastikan input domain sudah benar<br><br>
	<form action="delete.php" method="POST">
    <label for="inputDomain">Domain:</label>
    <input type="text" id="inputDomain" name="inputDomain" required>
    <br><br>
    <input type="checkbox" id="checkbox" name="checkbox">
    <label for="checkbox">Saya 100% yakin domain sudah benar</label>
    <br><br>
    <button type="submit" id="submitBtn" name="submitButton" disabled>Submit</button>
  </form>
</html>
