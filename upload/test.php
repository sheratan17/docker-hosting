<!DOCTYPE html>
<html>
<head>
    <title>Example PHP Form</title>
</head>
<body>
    <h1>Example PHP Form</h1>
    <form action="process.php" method="POST">
        <label for="domain">Domain:</label>
        <input type="text" name="domain" id="domain" required><br><br>
        <label for="package">Package:</label>
        <select name="package" id="package">
            <option value="p1">p1</option>
            <option value="p2">p2</option>
        </select><br><br>
        <input type="submit" value="Submit">
    </form>
</body>
</html>
