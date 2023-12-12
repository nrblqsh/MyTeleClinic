<?php
$hostname = "localhost";
$database = "teleclinic";
$username = "root";
$password = "";

$db = new PDO ("mysql:host=$hostname;dbname=$database",$username,$password);
//initial response code
//response code will be changed if the request goes into any of the process
http_response_code(404);
$response = new stdClass();

{
	$jsonbody = json_decode(file_get_contents('php://input'));
}

if($_SERVER["REQUEST_METHOD"] == "POST") {

	try{
$stmt = $db->prepare("INSERT INTO appointment (`appointmentID`, `patientID`, `appointmentDateTime`, `specialistID`, `appointmentStatus`)
VALUES (:appointmentID, :patientID, :appointmentDateTime, :specialistID, :appointmentStatus)");
		VALUES (:appointmentID, :patientID, :`appointmentDateTime, :specialistID, :appointmentStatus)");
		$stmt->execute(array(':appointmentID' => $jsonbody->appointmentID,':patientID' => $jsonbody->patientID,':appointmentDateTime' => $jsonbody->appointmentDateTime,
		':specialistID' => $jsonbody->specialistID, ':appointmentStatus' => $jsonbody->appointmentStatus));
		http_response_code(200);
	}catch(Exception $ee) {
		http_response_code(500);
		$response->error = "Error occured ". $ee->getMessage();
	}
}
else if($_SERVER["REQUEST_METHOD"] == "GET"){
	try{
		$stmt = $db->prepare("SELECT * FROM appointment");
		$stmt->execute();
		$response = $stmt->fetchAll(PDO::FETCH_ASSOC);
		http_response_code(200);
	}catch(Exception $ee) {
		http_response_code(500);
		$response->error = "Error occured". $ee->getMessage();
	}
}

echo json_encode($response);
exit();
?>