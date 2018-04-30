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
# refresh webpage each 5 sec till the result is obtained from database.

include "../../dbincloc/drugCombination.inc";

$message = "";
$status = "0";

//open the database connection
$db = new mysqli($hostname, $usr, $pwd, $dbname);
if ($db->connect_error) {
    die('Unable to connect to database: ' . $db->connect_error);
}

if (isset($_GET['jobid'])) {
    $jobid = mysqli_real_escape_string($db, $_GET['jobid']);
}


if (!empty($jobid)) {
    if ($result = $db->prepare("SELECT Status FROM Jobs where JOBID = ?")) {
        $result->bind_param("s", $jobid);
        $result->execute();
        $result->store_result();
        $result->bind_result($status);
        $result->fetch();

        if ($result->num_rows > 0) {
            if ($status == "2") {
                echo "<body>\n";
            } else if ($status == "3") {
                echo "<body>\n";
                $message = "Job failed with unexpected reason.";
            } else {
                echo "<body onload='timedRefresh(5000);'>\n";
                $message = "Your job is being processed. Please wait.";
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
    <div style="padding: 20px 20px 20px 30px;">
        <?php if ($status == "2") : ?>
            <table class="oar_table">
                <tr>
                    <td>
                        <img class="oar_img" src="imgShow.php?id=<?php echo $jobid ?>&resultName=HeatMapImage">
                    </td>
                </tr>

                <tr>
                    <td>
                        <p class="oar_title">
                            This heatmap show the synergistic score of compounds pairs. <br/>
                            Dark blue represents high scores, of which compound pair would probably have synergistic effect. <br/>
                            While white represent low score, indicating this compound pair may has antagonistic effect.
                        </p>
                        <br/>
                    </td>
                </tr>
            </table>
            <br/>
            <table class="oar_table">
                <tr>
                    <td>
                        <img class="oar_img2" src="imgShow.php?id=<?php echo $jobid ?>&resultName=RankImage">
                    </td>
                </tr>

                <tr>
                    <td>
                        <p class="oar_title">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            This figure shows the compounds pairs with top synergistic score.
                        </p>
                        <br/>
                    </td>
                </tr>
            </table>
            <br/><br/><br/>

            <a class="oar_file" href="csvShow.php?id=<?php echo $jobid ?>"><img src="images/download-button.png"/></a>
            <br/><br/><br/><br/>
        <?php else : ?>
            <h2><?php echo $message; ?></h2>
        <?php endif; ?>
    </div>
</article>

<?php include "footer.php"; ?>

</html>
