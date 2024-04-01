<?php
// read parameter
$id = $_GET['id'];

// connect and select DB
$dbconn = pg_connect('host=localhost port=5432 dbname=dvdrental user=postgres password=my-secret-pw connect_timeout=5')
  or die('Could not connect: ');

// perform SQL query
$query = "SELECT customer_id, First_Name, Last_Name, Email FROM dvd.Customer WHERE Customer_Id={$id}";

$result = pg_query($query) or die('Query failed. ' . pg_last_error());

// print results in html
echo "<table>\n";
while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
   echo "\t<tr>\n";
   foreach ($line as $col_value) {
      echo "\t\t<td>$col_value</td>\n";
   }
   echo "\t</tr>\n";
}
echo "</table>\n";

// show resultset
pg_free_result($result);
// close connection
pg_close($dbconn);

?>
    