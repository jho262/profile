<?php

include "config.php";

$skill = $_POST['skill'];

$select_query = "SELECT * FROM accomplishments WHERE skills like '%" . $skill . "%'" . " order by importance_level desc limit 15";

$result = mysqli_query($con,$select_query);

$html = "<div>";
$html .= "<p class='sz10'>Top accomplishments (maximum of 15) for the " . strtoupper($skill) . " skill are as follows:</p>";
$html .= "<table class='sz10'><tr><th>Activity_Date</th><th>Company</th><th>Accomplishment</th></tr>";

while($row = mysqli_fetch_array($result)){
 $skills = $row['skills'];
 $importance_level = $row['importance_level'];
 $accomplishment = $row['accomplishment'];
 $company = $row['company'];
 $end_date = $row['end_date'];
 $benefit = $row['benefit'];

 $html .= "<tr><td>" . $end_date . "</td><td>" . $company . "</td><td>" . $accomplishment . "</td></tr>";
}

$html .= "</table></div>";

echo $html;
?>
