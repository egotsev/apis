package sample_client;

use strict;
use warnings;

use Dancer ':syntax';
use URI;
use URI::QueryParam;
use List::MoreUtils qw(any);
use LWP::UserAgent;
use MIME::Base64 qw(encode_base64);
use JSON qw(decode_json);

our $VERSION = '0.1';

our @public_paths = (
    qr/^\/$/,
    qr/^\/susi_oauth$/
);

sub is_public_path {
    my $path = shift;

    return any { $path =~ $_ } @public_paths;
}

hook before => sub {
    my $path = request->path();

    if (is_public_path($path)) {
        return;
    }

    if (not session->{access_token}) {
        redirect '/';
    }
};

get '/' => sub {
    my $oauth = config->{oauth};
    my $susi_oauth_url = URI->new($oauth->{auth_url});

    $susi_oauth_url->query_param(response_type => $oauth->{response_type});
    $susi_oauth_url->query_param(client_id => $oauth->{client_id});
    $susi_oauth_url->query_param(redirect_uri => $oauth->{redirect_uri});
    $susi_oauth_url->query_param(grant_type => 'authorization_code');
    $susi_oauth_url->query_param(scope => @{$oauth->{scopes} || []});

    template 'index', {susi_oauth_url => $susi_oauth_url->as_string};
};

get '/susi_oauth' => sub {
    my %params = params();

    my $code = $params{code};

    if (!$code or $params{error}) {
        my $error_description = $params{'error_description'} || "An unknown error occurred";
        return template('oauth_error', {description => $error_description});
    }

    my $oauth = config->{oauth};

    my $auth = 'Basic ' . encode_base64($oauth->{client_id} . ':' . $oauth->{client_secret});

    my $ua = LWP::UserAgent->new();
    $ua->default_header('Authorization' => $auth);

    my $response = $ua->post(
        $oauth->{token_url},
        {
            grant_type => 'authorization_code',
            redirect_uri => $oauth->{redirect_uri},
            code => $code,
            scope => @{$oauth->{scopes} || []}
        }
    );

    my $result = $response->decoded_content();

    debug $result;

    my $data = decode_json($result);

    if ($data->{error}) {
        return template('oauth_error', {description => $data->{error_description}});
    } else {
        session(access_token => $data->{access_token}, token_type => $data->{token_type});
        redirect '/dashboard'
    }
};

get '/dashboard' => sub {
    debug session;
    template 'dashboard';
};

true;
