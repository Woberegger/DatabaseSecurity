<?php
require 'vendor/autoload.php'; // Composer MongoDB driver

$client = new MongoDB\Client('mongodb://admin:my-secret-pw@localhost:27017/?authSource=admin');
$db = $client->selectDatabase('ims');
$collection = $db->selectCollection('students');

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Liest den rohen JSON-Body der Anfrage (z.B. von einer API oder Postman)
    $jsonInput = file_get_contents('php://input');
    $data = json_decode($jsonInput, true); // true macht daraus ein assoziatives Array

    $name = $data["name"] ?? null;
    $course = $data["course"] ?? null;

    // ⚠️ Vulnerable query (no input sanitization)
    $query = ['name' => $name, 'course' => $course];
    $student = $collection->findOne($query);

    if ($student) {
        echo "<p>Welcome, " . htmlspecialchars($student['name']) . "!</p>";
    } else {
        echo "<p>injection into students not possible</p>";
    }
}
?>

<form method="POST">
    <!-- Der Angreifer gibt im Value-Feld z.B. "null" ein -->
    <label>Student: <input name="name" /></label><br>
    <label>Course: <input name="course" value="IMS" /></label><br>
    <button type="submit">Query</button>
</form>
