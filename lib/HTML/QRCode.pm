package HTML::QRCode;

use strict;
use warnings;
our $VERSION = '0.01';

use Text::QRCode;
use Carp;

sub new {
    my ( $class, %args ) = @_;

    bless {
        text_qrcode => Text::QRCode->new,
        white => 'white',
        black => 'black',
        %args
    }, $class;
}

sub plot {
    my ( $self, $text ) = @_;
    croak 'Not enough arguments for plot()' unless $text;

    my $arref = $self->{text_qrcode}->plot($text);

    my ($white, $black) = ($self->{white}, $self->{black});
    my $w = "<td style=\"border:0;margin:0;padding:0;width:3px;height:3px;background-color: $white;\">";
    my $b = "<td style=\"border:0;margin:0;padding:0;width:3px;height:3px;background-color: $black;\">";

    my $html
        .= '<table style="margin:0;padding:0;border-width:0;border-spacing:0;">';
    $html
        .= '<tr style="border:0;margin:0;padding:0;">'
        . join( '', map { $_ eq '*' ? $b : $w } @$_ ) . '</tr>'
        for (@$arref);
    $html .= '</table>';

    return $html;
}

1;
__END__

=head1 NAME

HTML::QRCode -

=head1 SYNOPSIS

  use HTML::QRCode;

=head1 DESCRIPTION

HTML::QRCode is

=head1 AUTHOR

Hideo Kimura E<lt>hide@hide-k.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
