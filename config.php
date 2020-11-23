<?php
$host = "localhost";
$user = "ar4jf2nz_profile";
$password = "bS2_Cd46n71";
$dbname = "ar4jf2nz_job";

$con = mysqli_connect($host, $user, $password, $dbname);
// Check connection
if (!$con) {
 die("Connection failed: " . mysqli_connect_error());
}
?>
