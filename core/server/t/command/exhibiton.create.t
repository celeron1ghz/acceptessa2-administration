use strict;
use warnings;
use Util;
use Test::More tests => 3;

my ($m, $t) = mocked_instance;

{
    $m->mock(sub { });

    my $ret = $t->run_command("exhibition.create", { exhibition_id => 'aabb', exhibition_name => 'aabbcc' });
    is_deeply $ret, { message => 'success' }, 'ok on api call is success';
}
{
    $m->mock(sub { die 'error from inside' });

    my $ret = $t->run_command("exhibition.create", { exhibition_id => 'aabb', exhibition_name => 'aabbcc' });
    my $raw = delete $ret->{raw_message};
    is_deeply $ret, { error => 1, message => 'create failed' }, 'error on api call is die';
    like $raw, qr/^error from inside/;
}
