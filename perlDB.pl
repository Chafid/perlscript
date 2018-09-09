use DBI;
use strict;

my $myDB = DBI->connect("DBI:mysql:test:localhost", "root", "");

my $sql = "select * from employee";

my $sth = $myDB->prepare($sql);
$sth->execute();

while(my @row = $sth->fetchrow_array()){
	printf("%s\t%s\t%s\t%s\t%s\n",$row[0],$row[1], $row[2], $row[3], $row[4]);
}       
$sth->finish();