use warnings;
use strict;

use Selenium::Chrome;
use Selenium::Waiter qw/wait_until/;
use Data::Dumper;

use URI::Encode;
use LWP::UserAgent;
use HTTP::Request();
use JSON;

my %settings = (
    'binary' => 'C:\Users\Chafid\Documents\Personal\Upwork\PerlProjects\MYOB-Selenium\chromedriver.exe',
    'detach' => 1
    );

my $driver = Selenium::Chrome->new(%settings);


my $url ="https://secure.myob.com/oauth2/account/authorize?";
my $client_id = "" ; 
my $client_secret = ""; 
my $redirect_uri = "http://desktop";
my $scope = 'CompanyFile';
my $grant_type = "authorization_code";

my $user_email = "";

my $uri = URI::Encode->new( { encode_reserved => 1 } );
my $encoded_uri = $uri->encode($redirect_uri);

my $params = "client_id=$client_id&redirect_uri=$encoded_uri&response_type=code&scope=$scope";

my $auth_url = $url . $params;

#print "$auth_url\n";

$driver->get($auth_url);
#$driver->debug_on;
my $username_input = $driver->find_element_by_name('UserName');
my $submit_button = $driver->find_element_by_xpath('//*[@id="form-with-recaptcha"]/button');
$username_input->send_keys($user_email);
$submit_button->click();
my $password_input = $driver->find_element_by_name('Password');
$password_input->send_keys('');
my $login_button = $driver->find_element_by_xpath('//*[@id="form-with-recaptcha"]/button');
$login_button->click();

#print $driver->get_page_source;
sleep 120;

my $code = $driver->get_title;

$code = substr($code, 5);

#decode access code
my $decoded_access_code = $uri->decode($code);

## get access token

my $access_token_url = 'https://secure.myob.com/oauth2/v1/authorize';
my $header = ['Content-Type' => 'application/x-www-form-urlencoded'];
my $params_access_token = "client_id=$client_id&client_secret=$client_secret&grant_type=$grant_type&code=$decoded_access_code&redirect_uri=$encoded_uri";

my $auth_request = HTTP::Request->new('POST', $access_token_url, $header, $params_access_token);

my $ua = LWP::UserAgent->new();
my $auth_response = $ua->request($auth_request);

my $json_response = decode_json($auth_response->content);

my $access_token = $json_response->{access_token};
my $refresh_token = $json_response->{refresh_token};

#get list of company files
my $api_url = 'https://api.myob.com/accountright';
my $auth_bearer = "Bearer " . $access_token;
my $api_request_header = [
                'Authorization' => $auth_bearer, 
                'x-myobapi-key' => $client_id, 
                'x-myobapi-version' => 'v2',
                'Accept' => 'application/json'
            ];

my $api_request = HTTP::Request->new('GET', $api_url, $api_request_header);

my $api_response = $ua->request($api_request);

$json_response = decode_json($api_response->content);
my $company_file_json = $json_response->[0];
my $company_file_url = $company_file_json->{'Uri'}; 

my $supplier_payment_url = $company_file_url . "/Purchase/SupplierPayment";

$api_request = HTTP::Request->new('GET', $supplier_payment_url, $api_request_header);
$api_response = $ua->request($api_request);

print "Supplier payment:\n";
print $api_response->content;
print "\n";