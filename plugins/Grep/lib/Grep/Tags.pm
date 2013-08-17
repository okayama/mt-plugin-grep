package Grep::Tags;
use strict;

use Grep::Util;

sub _hdlr_grep {
    my ( $ctx, $args, $cond ) = @_;
    my $name = $args->{ name };
    my $var = $ctx->var( $name );
    my $grep = $args->{ 'grep' };
    if ( my @grepped = Grep::Util::_grep( $var, $grep ) ) {
        $ctx->var( $name, \@grepped );
        my $out = MT::Template::Tags::Core::_hdlr_loop( $ctx, $args, $cond );
        $ctx->var( $name, $var );
        return $out;
    } else {
        return $ctx->_hdlr_pass_tokens_else( @_ );
    }
}

sub _hdlr_if_grep {
    my ( $ctx, $args, $cond ) = @_;
    my $name = $args->{ name };
    my $var = $ctx->var( $name );
    my $grep = $args->{ 'grep' };
    if ( Grep::Util::_grep( $var, $grep ) ) {
        return ( $ctx->stash( 'tag' ) =~ /ifgrep/i ? 1 : 0 );
    }
    return ( $ctx->stash( 'tag' ) =~ /ifgrep/i ? 0 : 1 );
}

1;
