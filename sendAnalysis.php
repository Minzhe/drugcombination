<?php
header("Content-Type:text/html;charset=utf-8");
session_start();
// define a function to clean the input
function test_input($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

$tmpName = "";
$doseTmpName = "";
$netTmpName = "";
$acceptedFileType = array("text/csv", "txt/csv", "text/plain", "txt/plain", "application/vnd.ms-excel");       //plain text file
$fileSizeLimit = 10000000;               // file size no larger than 10M


// --------------------------------- expression file --------------------------------- //
if ($_FILES["userfile"]["size"] > 0 && $_FILES["dosefile"]["size"] > 0) {
    $tmpName = $_FILES['userfile']['tmp_name'];
    $fileSize = $_FILES['userfile']['size'];
    $fileType = $_FILES['userfile']['type'];

    $isFileSizeNotGood = 0;
    $isFileTypeNotGood = 0;
    $noControl = 1;

    // check sample data file type
    if (!in_array($fileType, $acceptedFileType)) {
        $isFileTypeNotGood = 1;
    }
    //check file size
    if ($fileSize > $fileSizeLimit) {
        $isFileSizeNotGood = 1;
    }
    if ($isFileSizeNotGood == 1 || $isFileTypeNotGood == 1) {
        echo "<script>location.href='onlineAnalysis.php?isFileTypeNotGood=$isFileTypeNotGood&isFileSizeNotGood=$isFileSizeNotGood'</script>";
        exit();
    }

    include "../../dbincloc/drugCombination.inc";
    $db = new mysqli($hostname, $usr, $pwd, $dbname2);
    if ($db->connect_error) {
        die('Unable to connect to database: ' . $db->connect_error);
    }

    $count = 1;
    $geneArray = array();
    $file = fopen($tmpName, "r");

    // check for negative control
    if ($file) {
        $labels = fgetcsv($file);
        $labels = implode(',', $labels);
        $labels = strtoupper($labels);
        $labels = explode(',', $labels);
        //check if has negative control input
        if (in_array("NEG_CONTROL", $labels)) {
            $noControl = 0;
        }
        $geneArray[0] = mysqli_real_escape_string($db, trim(fgetcsv($file)[0]));
        while (!feof($file) && $count < 100) {
            $geneArray[$count] = mysqli_real_escape_string($db, trim(fgetcsv($file)[0]));
            $count++;
        }
        fclose($file);
    }
    if ($noControl == 1) {
        echo "<script>location.href='onlineAnalysis.php?noControl=1'</script>";
        exit();
    }

    //check if the first column is gene name. If more than 90% could not be found in the database, treate as incorrect input.
    $ratio = 0.1;
    $countGeneNames = 0;
    if ($result = $db->prepare("select count(geneName) from genes where geneName in (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);")) {
        $result->bind_param("ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss",
            $geneArray[0],
            $geneArray[1],
            $geneArray[2],
            $geneArray[3],
            $geneArray[4],
            $geneArray[5],
            $geneArray[6],
            $geneArray[7],
            $geneArray[8],
            $geneArray[9],
            $geneArray[10],
            $geneArray[11],
            $geneArray[12],
            $geneArray[13],
            $geneArray[14],
            $geneArray[15],
            $geneArray[16],
            $geneArray[17],
            $geneArray[18],
            $geneArray[19],
            $geneArray[20],
            $geneArray[21],
            $geneArray[22],
            $geneArray[23],
            $geneArray[24],
            $geneArray[25],
            $geneArray[26],
            $geneArray[27],
            $geneArray[28],
            $geneArray[29],
            $geneArray[30],
            $geneArray[31],
            $geneArray[32],
            $geneArray[33],
            $geneArray[34],
            $geneArray[35],
            $geneArray[36],
            $geneArray[37],
            $geneArray[38],
            $geneArray[39],
            $geneArray[40],
            $geneArray[41],
            $geneArray[42],
            $geneArray[43],
            $geneArray[44],
            $geneArray[45],
            $geneArray[46],
            $geneArray[47],
            $geneArray[48],
            $geneArray[49],
            $geneArray[50],
            $geneArray[51],
            $geneArray[52],
            $geneArray[53],
            $geneArray[54],
            $geneArray[55],
            $geneArray[56],
            $geneArray[57],
            $geneArray[58],
            $geneArray[59],
            $geneArray[60],
            $geneArray[61],
            $geneArray[62],
            $geneArray[63],
            $geneArray[64],
            $geneArray[65],
            $geneArray[66],
            $geneArray[67],
            $geneArray[68],
            $geneArray[69],
            $geneArray[70],
            $geneArray[71],
            $geneArray[72],
            $geneArray[73],
            $geneArray[74],
            $geneArray[75],
            $geneArray[76],
            $geneArray[77],
            $geneArray[78],
            $geneArray[79],
            $geneArray[80],
            $geneArray[81],
            $geneArray[82],
            $geneArray[83],
            $geneArray[84],
            $geneArray[85],
            $geneArray[86],
            $geneArray[87],
            $geneArray[88],
            $geneArray[89],
            $geneArray[90],
            $geneArray[91],
            $geneArray[92],
            $geneArray[93],
            $geneArray[94],
            $geneArray[95],
            $geneArray[96],
            $geneArray[97],
            $geneArray[98],
            $geneArray[99]
        );
        $result->execute();
        $result->store_result();
        $result->bind_result($countGeneNames);
        $result->fetch();
        $result->close();
    }
    $db->close();
    if ($countGeneNames < $ratio * $count) {
        echo "<script>location.href='./onlineAnalysis.php?isWrongDataFormat=1'</script>";
        exit();
    }

} else {
    $isNoDataFile = 0;
    if ($_FILES["userfile"]["size"] == 0) {
        $isNoDataFile = 1;
    }
    echo "<script>location.href='./onlineAnalysis.php?isNoDataFile=$isNoDataFile'</script>";
    exit();
}


// --------------------------------- dose file ---------------------------------- //
if ($_FILES["dosefile"]["size"] > 0) {
    $doseTmpName = $_FILES['dosefile']['tmp_name'];
    $doseFileType = $_FILES['dosefile']['type'];
    $doseSize = $_FILES['dosefile']['size'];

    // check dose data file type
    $isDoseFileTypeNotGood = 0;
    if (!in_array($doseFileType, $acceptedFileType)) {
        $isDoseFileTypeNotGood = 1;
    }
    // check file size
    if ($doseSize > $fileSizeLimit) {
        $isDoseFileSizeNotGood = 1;
    }

    if ($isDoseFileSizeNotGood == 1 || $isDoseFileTypeNotGood == 1) {
        echo "<script>location.href='onlineAnalysis.php?isDoseFileTypeNotGood=$isDoseFileTypeNotGood&isDoseFileSizeNotGood=$isDoseFileSizeNotGood'</script>";
        exit();
    }

    // check dose data file format
    $doseFile = fopen($doseTmpName, "r");
    $doseArray = array();
    if ($doseFile) {
        fgetcsv($doseFile);
        $doseArray[0] = strtoupper(trim(fgetcsv($doseFile)[0]));
        $doseArray[1] = strtoupper(trim(fgetcsv($doseFile)[0]));
        fclose($doseFile);
        if (!($doseArray[0] == "DOSERES1" && $doseArray[1] == "DOSERES2" || $doseArray[0] == "DOSERES2" && $doseArray[1] == "DOSERES1")) {
            echo "<script>location.href='./onlineAnalysis.php?isWrongDoseDataFormat=1'</script>";
            exit();
        }
    }
}


// --------------------------------- network file ---------------------------------- //
if ($_POST['method'] == 2) {
    if ($_FILES["geneNetfile"]["size"] > 0) {
        // check if uploaded network file
        $netTmpName = $_FILES['geneNetfile']['tmp_name'];
        $netFileType = $_FILES['geneNetfile']['type'];
        $netFileSize = $_FILES['geneNetfile']['size'];

        $isNetworkFileSizeNotGood = 0;
        $isNetworkFileTypeNotGood = 0;

        //check network data file type
        if (!in_array($netFileType, $acceptedFileType)) {
            $isNetworkFileTypeNotGood = 1;
        }
        //check network file size
        if ($netFileSize > $fileSizeLimit) {
            $isNetworkFileSizeNotGood = 1;
        }

        if ($isNetworkFileSizeNotGood == 1 || $isNetworkFileTypeNotGood == 1) {
            echo "<script>location.href='onlineAnalysis.php?isNetworkFileSizeNotGood=$isNetworkFileSizeNotGood&isNetworkFileTypeNotGood=$isNetworkFileTypeNotGood'</script>";
            exit();
        }
    } else {
        $isNoNetworkFile = 0;
        if ($_FILES["geneNetfile"]["size"] == 0) {
            $isNoNetworkFile = 1;
            echo "<script>location.href='onlineAnalysis.php?isNoNetworkFile=$isNoNetworkFile'</script>";
            exit();
        }
    }
}


// --------------------------------- user information ---------------------------------- //
// Check name organization and email
$isWrongName = 0;
$isWrongOrganization = 0;
$isWrongEmail = 0;

if ($_POST['name'] != "") {
    $name = test_input($_POST['name']);
    if (!preg_match("/^[a-zA-Z ]*$/",$name)) {
        $isWrongName = 1;
    }
}

if ($_POST['organization'] != "") {
    $organization = test_input($_POST['organization']);
    if (!preg_match("/^[a-zA-Z0-9 ]*$/",$organization)) {
        $isWrongOrganization = 1;
    }
}

if ($_POST['email'] != "") {
    $email = test_input($_POST['email']);
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $isWrongEmail = 1;
    }
}

if ($isWrongName == 1 || $isWrongOrganization == 1 || $isWrongEmail == 1) {
    echo "<script>location.href='onlineAnalysis.php?isWrongName=$isWrongName&isWrongOrganization=$isWrongOrganization&isWrongEmail=$isWrongEmail'</script>";
    exit();
}


// --------------------------------- insert to database ---------------------------------- //
include "../../dbincloc/drugCombination.inc";
// open the database connection
$db = new mysqli($hostname, $usr, $pwd, $dbname);
if ($db->connect_error) {
    die('Unable to connect to database: ' . $db->connect_error);
}

// read data
$jobid = uniqid("", TRUE);
$inputs = file_get_contents($tmpName);
$doseInputs = file_get_contents($doseTmpName);
$method = $_POST['method'];     // method: 1 for KEGG, 2 for gene network
$networkInputs = file_get_contents($netTmpName);

// set job status as 0. 0 means new job, 1 means job success, 2 means job processing, 9 means job failed.
if ($result1 = $db->prepare("INSERT INTO Jobs (JOBID, Status, Name, Organization, Email, SampleInput, DoseInput, NetworkInput, Method, CreateTime) VALUES (?, 0, ?, ?, ?, ?, ?, ?, ?, now());")) {
    $result1->bind_param("ssssssss", $jobid, $name, $organization, $email, $inputs, $doseInputs, $networkInputs, $method);
    $result1->execute();
    $result1->close();
}

echo "<script>location.href='./waiting.php?jobid=" . $jobid . "'</script>";
$db->close();
exit();
?>
