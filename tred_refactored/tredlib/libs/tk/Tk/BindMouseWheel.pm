package Tk::BindMouseWheel;

use strict;
use warnings;

# This module actually only adds features to Tk::Widget

use Tk;

my $scrolling_step = 3;

sub Tk::Widget::BindMouseWheelVert {
    my ( $w, $modifier, @tags ) = @_;
    if ($modifier) {
        $modifier .= q{-};
    }
    else {
        $modifier = q{};
    }
    $w->bind(
        @tags,
        "<$modifier" . 'MouseWheel>',
        [   sub {
                $_[1]->yview( 'scroll', -( $_[2] / 120 ) * $scrolling_step, 'units' );
            },
            $w,
            Tk::Ev("D")
        ]
    );
    if ( $Tk::platform eq 'unix' ) {
        $w->bind(
            @tags,
            "<$modifier" . '4>',
            [   sub {
                    if (!$Tk::strictMotif) {
                        $_[1]->yview( 'scroll', -$scrolling_step, 'units' );
                    }
                },
                $w
            ]
        );
        $w->bind(
            @tags,
            "<$modifier" . '5>',
            [   sub {
                    if (!$Tk::strictMotif) {
                        $_[1]->yview( 'scroll', $scrolling_step, 'units' );
                    }
                },
                $w
            ]
        );
        if ( $modifier eq q{} ) {
            $w->bind(
                @tags, '<6>',
                sub {
                    if (!$Tk::strictMotif) {
                        $_[0]->xview( 'scroll', -$scrolling_step, 'units' );
                    }
                }
            );
            $w->bind(
                @tags, '<7>',
                sub {
                    if (!$Tk::strictMotif) {
                        $_[0]->xview( 'scroll', $scrolling_step, 'units' );
                    }
                }
            );
        }
    }
    return;
}

sub Tk::Widget::BindMouseWheelHoriz {
    my ( $w, $modifier ) = @_;
    if ($modifier) {
        $modifier .= q{-};
    }
    else {
        $modifier = q{};
    }
    $w->bind(
        "<$modifier" . 'MouseWheel>',
        [   sub {
            $_[0]->xview( 'scroll', -( $_[1] / 120 ) * $scrolling_step, 'units' ) },
            Tk::Ev('D')
        ]
    );
    if ( $Tk::platform eq 'unix' ) {
        $w->bind(
            "<$modifier" . '4>',
            sub {
                if (!$Tk::strictMotif) {
                    $_[0]->xview( 'scroll', -$scrolling_step, 'units' );
                }
            }
        );
        $w->bind(
            "<$modifier" . '5>',
            sub {
                if (!$Tk::strictMotif) {
                    $_[0]->xview( 'scroll', $scrolling_step, 'units' );
                }
            }
        );
    }
    return;
}

1;
