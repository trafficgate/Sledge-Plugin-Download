# $Id$
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Limited.
#

use strict;
use Test::More 'no_plan';

use CGI;
use IO::Scalar;
use Jcode;

use Sledge::Request::CGI;

package Mock::Pages;
use base qw(Sledge::Pages::CGI);
use Sledge::Plugin::Download;

package main;

my $page = bless {}, 'Mock::Pages';
$page->{r} = Sledge::Request::CGI->new(CGI->new({}));

{
    local $ENV{HTTP_USER_AGENT} = 'MSIE/Mac';
    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->download('foo.csv');
    untie *STDOUT;

    like $out, qr/Content-Disposition: attachment; filename=foo\.csv/;
    like $out, qr@Content-Type: application/octet-stream; name=foo\.csv@;
}

{
    local $ENV{HTTP_USER_AGENT} = 'MSIE 4.0';
    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->download('foo.csv');
    untie *STDOUT;

    like $out, qr/Content-Disposition: inline; filename=foo\.csv/;
    like $out, qr@Content-Type: application/download; name=foo\.csv@;
}

{
    local $ENV{HTTP_USER_AGENT} = 'Mozilla';
    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->download('foo.csv');
    untie *STDOUT;

    like $out, qr/Content-Disposition: attachment; filename=foo\.csv/;
    like $out, qr@Content-Type: application/octet-stream; name=foo\.csv@;
}

{
    local $ENV{HTTP_USER_AGENT} = 'MSIE 5.5';
    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->download('foo.csv');
    untie *STDOUT;

    like $out, qr/Content-Disposition: attachment; filename=foo\.csv/;
    like $out, qr@Content-Type: application/download; name=foo\.csv@;
}

{
    local $ENV{HTTP_USER_AGENT} = 'MSIE 5.5';
    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->download('ほげ.csv');
    untie *STDOUT;

    my $filename = Jcode->new('ほげ.csv')->sjis;
    like $out, qr/Content-Disposition: attachment; filename=$filename/;
    like $out, qr@Content-Type: application/download; name=$filename@;
}

{
    local $ENV{HTTP_USER_AGENT} = 'MSIE 5.5';
    tie *STDOUT, 'IO::Scalar', \my $out;
    $page->download('ほげ.csv', 'hogehoge');
    untie *STDOUT;

    like $out, qr/hogehoge/, $out;
    like $out, qr/Content-Length: 8/, 'Content-Length';
    is $page->finished, 1, 'finished';
}



