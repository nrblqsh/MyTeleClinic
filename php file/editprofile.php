<?php
error_reporting(E_ALL);
ini_set('display_errors', '1');
$hostname = "localhost";
$database = "teleclinic";
$username = "root";
$password = "";

try {
    $db = new PDO("mysql:host=$hostname;dbname=$database", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Database connection error: " . $e->getMessage()]);
    exit;
}

http_response_code(404);
$response = new stdClass();

if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $jsonbody = json_decode(file_get_contents('php://input'));

    if ($jsonbody === null) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid JSON in request body"]);
        exit;
    }

    $patientID = isset($_GET['patientID']) ? $_GET['patientID'] : (isset($jsonbody->patientID) ? $jsonbody->patientID : null);

    if ($patientID === null) {
        echo json_encode(["status" => "error", "message" => "Patient ID is required"]);
        exit;
    }

    try {
        $updateQuery = "UPDATE patient SET ";
        $updateData = [];
        $responseDetails = ["patientID" => $patientID];

        // Modify this part according to your field names
        if (($jsonbody->patientName)) {
            if (getExistingValue('patientName', $patientID, $db) !== $jsonbody->patientName) {

            $updateQuery .= "patientName = :patientName, ";
            $updateData[':patientName'] = $jsonbody->patientName;
            $responseDetails['patientName'] = $jsonbody->patientName;
}
        }

        if (($jsonbody->icNumber)) {
            if (getExistingValue('icNumber', $patientID, $db) !== $jsonbody->icNumber) {

            $updateQuery .= "icNumber = :icNumber, ";
            $updateData[':icNumber'] = $jsonbody->icNumber;
            $responseDetails['icNumber'] = $jsonbody->icNumber;
}
        }

        if (($jsonbody->phone)) {
            // Check if the phone value has changed
            if (getExistingValue('phone', $patientID, $db) !== $jsonbody->phone) {
                $updateQuery .= "phone = :phone, ";
                $updateData[':phone'] = $jsonbody->phone;
                $responseDetails['phone'] = $jsonbody->phone;
            }
        }

 if (($jsonbody->gender)) {
            // Check if the phone value has changed
            if (getExistingValue('gender', $patientID, $db) !== $jsonbody->gender) {
                $updateQuery .= "gender = :gender, ";
                $updateData[':gender'] = $jsonbody->gender;
                $responseDetails['gender'] = $jsonbody->gender;
            }
        }

 if (($jsonbody->birthDate)) {
            // Check if the phone value has changed
            if (getExistingValue('birthDate', $patientID, $db) !== $jsonbody->birthDate) {
                $updateQuery .= "birthDate = :birthDate, ";
                $updateData[':birthDate'] = $jsonbody->birthDate;
                $responseDetails['birthDate'] = $jsonbody->birthDate;
            }
        }

 if (($jsonbody->password)) {
            // Check if the phone value has changed
            if (getExistingValue('password', $patientID, $db) !== $jsonbody->password) {
                $updateQuery .= "password = :password, ";
                $updateData[':password'] = $jsonbody->password;
                $responseDetails['password'] = $jsonbody->password;
            }
        }
        // Add other fields similarly

        $updateQuery = rtrim($updateQuery, ", ");
        $updateQuery .= " WHERE patientID = :patientID";

        $stmt = $db->prepare($updateQuery);
        $stmt->bindParam(':patientID', $patientID, PDO::PARAM_INT);

        // Bind other parameters and execute the query
        foreach ($updateData as $param => &$value) {
            $stmt->bindParam($param, $value);
            $responseDetails[$param] = $value;
        }

        $stmt->execute();

        // Fetch the updated data using a SELECT query
        $selectStmt = $db->prepare("SELECT * FROM patient WHERE patientID = :patientID");
        $selectStmt->bindParam(':patientID', $patientID, PDO::PARAM_INT);
        $selectStmt->execute();
        $updatedPatientData = $selectStmt->fetchAll(PDO::FETCH_ASSOC);

        if ($stmt->rowCount() > 0) {
            http_response_code(200);
            echo json_encode(["status" => "success", "data" => $updatedPatientData, "details" => $responseDetails]);
        } else {
            http_response_code(404);
            echo json_encode(["status" => "error", "message" => "Patient not found or no changes applied"]);
        }
    } catch (PDOException $ex) {
        http_response_code(500);
        $errorDetails = [
            "status" => "error",
            "message" => "Failed to update patient information: " . $ex->getMessage(),
            "trace" => $ex->getTraceAsString(),
        ];
        echo json_encode($errorDetails);
        // Log the exception details to the PHP error log
        error_log("Exception: " . $ex->getMessage() . "\nTrace: " . $ex->getTraceAsString());
    }

    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $patientID = isset($_GET['patientID']) ? $_GET['patientID'] : null;
    error_log("Received patientID: $patientID");

    if ($patientID === null) {
        echo json_encode(["status" => "error", "message" => "Patient ID is required"]);
        exit;
    }

    try {
        $selectStmt = $db->prepare("SELECT * FROM patient WHERE patientID = :patientID");
        $selectStmt->bindParam(':patientID', $patientID, PDO::PARAM_INT);
        $selectStmt->execute();
        $patientData = $selectStmt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($patientData)) {
            http_response_code(200);
            echo json_encode(["status" => "success", "data" => $patientData]);
        } else {
            http_response_code(404);
            echo json_encode(["status" => "error", "message" => "Patient not found"]);
        }
    } catch (PDOException $ex) {
        http_response_code(500);
        $errorDetails = [
            "status" => "error",
            "message" => "Failed to update patient information: " . $ex->getMessage(),
            "trace" => $ex->getTraceAsString(),
        ];
        echo json_encode($errorDetails);
        // Log the exception details to the PHP error log
        error_log("Exception: " . $ex->getMessage() . "\nTrace: " . $ex->getTraceAsString());
    }

    exit;
}

// Function to get the existing value of a field from the database
function getExistingValue($field, $patientID, $db) {
    $stmt = $db->prepare("SELECT $field FROM patient WHERE patientID = :patientID");
    $stmt->bindParam(':patientID', $patientID, PDO::PARAM_INT);
    $stmt->execute();
    $value = $stmt->fetchColumn();
    echo $value;
    return $value;
}
?>
