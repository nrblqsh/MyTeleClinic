<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$hostname = "localhost";
$database = "teleclinic";
$username = "root";
$password = "";

$response = new stdClass();
header('Content-Type: application/json');

if ($_SERVER["REQUEST_METHOD"] == "GET") {
    try {
        $conn = new mysqli($hostname, $username, $password, $database);

        if ($conn->connect_error) {
            die("Connection failed: " . $conn->connect_error);
        }

        // Retrieve upcoming consultations for a specific specialist with patientName using a join
        if (isset($_GET['specialistID'])) {
            $specialistID = $_GET['specialistID'];

            $currentDate = date('Y-m-d H:i:s');
            $stmt = $conn->prepare("SELECT consultation.*, patient.patientName 
                                   FROM consultation 
                                   INNER JOIN patient ON consultation.patientID = patient.patientID
                                   WHERE consultation.specialistID = ? 
                                   AND consultation.consultationDateTime > ? 
                                   ORDER BY consultation.consultationDateTime ASC");
            $stmt->bind_param("ss", $specialistID, $currentDate);

            if ($stmt->execute()) {
                $result = $stmt->get_result();
                $upcomingConsultations = array();

                while ($row = $result->fetch_assoc()) {
                    $upcomingConsultations[] = $row;
                }

                $response->data = $upcomingConsultations;
                $response->success = true;
            } else {
                $response->success = false;
                $response->error = "Error retrieving upcoming consultations: " . $stmt->error;
            }

            $stmt->close();
        } else {
            http_response_code(400);
            $response->error = "Specialist ID not provided";
        }

        $conn->close();

    } catch (Exception $ee) {
        http_response_code(500);
        $response->error = "Error occurred " . $ee->getMessage();
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit();
}
?>
