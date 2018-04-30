<!DOCTYPE html>
<head>
    <meta charset="utf-8" http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Computational Models to Identify Effective Multi-drug Therapies</title>
    <link rel="stylesheet" href="style/style.css" type="text/css" media="screen"/>
    <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon">
    <link rel="icon" href="images/favicon.ico" type="image/x-icon">
    <script type="text/javascript" src="js/jquery.js"></script>
    <script>
        $(document).ready(function () {
            $("#download").addClass("active");
        });
    </script>
</head>

<body>
<?php include "header.php"; ?>

<article class="dl_article">
    <div style="padding: 50px;">
        <h2>
            Download the code for DIGRE Model
        </h2>
        <br/>

        <table class="dl_table">
            <tr>
                <th>Resource</th>
                <th>Instructions</th>
                <th>Download</th>
            </tr>
            <!------------------  user manual  --------------------->
            <tr>
                <td>
                    <p>Web user manual</p>
                </td>
                <td>
                    <p>
                        Download the user manual to see a step-by-step instruction of how to use DIGREM website.<br/><br/>
                    </p>
                </td>
                <td>
                    <a href="" target="_blank"><img style="width: 40px; padding-left: 15px;" src="images/down.png"/></a>
                </td>
            </tr>
            <!------------------  command line tool  --------------------->
            <tr>
                <td>
                    <p>Command line tool</p>
                </td>
                <td>
                    <p>
                        R command line tool to run in console locally.<br/><br/>
                        How to run:<br/>
                        <span style="color: green;">$</span>Rscript geneExpFile doseResFile –p 1 -f 0.6<br/><br/>
                        (Detail see ReadMe.txt in the download file)
                    </p>
                </td>
                <td>
                    <a href="download/DIGREsyn-Rscript_1.0.tar.gz"><img style="width: 40px; padding-left: 15px;" src="images/down.png"/></a>
                </td>
            </tr>
            <!------------------  R package  --------------------->
            <tr>
                <td>
                    <p>R package</p>
                </td>
                <td>
                    <p>R package providing the function for running in R program.<br/><br/>
                        How to run:<br/>
                        > install_github("DIGREsyn", "Minzhe")<br/>
                        > library(DIGRESyn)<br/>
                    </p>
                </td>
                <td>
                    <a href="https://github.com/Minzhe/DIGREsyn" target="_blank"><img style="width: 40px; padding-left: 15px;" src="images/down.png"/></a>
                </td>
            </tr>
        </table>
    </div>
</article>
<?php include "footer.php"; ?>
</body>
