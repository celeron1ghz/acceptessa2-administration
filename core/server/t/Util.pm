package    # test class
  test {
    use Moose;

    with 'Paws::Net::CallerRole';

    has mock => (is => 'rw', isa => 'CodeRef');

    sub do_call {
        my $self = shift;
        $self->mock->(@_);
    }
}

package Util;
use strict;
use warnings;
use Paws;
use Acceptessa2::Administration;

use parent qw/Exporter/;
our @EXPORT = qw/mocked_instance/;

sub mocked_instance {
    my $mock = test->new;
    my $paws = Paws->new(config => { caller => $mock });
    my $t    = Acceptessa2::Administration->new(paws => $paws);
    return ($mock, $t);
}

# BEGIN {
#     unless ($ENV{PLACK_ENV}) {
#         $ENV{PLACK_ENV} = 'test';
#     }
# }

# {
#     # utf8 hack.
#     binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;
#     no warnings 'redefine';
#     my $code = \&Test::Builder::child;
#     *Test::Builder::child = sub {
#         my $builder = $code->(@_);
#         binmode $builder->output,         ":utf8";
#         binmode $builder->failure_output, ":utf8";
#         binmode $builder->todo_output,    ":utf8";
#         return $builder;
#     };
# }

1;
