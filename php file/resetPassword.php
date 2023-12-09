<?php
$db = mysqli_connect('localhost', 'root', '', 'teleclinic');

if (!$db) {
    echo "Database connection failed";
}

$phone = $_POST['phone'];
$password = $_POST['password'];

// Check patient table
$sql_patient = "SELECT * FROM patient WHERE phone = '$phone'";
$result_patient = mysqli_query($db, $sql_patient);
$count_patient = mysqli_num_rows($result_patient);

// Check specialist table
$sql_specialist = "SELECT * FROM specialist WHERE phone = '$phone'";
$result_specialist = mysqli_query($db, $sql_specialist);
$count_specialist = mysqli_num_rows($result_specialist);

if ($count_patient == 1) {
    // Update the password for patient
    $sql_updatePassword = "UPDATE patient SET password = '$password' WHERE phone = '$phone'";

    if (mysqli_query($db, $sql_updatePassword)) {
        echo json_encode("success reset");
    } else {
        echo json_encode("error updating password");
    }
} elseif ($count_specialist == 1) {
    // Update the password for specialist
    $sql_updatePassword = "UPDATE specialist SET password = '$password' WHERE phone = '$phone'";

    if (mysqli_query($db, $sql_updatePassword)) {
        echo json_encode("success reset");
    } else {
        echo json_encode("error updating password");
    }
} else {
    echo json_encode("error");
}

mysqli_close($db);
?>
