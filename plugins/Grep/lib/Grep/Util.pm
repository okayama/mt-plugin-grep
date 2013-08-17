package Grep::Util;
use strict;

sub _grep {
    my ( $items, $search ) = @_;
    return 0 unless $items && ( ( ref( $items ) eq 'ARRAY' ) && ( scalar @$items ) );
    return 0 unless $search;
    if ( $search =~ m!^(/)(.+)\1([A-Za-z]+)?$! ) {
        $search = $2;
        if ( my $option = $3 ) {
            if ( $option eq 'i' ) {
                return grep { $_ =~ /$search/i } @$items;
            }
        }
        return grep { $_ =~ /$search/ } @$items;
    } else {
        return grep { $_ eq $search } @$items;
    }
    return 0;
}

1;
