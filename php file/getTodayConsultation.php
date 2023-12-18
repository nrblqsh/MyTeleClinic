<?php
// Enable error reporting
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
        // Create a MySQLi connection
        $conn = new mysqli($hostname, $username, $password, $database);

        // Check the connection
        if ($conn->connect_error) {
            die("Connection failed: " . $conn->connect_error);
        }

        $today = date("Y-m-d");
        $specialistID = isset($_GET['specialistID']) ? $_GET['specialistID'] : null;

        // Check if 'specialistID' is not null before using it
        if ($specialistID !== null) {
            // Prepare the SQL statement with a JOIN operation and ORDER BY
            $stmt = $conn->prepare("SELECT c.*, p.patientName
                                   FROM consultation c
                                   LEFT JOIN patient p ON c.patientID = p.patientID
                                   WHERE DATE(c.consultationDateTime) = ? AND c.specialistID = ?
                                   ORDER BY c.consultationDateTime ASC"); // ASC for ascending order
            $stmt->bind_param("ss", $today, $specialistID);

            // Execute the statement
            if (!$stmt->execute()) {
                die("Error: " . $stmt->error);
            }

            // Get the result
            $result = $stmt->get_result();

            // Fetch the data
            $data = $result->fetch_all(MYSQLI_ASSOC) ?: [];

            $response->data = $data;
            http_response_code(200);
        } else {
            http_response_code(400);
            $response->error = "Specialist ID not provided";
        }

        // Close the connection
        $conn->close();

    } catch (Exception $ee) {
        http_response_code(500);
        $response->error = "Error occurred " . $ee->getMessage();
    }

    // Remove the var_dump() statement
    // var_dump($response);

    // Echo only the JSON-encoded response
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit();
}
?>
