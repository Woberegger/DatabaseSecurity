<?php
require 'php-quickstart/vendor/autoload.php'; // Composer MongoDB driver

$client = new MongoDB\Client("mongodb://localhost:27017");
$collection = $client->testdb->users;

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST["username"]; // pass something like  { "$ne": null }
    $password = $_POST["password"]; // pass something like  { "$ne": null }

    // ⚠️ Vulnerable query (no input sanitization)
    $query = ['username' => $username, 'password' => $password];
    $user = $collection->findOne($query);

    if ($user) {
        echo "<p>Welcome, " . htmlspecialchars($user['username']) . "!</p>";
    } else {
        echo "<p>Login failed.</p>";
    }
}
?>

<form method="POST">
    <label>Username: <input name="username" /></label><br>
    <label>Password: <input name="password" type="password" /></label><br>
    <button type="submit">Login</button>
</form>
