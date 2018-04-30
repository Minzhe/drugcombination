#! /usr/bin/perl -w

use warnings;
use DBI;
use strict;
use Cwd;

sub trim;

# declare path
my $path = cwd();

# ------------------------  connect to databse  -------------------------- #
# get db config
my $db_host;
my $db_username;
my $db_password;
open(IN_DATABASE, "dbconfig.inc") || die("The file dbconfig.inc is required. \n");
while (my $line = <IN_DATABASE>) {
	chomp($line);

	if (lc(substr($line, 0, 4)) eq "host") {
		$db_host = trim(substr($line, 5));
		next;
	}

	if (lc(substr($line, 0, 8)) eq "username") {
		$db_username = trim(substr($line, 9));
		next;
	}

	if (lc(substr($line, 0, 8)) eq "password") {
		$db_password = trim(substr($line, 9));
	}
}
close(IN_DATABASE);

# connect to database
my $dbh = DBI->connect('DBI:mysql:drugCombinationRemoteR;host=' . $db_host, $db_username, $db_password)
	           or die "Can't connect: " . DBI->errstr();

# Get jobid which has not been dealt with
my $sth1 = $dbh->prepare("SELECT JOBID, SampleInput, DoseInput, NetworkInput, Method, Name, Email FROM Jobs WHERE status = 0 ORDER BY CreateTime ASC limit 1")
			or die("Prepare of SQL failed" . $dbh->errstr());
$sth1->execute();
my @result1 = $sth1->fetchrow_array();

$sth1->finish();


# ---------------------------  write data into files  -------------------------- #
# if no available job id is found in database, the perl code will stop
if($#result1 eq -1) {
	$dbh->disconnect();
	die "No new job id is found in database!\n"
}

# read data
my $jobid = $result1[0];
my $input = $result1[1];
my $doseInput = $result1[2];
my $networkInput = $result1[3];
my $method = $result1[4];
my $name = $result1[5];
my $email = $result1[6];

# update job status to processed
my $stm0 = $dbh->prepare("update drugCombinationRemoteR.Jobs set Status = 2 where JOBID = '" . $jobid . "';");
$stm0->execute();
$stm0->finish();
$dbh->disconnect();

print "Jobid is " . $jobid . "\n";
print "Method is " . $method . "\n";

# write expression data
my $filename = $path . '/data/GeneExpr' . $jobid . '.csv';
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
print $fh $input;
close $fh;
print "Read sample input done\n";

# write dose data
if ($doseInput ne '') {
	my $doseFilename = $path . '/data/doseRes' . $jobid . '.csv';
	open(my $fhd, '>', $doseFilename) or die "Could not open file '$doseFilename' $!";
	print $fhd $doseInput;
	close $fhd;
	print "Read dose input done\n";
}

# write network data
if ($method eq 2) {
	my $networkFilename = $path . '/data/geneNet' . $jobid . '.csv';
	open(my $fhn, '>', $networkFilename) or die "Could not open file '$networkFilename' $!";
	print $fhn $networkInput;
	close $fhn;
	print "Read network input done\n";
}


# --------------------------------  run program  -------------------------------------- #
system("Rscript process_pipeline.R \"" . $jobid . "\" -p " . $method);

# --------------------------------  output  -------------------------------------- #
my $HEATMAP;
my $RANK;
my $resultFile;
my $status;

# test number
my $testnumber = 0;
# test 5 times
while ((! -e $path ."/report/status" . $jobid . ".txt") && $testnumber < 20) {
	sleep 6;
	$testnumber++;
}

if ($testnumber < 20) {
	open STATUS, $path . "/report/status" . $jobid . ".txt";
	$status = <STATUS>;
	close(STATUS);
}

if ($testnumber == 20 || $status ne "Success\n") {
	my $dbh1 = DBI->connect('DBI:mysql:drugCombinationRemoteR;host=' . $db_host, $db_username, $db_password)
           or die "Can't connect: " . DBI->errstr();

	my $stm = $dbh1->prepare("update drugCombinationRemoteR.Jobs set Status = 3, FinishTime = now() where JOBID = '" . $jobid . "';");
	$stm->execute();
	$stm->finish();
	$dbh1->disconnect();
} else {
	# read HEATMAP
	open HEATMAP, $path . "/report/score_heatmap" . $jobid . ".jpeg";
	#assume is a jpeg...
	my $buff;
	while(read HEATMAP, $buff, 1024) {
			$HEATMAP .= $buff;
	}
	close HEATMAP;

	# read RANK
	open RANK, $path . "/report/score_rank" . $jobid . ".jpeg";
	#assume is a jpeg...
	my $buff1;
	while(read RANK, $buff1, 1024) {
			$RANK .= $buff1;
	}
	close RANK;

	open FILE, $path . "/report/pred.pairRank" . $jobid . ".csv";
	my $buff2;
	while(read FILE, $buff2, 1024) {
		$resultFile .= $buff2;
	}
	close FILE;

	# update database with result

	my $dbh1 = DBI->connect('DBI:mysql:drugCombinationRemoteR;host=' . $db_host, $db_username, $db_password)
	           or die "Can't connect: " . DBI->errstr();

	my $stm = $dbh1->prepare("insert into Results (JOBID, HeatMapImage, RankImage, ScoreFile) values (?, ?, ?, ?);");
	$stm->bind_param(1, $jobid);
	$stm->bind_param(2, $HEATMAP, DBI::SQL_BLOB);
	$stm->bind_param(3, $RANK, DBI::SQL_BLOB);
	$stm->bind_param(4, $resultFile, DBI::SQL_BLOB);
	$stm->execute();
	$stm->finish();

	my $stm1 = $dbh1->prepare("update drugCombinationRemoteR.Jobs set Status = 2, FinishTime = now() where JOBID = '" . $jobid . "';");
	$stm1->execute();
	$stm1->finish();

	$dbh1->disconnect();	
}

# send email alert
if ($email) {
	system("php " . $path . "/phpmailer/mailer.php \"" . $name . "\" \"" . $email . "\" \"" . $jobid . "\"");
}	

# remove temporary file   	
system("rm -f " . $path . "/data/GeneExpr" . $jobid . ".csv");
system("rm -f " . $path . "/data/doseRes" . $jobid . ".csv");
system("rm -f " . $path . "/data/geneNet" . $jobid . ".csv");
system("rm -f " . $path . "/report/log" . $jobid . ".txt");
system("rm -f " . $path . "/report/pred.pairRank" . $jobid . ".csv");
system("rm -f " . $path . "/report/score_heatmap" . $jobid . ".jpeg");
system("rm -f " . $path . "/report/score_rank" . $jobid . ".jpeg");
system("rm -f " . $path . "/report/status" . $jobid . ".txt");
# system("rm -f /home/yiwei/Documents/projects/drugcombination/program/Rplots.pdf");


# Perl trim function to remove whitespace from the start and end of the string
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
