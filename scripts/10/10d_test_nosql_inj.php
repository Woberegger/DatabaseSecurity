<?php
require 'vendor/autoload.php'; // Composer MongoDB driver

$client = new MongoDB\Client('mongodb://admin:my-secret-pw@localhost:27017/?authSource=admin');
$db = $client->selectDatabase('ims');
$collection = $db->selectCollection->students;

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST["name"]; // pass something like  { "$ne": null }
    $course = $_POST["course"]; // pass something like  { "$ne": null }

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
    <label>Student: <input name="name" /></label><br>
    <label>Course: <input name="course" /></label><br>
    <button type="submit">Query</button>
</form>
