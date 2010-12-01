package MT::Plugin::Grep;
use strict;
use warnings;
use MT;
use MT::Plugin;
use base qw( MT::Plugin );

our $VERSION = '0.1';

my $plugin = MT::Plugin::Grep->new( {
    id => 'Grep',
    key => 'grep',
    name => 'Grep',
    version => $VERSION,
    description => "<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>",
    author_name => 'okayama',
    author_link => 'http://weeeblog.net/',
    l10n_class => 'Grep::L10N',
} );

MT->add_plugin( $plugin );

sub init_registry {
    my $p = shift;
    $p->registry( {
        tags => {
            block => {
                'Grep' => \&_hdlr_grep,
                'IfGrep?' => \&_hdlr_if_grep,
                'UnlessGrep?' => \&_hdlr_if_grep,
            },
        },
    } );
}

sub _hdlr_grep {
    my ( $ctx, $args, $cond ) = @_;
    my $name = $args->{ name };
    my $var = $ctx->var( $name );
    my $grep = $args->{ 'grep' };
    if ( my @grepped = _grep( $var, $grep ) ) {
        $ctx->var( $name, \@grepped );
        my $out;
        if ( MT->version_number >= 5 ) {
            $out = MT::Template::Tags::Core::_hdlr_loop( $ctx, $args, $cond );
        } else {
            $out = MT::Template::Context::_hdlr_loop( $ctx, $args, $cond );
        }
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
    if ( _grep( $var, $grep ) ) {
        return ( $ctx->stash( 'tag' ) =~ /ifgrep/i ? 1 : 0 );
    }
    return ( $ctx->stash( 'tag' ) =~ /ifgrep/i ? 0 : 1 );
}

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