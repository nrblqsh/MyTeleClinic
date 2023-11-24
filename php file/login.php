<?php
$db = mysqli_connect('localhost', 'root', '', 'teleclinic');

if (!$db) {
    echo "Database connection failed";
}

$phone = $_POST['phone'];
$password = $_POST['password'];

$sql_patient = "SELECT * FROM patient WHERE phone = '$phone' AND password = '$password'";
$result_patient = mysqli_query($db, $sql_patient);
$count = mysqli_num_rows($result_patient);

$sql_specialist = "SELECT * FROM specialist WHERE phone = '$phone' AND password = '$password'";
$result_specialist = mysqli_query($db, $sql_specialist);
$count_specialist = mysqli_num_rows($result_specialist);

if ($count == 1) {
    echo json_encode("success patients");
} else if($count_specialist==1){
    echo json_encode("success specialist");
}
else {
    echo json_encode("error");
}
?>
