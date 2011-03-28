package HTML::QRCode;

use strict;
use warnings;
our $VERSION = '0.02';

use Text::QRCode;
use Carp;

sub new {
    my ( $class, @args ) = @_;

    my %args = @args;
    if (scalar(@args) == 1 && ref($args[0] eq 'HASH')) {
        %args = %{$args[0]};
    }

    # We check against use_css, white, and black for backwards compatibility.
    $args{foreground_color} = $args{foreground_color} || $args{black} || '#000';
    $args{background_color} = $args{background_color} || $args{white} || '#fff';
    $args{module_size} = '3px' unless defined $args{module_size};
    $args{table_class} = 'qr_code' unless defined $args{table_class};
    $args{use_css} = 0 unless $args{use_css} || $args{use_style};

    bless {
        text_qrcode => Text::QRCode->new,
        %args
    }, $class;
}

sub output {
    my ( $self, $text ) = @_;
    croak 'Not enough arguments for output()' unless $text;

    my $rv = '';
    if ($self->{use_css}) {
        $rv .= '<style type="text/css">' . $self->css . '</style>';
    }
    return $rv . $self->plot($text);
}

sub plot {
    my ( $self, $text ) = @_;
    croak 'Not enough arguments for plot()' unless $text;

    my $arref = $self->{text_qrcode}->plot($text);

    my $html = $self->_start_table;
    for my $module (@$arref) {
        $html .= $self->_tr( join( '', map { $self->_td($_ eq '*') } @$module ) );
    }
    $html .= $self->_end_table;

    return $html;
}

sub css {
    my $self = shift;
    return $self->{style} if $self->{style}; # for backwards compatibility.
    my $table = 'table.' . $self->{table_class};
    return "${table}{border-width:0;border-spacing:0;}"
        . "$table,$table tr, $table td{border:0;margin:0;padding:0;}"
        . "$table td{width:" . $self->{module_size} . ";height:" . $self->{module_size} . ";}"
        . "$table td.on{background-color:" . $self->{foreground_color} . ";}"
        . "$table td.off{background-color:" . $self->{background_color} . ";}"
        ;
}

sub _td {
    my ( $self, $on, $contents ) = @_;
    $contents ||= '';

    if ($self->{use_css}) {
        my $class = $on ? 'on' : 'off';
        return qq{<td class="$class">$contents</td>};
    } else {
        my $color = $on ? $self->{foreground_color} : $self->{background_color};
        return qq{<td style="border:0;margin:0;padding:0;width:} . $self->{module_size} . qq{;height:} . $self->{module_size} . qq{;background-color:$color;">$contents</td>};
    }
}
sub _tr {
    my ( $self, $contents ) = @_;
    $contents ||= '';
    return (($self->{use_css} ? '<tr>' : '<tr style="border:0;margin:0;padding:0;">') . $contents . '</tr>');
}
sub _start_table {
    my $self = shift;
    return $self->{use_css} ? '<table class="' . $self->{table_class} . '">' : '<table style="margin:0;padding:0;border-width:0;border-spacing:0;">';
}
sub _end_table { return '</table>' }


1;
__END__

=encoding utf8

=head1 NAME

HTML::QRCode - Generate HTML based QR Code

=head1 SYNOPSIS

  #!/usr/bin/env perl

  use HTML::QRCode;
  use CGI

  my $q = CGI->new;
  my $text = $q->param('text') || 'http://example.com/';

  my $qrcode = HTML::QRCode->new(use_css => 1)->output($text);

  print $q->header;
  print <<"HTML";
  <html>
  <head></head>
  <body>
  $qrcode
  </body>
  </html>
  HTML

=head1 DESCRIPTION

HTML::QRCode generates HTML tables representing QR codes. Please note this 
requires C<libqrencode>.

=begin html

<p>Here is an example of a QR code rendered with this module:</p>
<style type="text/css">table.qr_code{border-width:0;border-spacing:0;}table.qr_code,table.qr_code tr, table.qr_code td{border:0;margin:0;padding:0;}table.qr_code td{width:3px;height:3px;}table.qr_code td.on{background-color:#000;}table.qr_code td.off{background-color:#fff;}</style><table class="qr_code"><tr><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td></tr><tr><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td></tr><tr><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td></tr><tr><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td></tr><tr><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td></tr><tr><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td></tr><tr><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td></tr><tr><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td></tr><tr><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td></tr><tr><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td></tr><tr><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td></tr><tr><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td></tr><tr><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td></tr><tr><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td></tr><tr><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td></tr><tr><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td></tr><tr><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td></tr><tr><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="off"></td><td class="on"></td><td class="on"></td><td class="off"></td><td class="on"></td><td class="on"></td></tr></table>

=end html

=head1 METHODS

=over 4

=item new

    $qrcode = HTML::QRCode->new(%params);

The C<new()> constructor method instantiates a new HTML::QRCode object. It can
take any of the following options in the C<%params> hash:

=over 4

=item use_css

I<Recommended>. If you provide a true value for this option,
the generated HTML will use CSS classes to format the output. Otherwise, all
style information is embedded in C<style> attributes applied directly
to the the HTML.

This option signficantly reduces the size of the HTML, and is highly
recommended.

=item foreground_color

A CSS value for foreground color. Default is "#000" (black).

=item background_color

A CSS value for background color. Default is "#fff" (white).

=item module_size

A CSS value for size of an individual module (dot) in the QR code.
Default is "3px".

=item table_class

The class applied to the generated C<< <table >>. Default is "qr_code".

=back

=item output($text)

    $html = $qrcode->output("blah blah");

This returns the C<table> and C<style> HTML tags necessary to render the QR code.

=item plot($text)

    $html = $qrcode->plot("blah blah");

This method is similar to L<output|/"output($text)">, but along with the
L</css> method, gives you tighter control over rendering.

This returns an HTML table representing the QR code. This does not include
the C<style> HTML tags, so is useful for providing a custom stylesheet.
It is also useful for putting the output of L</css> into the document
headers to ensure valid XHTML, or when rendering multiple QR codes.

See C<example/qrcode_css.cgi> included in this distribution.

=item css

    $css = $qrcode->css();

Returns the styles that can be added to your stylesheet.  It does not include
the C<style> tag, only the contents of it.

=back

=head1 AUTHOR

Hideo Kimura E<lt>hide <at> hide-k.netE<gt>

Yoshiki Kurihara

Yappo

nipotan

Mark A. Stratman E<lt>stratman@gmail.comE<gt>

=head1 SEE ALSO

=over

=item L<Text::QRCode>

=item L<Imager::QRCode>

=item L<Term::QRCode>

=item L<HTML::QRCode>

=item L<http://www.qrcode.com/>

=item L<http://megaui.net/fukuchi/works/qrencode/index.en.html>

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
