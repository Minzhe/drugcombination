<!DOCTYPE html>
<head>
    <meta charset="utf-8" http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Computational Models to Identify Effective Multi-drug Therapies</title>
    <meta name="description" content="Online tool to predict the therapeutic effects of drug combinations for cancer."/>
    <meta name="keywords" content="multi-drug, therapies, tool, bioinformatics, prediction, cancer, computational, model, effect, combination, medicine, screening, genome, gene expression"/>
    <link rel="stylesheet" href="style/style.css" type="text/css" media="screen"/>
    <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon">
    <link rel="icon" href="images/favicon.ico" type="image/x-icon">
    <script type="text/javascript" src="js/jquery.js"></script>
    <script>
        $(document).ready(function () {
            $("#index").addClass("active");
            $(".in_introduction_detail").hide();
            $("button").click(function () {
                $(".in_introduction_detail").slideToggle();
            });
        });
    </script>
</head>
<body>
<div class="in_body">
    <?php include "header.php"; ?>
    <article>
        <div class="in_introduction">
            <p class="in_introduction_title">Introduction</p>
            <br/><br/>

            <p class="in_introduction_abstract">
                The Drug-Induced Genomic REsponse Model (DIGREM) is developed to
                predict the compound pair synergistic effect. It uses drug-treated gene
                expression data as input, and outputs predicted scores of synergistic effects
                and rankings of drug combinations.

            </p>
            <br/>

            <p class="in_introduction_detail">
                The promise of multi-drug therapies for cancer has evoked renewed interest in
                high-throughput methods to identify effective drug combinations. Although a
                cell-based, large-scale single-drug screening strategy is well established,
                its extension to drug combination screening becomes cost-prohibitive. Our
                group aims to computationally predict the therapeutic effects of drug
                combinations, and thereby enable <i>in silico</i> screening of large repertories of
                drug combinations to prioritize potential effective multi-drug therapies for
                further experimental validation. It could dramatically revolutionize the
                current procedure of multi-drug therapy discovery and lead to the rapid
                identification of new combination therapies.
            </p>
            <p class="in_introduction_detail">
                DIGREM integrates three methods (DIGRE, IUPUI_CCBB and gene set-based methods)
                to predict drug combination effects by explicitly modeling the drug response
                dynamics and gene expression changes after individual drug treatments.
            </p>
            <p class="in_introduction_detail">
                The DIGRE model developed by our group won the best performance in the National
                Cancer Institute’s DREAM 7 Drug Combination Synergy Prediction Challenge, an
                international crowdsourcing-based computational challenge for
                predicting drug combination effects using transcriptome data. This
                challenge’s blind-assessment of submitted computational models revealed that
                the prediction of drug pair activity from DIGRE was significantly consistent
                with the vast majority of the organizers’ experimental validations. In
                addition, we further validated our DIGRE model using another experimental
                dataset.
            </p>
            <p class="in_introduction_detail">
                IUPUI_CCBB is the second ranked method in DREAM 7 challenge. It has a similar workflow
                as DIGRE but does not consider gene-gene interaction and dose response curve. Statistical
                test is applied to identify commonly disturbed genes in a core gene set by two drugs,
                therefore replicates are required to ensure the statistical power.
            </p>
            <p class="in_introduction_detail">
                Gene set-based method is another recently developed method aiming the same question. Rather
                than looking at individual genes or a defined gene set, it calculates a gene set enrichment
                score across all gene ontology and oncogenic signature gene sets, and ranks drug pairs by an
                average percentage of commonly disturbed genes with the co-enriched gene sets.
            </p>
            <p class="in_introduction_detail">
                DIGREM could potentially be used for large-scale
                discovery of effective drug combinations for further experimental
                validation, possibly leading to the rapid identification of new therapies
                for complex diseases.
            </p>
            <br/>
            <button class="in_button">Detail...</button>
        </div>
        <br/><br/>

        <div class="in_algorithm">
            <p class="in_algorithm_title">Work Flow Chart</p>
            <img style="width: 920px;" src="images/algorithm.jpg"/>
        </div>

        
<!--citation-->
        <div class="in_citation">
            <br/>
            <p class="in_citation_title">Citing the tool:</p>
            <p>DIGREM: an integrated web-based platform for detecting effective multi-drug combination. Zhang M, Lee S, Yao B, Xiao G, Xu L, Xie Y. <a href=""><span style="font-style: italic;">Submitted</span></a></p><br/>
            <p>DIGRE: Drug-Induced Genomic Residual Effect Model for Successful Prediction of Multidrug Effects. Yang J, Tang H, Li Y, Zhong R, Wang T, Wong S, Xiao G, Xie Y. <a href="http://onlinelibrary.wiley.com/doi/10.1002/psp4.1/abstract"><span style="font-style: italic;">CPT Pharmacometrics Syst Pharmacol.</span> 2015 Feb;4(2):e1.</a></p><br/>
            <p>A community computational challenge to predict the activity of pairs of compounds. Bansal M, Yang J, Karan C, Menden MP, Costello JC, Tang H, Xiao G, Li Y, Allen J, Zhong R, Chen B, Kim M, Wang T, Heiser LM, Realubit R, Mattioli M, Alvarez MJ, Shen Y; NCI-DREAM Community, Gallahan D, Singer D, Saez-Rodriguez J, Xie Y, Stolovitzky G, Califano A; NCI-DREAM Community. <a href="http://www.nature.com/nbt/journal/v32/n12/full/nbt.3052.html"><span style="font-style: italic;">Nat Biotechnol.</span> 2014 Dec;32(12):1213-22.</a></p>

        </div>
    </article>
</div>
<?php include "footer.php"; ?>
</body>

