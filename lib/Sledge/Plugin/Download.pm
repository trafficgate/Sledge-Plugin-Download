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
      $self->download("ほげほげ.txt", $output);
  }

=head1 DESCRIPTIO

Sledge::Plugin::Download は、ファイルダウンロードダイアログを出す際の、
ブラウザによるバグに対応するためのプラグインです。

=head1 METHODS

このプラグインをuseすると、Pagesクラスに C<download()> メソッドが追加さ
れます。このメソッドは、ファイル名を引数にとり、HTTPダウンロードを開始
するヘッダを出力します。

ファイルの中身が小さく、メモリ展開しても問題ない場合には、先に中身をス
カラ変数に読みこんでおいて C<download()> の第2引数に渡せば、
Content-Length: の出力、中身のアウトプットを順番に実行します。

ファイル名にマルチバイト文字を使用した場合 Shift_JIS でエンコーディン
グされ、UNIXクライアントでは文字化けが発生する可能性があります。

=head1 AUTHOR

Tatsuhiko Miyagawa <miyagawa@edge.co.jp> with Sledge development team.

=head1 SEE ALSO

L<Jcode>

=cut
