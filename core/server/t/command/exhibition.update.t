use strict;
use warnings;
use Util;
use Test::More;

plan tests => 5;

my ($m, $t) = mocked_instance;

{
    my $ret = $t->run_command("exhibition.update", { id => 'aa', key => 'bb', value => undef });
    is_deeply $ret, { error => 1, message => 'invalid key' }, 'error on specify not exist key';
}
{
    my $ret = $t->run_command("exhibition.update", { id => 'aa', key => 'exhibition_name', value => undef });
    is_deeply $ret, { error => 1, message => 'validation failed' }, 'error on validation failed';
}
{
    $m->mock(sub { });

    my $ret = $t->run_command("exhibition.update", { id => 'aa', key => 'exhibition_name', value => "112233" });
    is_deeply $ret, { message => 'success' }, 'ok on valid value';
}
{
    $m->mock(sub { die 'error from inside' });

    my $ret = $t->run_command("exhibition.update", { id => 'aa', key => 'exhibition_name', value => "445566" });
    my $raw = delete $ret->{raw_message};
    is_deeply $ret, { error => 1, message => 'update failed' }, 'error on api call is die';
    like $raw, qr/^error from inside/;
}
