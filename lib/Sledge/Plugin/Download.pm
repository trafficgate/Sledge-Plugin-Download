package Sledge::Plugin::Download;
# $Id$
#
# Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
# Livin' On The EDGE, Limited.
#

use strict;
use vars qw($VERSION);
$VERSION = 0.02;

use vars qw(@ISA @EXPORT);

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(download);

sub download {
    my($self, $filename, $content) = @_;
    my $type = _dispatch_type($self, $filename);
    $self->r->header_out('Content-Disposition' => $type->{disposition});
    $self->r->content_type($type->{type});

    if (defined $content) {
	$self->r->header_out('Content-Length' => length $content);
	$self->r->send_http_header;
	$self->r->print($content);
    }
    else {
	$self->r->send_http_header;
    }
    $self->finished(1);		# may be early, but no problem
}

sub _dispatch_type {
    my($self, $filename) = @_;
    my $ua = $self->r->header_in('User-Agent');
    my $name = _convert($filename);

    if ($ua !~ /Mac/ && $ua =~ /MSIE/) {
	my($ver) = $ua =~ /MSIE ([\d\.]+)/;
	if ($ver < 5) {
	    return {
		disposition => "inline; filename=$name",
		type => "application/download; name=$name",
	    };
	}
	else {
	    return {
		disposition => "attachment; filename=$name",
		type => "application/download; name=$name",
	    };
	}
    }
    else {
	return {
	    disposition => "attachment; filename=$name",
	    type => "application/octet-stream; name=$name",
	};
    }
}

sub _convert {
    my $name = shift;
    return $name if $name =~ /^[\x00-\x7f]+$/; # ascii

    require Jcode;
    return Jcode->new($name)->sjis;
}

1;
