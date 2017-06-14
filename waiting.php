<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Computational Models to Identify Effective Multi-drug Therapies</title>
    <link href="style/style.css" rel="stylesheet" type="text/css"/>
    <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon">
    <link rel="icon" href="images/favicon.ico" type="image/x-icon">
    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/JavaScript">
        function timedRefresh(timeoutPeriod) {
            setTimeout("location.reload(true);", timeoutPeriod);
        }

        $(document).ready(function () {
            $("#onlineAnalysis").addClass("active");
        });
    </script>
</head>

<?php

include "../../dbincloc/drugCombination.inc";

//open the database connection
$db = new mysqli($hostname, $usr, $pwd, $dbname);
if ($db->connect_error) {
    die('Unable to connect to database: ' . $db->connect_error);
}

if (isset($_GET['jobid'])) {
    $jobid = mysqli_real_escape_string($db, $_GET['jobid']);
}

$message = "";
$status = "0";

if (!empty($jobid)) {
    if ($result = $db->prepare("SELECT Status FROM Jobs where JOBID = ?;")) {
        $result->bind_param("s", $jobid);
        $result->execute();
        $result->store_result();
        $result->bind_result($status);
        $result->fetch();

        if ($result->num_rows > 0) {
            if ($status == "2" || $status == "3") {
                echo "<script>location.href='onlineAnalysisResult.php?jobid=" . $jobid . "'</script>";
                exit();
            } else {
                echo "<body onload=\"JavaScript:timedRefresh(5000);\">\n";
            }
        } else {
            echo "<body>\n";
            $message = "No Job Found.";
        }

        $result->close();
    } else {
        echo "<body>\n";
        $message = "DataBase Connection Failed.";
    }
} else {
    echo "<body>\n";
    $message = "Job Submission Failed.";
}

$db->close();

?>
<?php include "header.php"; ?>
<article id="art-main">
    <div style="padding: 20px 75px;">
        <h2>Your job has been submitted!</h2>
        <br/><br/>
        <img src="images/Preloader_8.gif" style="margin: 0 330px 20px 330px;"/><br/><br/>
        <p style="font-size: 17px;">The job will take about one min. This page will refresh automatically each 5 seconds. <br/>
            When your job is finished, the results will be shown on this page.
            <br/><br/>You can record the following URL and check your results later. Your query will be kept on our
            service for a long time.<br/>

            <a href="http://qbrc2.swmed.edu/drugcombination/onlineAnalysisResult.php?jobid=<?php echo $jobid ?>">http://qbrc2.swmed.edu/drugcombination/onlineAnalysisResult.php?jobid=<?php echo $jobid ?></a>

            <br/><br/> Any questions please feel free to contact <a href="https://qbrc.swmed.edu/">Quantitative Biomedical Research Center</a>.</p>
    </div>
</article>
<?php include "footer.php"; ?>
</body>
</html>
