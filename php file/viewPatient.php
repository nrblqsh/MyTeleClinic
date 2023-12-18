<?php

    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "teleclinic";

  // Give your table name
    $table = "patient";

    // Create Connection
    $conn = new mysqli($servername, $username, $password, $dbname);
    // Check Connection
    if($conn->connect_error){
        die("Connection Failed: " . $conn->connect_error);
        return;
    }
 if ($_SERVER["REQUEST_METHOD"] == "GET") {
 try {
        $stmt = $db->prepare("SELECT consultation.*, patient.*
                              FROM consultation
                              INNER JOIN patient ON consultation.patientID = patient.patientID
                              WHERE consultation.specialistID = ? AND consultation.consultationStatus = 'Accepted'
                              GROUP BY consultation.patientID;");
        $stmt->execute();
        $response = $stmt->fetchAll(PDO::FETCH_ASSOC);
        http_response_code(200);
    } catch (Exception $ee) {
        http_response_code(500);
        $response->error = "Error occurred " . $ee->getMessage();
    }
}
?>