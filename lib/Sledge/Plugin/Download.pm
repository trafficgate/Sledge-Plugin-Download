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

__END__

=head1 NAME

Sledge::Plugin::Download - HTTP file download enhancemnet

=head1 SYNOPSIS

  package Your::Pages;
  use Sledge::Plugin::Download;

  sub dispatch_foo {
      my $self = shift;
      $self->download('foo.csv');
      while (my $line = <$fh>) {
          $self->r->print($line);
      }
  }

  # or, if your filesize is small
  sub dispatch_foo {
      my $self = shift;
      my $output = $self->read_content;
      $self->download("�ۤ��ۤ�.txt", $output);
  }

=head1 DESCRIPTIO

Sledge::Plugin::Download �ϡ��ե������������ɥ���������Ф��ݤΡ�
�֥饦���ˤ��Х����б����뤿��Υץ饰����Ǥ���

=head1 METHODS

���Υץ饰�����use����ȡ�Pages���饹�� C<download()> �᥽�åɤ��ɲä�
��ޤ������Υ᥽�åɤϡ��ե�����̾������ˤȤꡢHTTP��������ɤ򳫻�
����إå�����Ϥ��ޤ���

�ե��������Ȥ�������������Ÿ�����Ƥ�����ʤ����ˤϡ������Ȥ�
�����ѿ����ɤߤ���Ǥ����� C<download()> ����2�������Ϥ��С�
Content-Length: �ν��ϡ���ȤΥ����ȥץåȤ���֤˼¹Ԥ��ޤ���

�ե�����̾�˥ޥ���Х���ʸ������Ѥ������ Shift_JIS �ǥ��󥳡��ǥ���
�����졢UNIX���饤����ȤǤ�ʸ��������ȯ�������ǽ��������ޤ���

=head1 AUTHOR

Tatsuhiko Miyagawa <miyagawa@edge.co.jp> with Sledge development team.

=head1 SEE ALSO

L<Jcode>

=cut
