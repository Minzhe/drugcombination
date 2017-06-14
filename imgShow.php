<?php
include "../../dbincloc/drugCombination.inc";

//open the database connection
$db = new mysqli($hostname, $usr, $pwd, $dbname);
if ($db->connect_error) {
    die('Unable to connect to database: ' . $db->connect_error);
}

$resultName = "";
if (isset($_GET['id'])) {
    $jobid = mysqli_real_escape_string($db, $_GET['id']);
    $resultName = mysqli_real_escape_string($db, $_GET['resultName']);
}

header("Content-type: image/jpeg");

if (!empty($jobid) && $result = $db->prepare("select " . $resultName . " from Results where JOBID = ?")) {
    $result->bind_param("s", $jobid);
    $result->execute();
    $result->store_result();
    $result->bind_result($resultimage);
    $result->fetch();
    echo $resultimage;
    $result->close();
}


$db->close();
?>
