<?php
$db = mysqli_connect('localhost', 'root', '', 'teleclinic');

if (!$db) {
    echo "Database connection failed";
}

$phone = $_POST['phone'];
$password = $_POST['password'];

$sql_patient = "SELECT * FROM patient WHERE phone = '$phone' AND password = '$password'";
$result_patient = mysqli_query($db, $sql_patient);
$count_patient = mysqli_num_rows($result_patient);

$sql_specialist = "SELECT * FROM specialist WHERE phone = '$phone' AND password = '$password'";
$result_specialist = mysqli_query($db, $sql_specialist);
$count_specialist = mysqli_num_rows($result_specialist);

if ($count_patient == 1) {

    // Fetch patient details including patientName
    $row = mysqli_fetch_assoc($result_patient);
    $patientName = $row['patientName'];
    $patientID = $row['patientID'];


    // Create an associative array to send as JSON response
    $response = array(
        "status" => "success patients",
        "patientName" => $patientName,
        "patientID" => $patientID
    );

    echo json_encode($response);
} else if ($count_specialist == 1) {

   $response = array(
           "status" => "success specialist",);

   echo json_encode($response);

} else {
    echo json_encode("error");
}
?>
