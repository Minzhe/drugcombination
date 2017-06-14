<?php
include "../../dbincloc/drugCombination.inc";

//open the database connection
$db = new mysqli($hostname, $usr, $pwd, $dbname);
if ($db->connect_error) {
    die('Unable to connect to database: ' . $db->connect_error);
}

if (isset($_GET['id'])) {
    $jobid = mysqli_real_escape_string($db, $_GET['id']);
}

header("Content-type: text/csv");
header("Content-Disposition: attachment; filename=result.csv");

if (!empty($jobid) && $result = $db->prepare("select ScoreFile from Results where JOBID = ?")) {
    $result->bind_param("s", $jobid);
    $result->execute();
    $result->store_result();
    $result->bind_result($resultFile);
    $result->fetch();
    echo $resultFile;
    $result->close();
}

$db->close();
?>
