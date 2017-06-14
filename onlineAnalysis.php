<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Computational Models to Identify Effective Multi-drug Therapies</title>
    <link rel="stylesheet" href="style/style.css" type="text/css" media="screen"/>
    <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon">
    <link rel="icon" href="images/favicon.ico" type="image/x-icon">
    <script type="text/javascript" src="js/jquery.js"></script>
    <script>
        $(document).ready(function () {
            $("#onlineAnalysis").addClass("active");
            $(".oa_introduction_detail").hide();
            $("button").click(function () {
                $(".oa_introduction_detail").toggle();
            });
            $("#oa_uploadGeneNet").hide();
            $("#oa_netOption").change(function () {
                if (this.value == 1) {
                    $("#oa_uploadGeneNet").hide();
                } else if (this.value == 2) {
                    $("#oa_uploadGeneNet").show();
                }
            })
        });
    </script>
</head>

<body>
<?php include "header.php"; ?>
<article>
    <div class="oa_article">
        <div class="module">
            <p class="oa_introduction_abstract">
                The DIGRE take three inputs to do the prediction.
                <button class="oa_button">&nbsp;Detailed Instruction...</button>
            </p>

            <div class="oa_introduction_detail">
                <div class="oa_introduction_detail_item">1. Drug treated gene expression data.<br/></div>
                <div class="oa_introduction_detail_content">Gene expression profiles of single compound-treated and
                    negative control-treated cell line sample. Data needs to be log2 transformed.
                </div>
                <br/>
                <div class="oa_introduction_detail_item">2. Dose-response curve data.<br/></div>
                <div class="oa_introduction_detail_content">Dose-response curves for viability of cell line you used for
                    gene expression assay. For each compound, two data point(viability reduction in IC20 and double dose
                    of IC20) from dose-response curve is desired.
                </div>
                <br/>
                <div class="oa_introduction_detail_item">3. Pathway information<br/></div>
                <div class="oa_introduction_detail_content">Pathway information is used to estimate drug similarity of
                    effect on upstream and downstream genes.<br/>
                    Currently, the DIGRE algorithm use two pathway information, the KEGG pathway information and
                    self-constructed gene network information. User can specify to use either of them. (Currently, the
                    gene network only has lymphoma dataset, so it’s better to use KEGG pathway information if your data
                    is generated on other cancer cell lines.)<br/><br/></div>
                <div class="oa_introduction_detail_content" style="padding: 0;">By taking the above three input, the
                    DIGRE algorithm will calculate pair synergistic score of all the possible combination of the
                    compound you provided, and their rank from the most synergistic to the most antagonist. Larger score
                    indicates high possibility of the pair to have synergistic effect, and vice versa. (Notice that this
                    algorithm focus more on predicting the relative rank of your compound pairs not the exact
                    synergistic strength. If you want to do that, maybe you should involve positive control in your
                    experiment. And also the score calculated by two pathway information is not comparable.)
                </div>
            </div>
        </div>
        <br/>
        <form action="sendAnalysis.php" enctype="multipart/form-data" method="POST">
            <div class="module" style="height: 350px;">
                <div class="oa_form">
                    <p class="an_info">Please leave your contact information (optional).<br/>
                        We will send you email after work done.
                    </p>
                    <input type="text" placeholder="Name (optional) <?php if (isset($_GET["isWrongName"]) && $_GET["isWrongName"] == 1) {
                        echo "Please input correct name.";
                    } ?>" class="textbox" name="name"/>
                    <input type="text"
                           placeholder="Organization (optional) <?php if (isset($_GET["isWrongOrganization"]) && $_GET["isWrongOrganization"] == 1) {
                               echo "Please input correct organization.";
                           } ?>" class="textbox" name="organization"/>
                    <input type="text" placeholder="Email (optional) <?php if (isset($_GET["isWrongEmail"]) && $_GET["isWrongEmail"] == 1) {
                        echo "Please input correct email.";
                    } ?>" class="textbox" name="email"/>
                </div>
            </div>
            <br/>

            <div class="module">
                <br/><br/>
                <table class="an_table">
                    <tr>
                        <td>
                            <p class="oa_reminder"><span style="color: red;">*&nbsp;</span>Gene Expression data:</p>
                        </td>

                        <td>
                            <label>
                                <input id="oa_file" name="userfile" type="file" class="inputfile inputfile-1"/>
                                <label for="oa_file"><img style="width:20px; padding-right: 10px;" src="images/pin.png"
                                                          alt=""/><span
                                        style="padding-bottom: 5px;">Choose a file&hellip;</span></label>
                            </label>
                        </td>

                        <td style="padding: 0 0 0 20px;">
                            <div>
                                <p>
                                    <label class="btn" for="modal-1">Example and Detail</label>
                                </p>
                            </div>
                            <input class="modal-state" id="modal-1" type="checkbox"/>
                            <div class="modal">
                                <label class="modal__bg" for="modal-1"></label>
                                <div class="modal__inner">
                                    <label class="modal__close" for="modal-1"></label>
                                    <img style="width: 500px; padding: 30px 0px;" src="images/sampleInputSample.png"
                                         alt=""/>
                                    <p style="font-size: 17px;">Only accept CSV fil. Maximum file size 10M. <br/>
                                        The first column must be gene names. The first row of other columns should be
                                        compound name. <br/>
                                        At least one column of negative control data should be provided. And the column
                                        name should be "Neg_control".<br/>
                                        Same compound may have more than one column, in which case the average values
                                        will be use in calculation.<br/><br/>
                                        Example:<a href="sample.php"><img style="width: 40px; padding-left: 15px;" src="images/down.png"/></a><br/><br/>
                                    </p>
                                </div>
                            </div>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <br/>
                        </td>
                    </tr>
                    <tr>

                        <td>
                            <p class="oa_reminder"><span style="color: red;">*&nbsp;</span>Dose data:</p>
                        </td>
                        <td>
                            <label>
                                <input id="oa_dosefile" name="dosefile" type="file" class="inputfile inputfile-1"/>
                                <label for="oa_dosefile"><img style="width:20px; padding-right: 10px;"
                                                              src="images/pin.png" alt=""/><span
                                        style="padding-bottom: 5px;">Choose a file&hellip;</span></label>

                            </label>

                        </td>

                        <td style="padding: 0 0 0 20px;">
                            <div>
                                <p>
                                    <label class="btn_2" for="modal-1_2">Example and Detail</label>
                                </p>
                            </div>
                            <input class="modal-state_2" id="modal-1_2" type="checkbox"/>
                            <div class="modal_2">
                                <label class="modal__bg_2" for="modal-1_2"></label>
                                <div class="modal__inner_2">
                                    <label class="modal__close_2" for="modal-1_2"></label>
                                    <img style="width: 500px; padding: 30px 0px;" src="images/doseInputSample.png"
                                         alt=""/>
                                    <p style="font-size: 17px;">Only accept CSV fil. Maximum file size 60K. <br/>
                                        The content should have three rows. <br/>
                                        The first row should be compound names. Each compound should only have one
                                        column.<br/>
                                        The second row should be the values of doseRes1. The first column should be
                                        labeled as "doseRes1".<br/>
                                        The third row should be the values of doseRes2. The first column should be
                                        labeled as "doseRes2".<br/><br/>
                                        Example:<a href="dose.php"><img style="width: 40px; padding-left: 15px;" src="images/down.png"/></a><br/></br>
                                    </p>
                                </div>
                            </div>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <br/>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            <p class="oa_reminder" style="padding-top: 10px;"><span style="color: red;">*&nbsp;</span>Gene Connectivity:</p>
                        </td>

                        <td style="padding: 10px 30px 10px 2px;">
                            <select name="method" class="oa_method" id="oa_netOption">
                                <option value="1">&nbsp;&nbsp;KEGG Pathway</option>
                                <option value="2">&nbsp;&nbsp;Gene Network</option>
                            </select>
                        </td>
                    </tr>

                    <tr id="oa_uploadGeneNet">
                        <td>
                            <p class="oa_reminder"><span style="color: red;">*&nbsp;</span>Connectivity data:</p>
                        </td>
                        <td>
                            <label>
                                <input id="oa_geneNetfile" name="geneNetfile" type="file" class="inputfile inputfile-1"/>
                                <label for="oa_geneNetfile"><img style="width:20px; padding-right: 10px;"
                                                              src="images/pin.png" alt=""/><span
                                        style="padding-bottom: 5px;">Choose a file&hellip;</span></label>
                            </label>
                        </td>
                        <td style="padding: 0 0 0 20px;">
                            <div>
                                <p>
                                    <label class="btn_2" for="modal-1_3">Example and Detail</label>
                                </p>
                            </div>
                            <input class="modal-state_2" id="modal-1_3" type="checkbox"/>
                            <div class="modal_2">
                                <label class="modal__bg_2" for="modal-1_3"></label>
                                <div class="modal__inner_2">
                                    <label class="modal__close_2" for="modal-1_3"></label>
                                    <img style="width: 200px; padding: 30px 0px;" src="images/networkInputSample.PNG"
                                         alt=""/>
                                    <p style="font-size: 17px;">Only accept CSV file. Maximum file size 1M. <br/>
                                        The file should have two columns to specify the two connected genes with their SYMBOL name. <br/>
                                        Example: the following gene-network example files are refined from lymphoma
                                        patients gene expression data. If you are using lymphoma cell lines, you could use our
                                        gene network, otherwise we recommend you use KEGG pathway or upload your own
                                        gene-network file.<br/><br/>
                                        Gene network:
                                        <a href="geneNet.php"><img style="width: 40px; padding-left: 15px;" src="images/down.png"/></a><br/><br/>
                                    </p>
                                </div>
                            </div>
                        </td>
                    </tr>

                    <tr>
                        <!--<td style="padding: 15px 0 0 40px;">
                            <p style="font-size: 20px;"><span style="color: red;">*&nbsp;</span>Verification Code:</p>

                        <td style="padding: 5px 20px 0 7px;">
                            <img id="captcha_img" border='1' src='./captcha.php?r=<?php /*echo rand(); */?>' style="width:100px; height:30px"/>
                            <a href="javascript:void(0)" onclick="$('#captcha_img').attr('src', './captcha.php?r='+Math.random())"><img style="width: 30px;" src="images/refresh.png"/></a>
                        </td>-->

                        <!--<td style="padding: 5px 20px 0 0;">
                            <input style="font-size: 20px; width: 130px;" type="text" name='authcode' value=''/>
                        </td>-->

                        <td colspan="3" style="text-align: center">
                            <br/>
                            <input type="submit" value="Submit" class="an_button">
                        </td>
                    </tr>
                </table>

                <table>
                    <tr>
                        <td>
                            <p class="an_warning">
                                <?php
                                if (isset($_GET["isNoDataFile"]) && $_GET["isNoDataFile"] == 1) {
                                    echo "<br/>Please upload sample data file.";
                                }

                                if (isset($_GET["isFileTypeNotGood"]) && $_GET["isFileTypeNotGood"] == 1) {
                                    echo "<br/>Please upload CSV sample data file.";
                                }

                                if (isset($_GET["isFileSizeNotGood"]) && $_GET["isFileSizeNotGood"] == 1) {
                                    echo "<br/>Sample data file size too big.";
                                }

                                if (isset($_GET["isDoseFileTypeNotGood"]) && $_GET["isDoseFileTypeNotGood"] == 1) {
                                    echo "<br/>Please upload CSV dose data file.";
                                }

                                if (isset($_GET["isNetworkFileTypeNotGood"]) && $_GET["isNetworkFileTypeNotGood"] == 1) {
                                    echo "<br/>Please upload CSV gene connectivity data file.";
                                }

                                if (isset($_GET["isNetworkFileSizeNotGood"]) && $_GET["isNetworkFileSizeNotGood"]) {
                                    echo "<br/>Gene connectivity data file size too big!";
                                }

                                if (isset($_GET["isNoNetworkFile"]) && $_GET["isNoNetworkFile"] == 1) {
                                    echo "<br/>Please upload gene connectivity data file.";
                                }

                                if (isset($_GET["isWrongDataFormat"]) && $_GET["isWrongDataFormat"] == 1) {
                                    echo "<br/>Please upload sample data file with correct data format.";
                                }

                                if (isset($_GET["isWrongDoseDataFormat"]) && $_GET["isWrongDoseDataFormat"] == 1) {
                                    echo "<br/>Please upload dose data file with correct data format.";
                                }

                                if (isset($_GET["noControl"]) && $_GET["noControl"] == 1) {
                                    echo "<br/>Must have negative control result in sample data file.";
                                }

                                if (isset($_GET["isNoDoseFile"]) && $_GET["isNoDoseFile"] == 1) {
                                    echo "<br/>Please upload dose data file.";
                                }
                                ?>
                            </p>
                        </td>
                    </tr>
                </table>

                <table>
                    <tr>
                        <td>
                            <p class="an_warning">
                                <?php
                                if (isset($_GET["isWrongVerification"]) && $_GET["isWrongVerification"] == 1) {
                                    echo "Please input correct verification code.";
                                }
                                ?>
                            </p>
                        </td>
                    </tr>
                </table>
                <br/>
            </div>
        </form>
    </div>
</article>
<?php include "footer.php"; ?>
<script type="text/javascript" src="js/custom-file-input.js"></script>
</body>
</html>
