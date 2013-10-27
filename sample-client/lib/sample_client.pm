package sample_client;

use strict;
use warnings;

use Dancer ':syntax';
use URI;
use URI::QueryParam;

our $VERSION = '0.1';

get '/' => sub {
    my $oauth = config->{oauth};
    my $susi_oauth_url = URI->new($oauth->{url});

    $susi_oauth_url->query_param(response_type => $oauth->{response_type});
    $susi_oauth_url->query_param(client_id => $oauth->{client_id});
    $susi_oauth_url->query_param(redirect_uri => $oauth->{redirect_uri});

    template 'index', {susi_oauth_url => $susi_oauth_url->as_string};
};

get '/dashboard' => sub {
    template 'dashboard';
};

true;
