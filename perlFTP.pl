use Net::SFTP;
use Time::localtime;
use strict;

my $sourcedir = $ARGV[0];
my $destdir = $ARGV[1];
my $backuptime = $ARGV[2] * 3600;
my $filename;
my $filetimestamp;
my $timediff;
my $filedest;
my $filesource;
my $currenttime = time();
my $sftp = Net::SFTP->new("202.158.123.93", user=>"chafid", password=>"sqiva789", debug=>0,ssh_args => [port =>2049]) or die();
my @filelist = $sftp->ls($sourcedir);

print "localtime: $currenttime\n";

#my $timestamp = ctime(stat($fh)->mtime);

foreach $line (@filelist) {
	$filename = $line->{filename};
	$filetimestamp = $line->{a}->{mtime};	
	$timediff = ($currenttime - $filetimestamp)/3600;
	if (length($filename) > 2 and $timediff > $backuptime) {
		$filesource = $sourcedir . "/" . $filename;
		$filedest = $destdir . "/" . $filename;
		print "getting $filesource to $filedest\n";
		$sftp->get($filesource, $filedest);
		print "removing $filesource\n";
		$sftp->do_remove($filesource);
		
	}
}

