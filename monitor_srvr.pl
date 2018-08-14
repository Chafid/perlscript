use strict;
use warnings;
use Net::SMTP;

my $top_cmd = "/usr/bin/top -b -n 1";
my $mem_cmd = "/usr/bin/vmstat -s";
my $disk_cmd = "/bin/df -h";

my $message;

my $cpu_threshold = 1;
my $mem_threshold = 70;
my $disk_threshold = 30;

my $top_result = `$top_cmd`;
my $mem_result = `$mem_cmd`;
my $disk_result = `$disk_cmd`;


#get cpu usage
my @top_array = split ("\n", $top_result);
my ($cpu_usage) = $top_array[2] =~ /(\d+\.\d+)%/;

my @mem_array = split ("\n", $mem_result);
my ($mem_usage) = $mem_array[1] =~ /(\d+)/;
my ($mem_total) = $mem_array[0] =~ /(\d+)/;

my ($disk_usage) = $disk_result =~ /(\d+)%/;
my $mem_percentage = sprintf ( "%.2f", (($mem_usage / $mem_total) * 100));

print "CPU raw: $top_array[2]\n";
print "CPU usage: $cpu_usage\n";
print "Memory percentage: $mem_percentage" . '%' . "\n"; 
print "Disk usage: $disk_usage\n";

#set threshold to send e-mail after 

if ($cpu_usage > $cpu_threshold) {
	$message = "CPU usage has reached $cpu_usage%\n";
	#send_email($message);
	#print "message1: $message\n";
}

if ($mem_percentage > $mem_threshold) {
	$message = "Memory usage has reached $mem_percentage%\n";
	#print "message2: $message\n";
	send_email($message);
}

if ($disk_usage > $disk_threshold) {
	$message = "Root disk usage has reached $disk_usage\n";
	send_email($message);
}

sub send_email {
	my ($message) = @_;
	print "message: $message\n";
	my $to_addr = 'chafid@sqiva.com';
	my $from_addr = 'test_monitor@sqiva.com';
	my $subject = "Server is overworked";
	my $smtp = Net::SMTP->new('smtp.cbn.net.id') or die $!;
	$smtp->mail( $from_addr);
    $smtp->to( $to_addr );
    $smtp->data();
    $smtp->datasend("To: $to_addr\n");
    $smtp->datasend("From: $from_addr\n");
    $smtp->datasend("Subject: $subject\n");
    $smtp->datasend("\n"); # done with header
    $smtp->datasend($message);
    $smtp->dataend();
    $smtp->quit();
}