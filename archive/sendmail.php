


<?php


$to = $_REQUEST['to']; 
$from = $_REQUEST['from'];
$subject = $_REQUEST['subject'];
$body = $_REQUEST['body'];
$headers = "From: " . $from; 

if (mail($to, $subject, $body, $headers)) {
	echo("<p>Message successfully sent!</p>");
} else {
	echo ("<p>Message delivery failed...</p>");
}

?>
