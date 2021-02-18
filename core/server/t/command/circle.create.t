use utf8;
use strict;
use warnings;
use Util;
use Test::More tests => 3;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Validator;

my ($m, $t) = mocked_instance;

# mocking validator
$t->validators->{moge} = Acceptessa2::Administration::Validator->build(
    [
        {
            column_name => 'name',
            label       => '名前',
            type        => Str,
            description => 'なまえ',
        },
        {
            column_name => 'price',
            label       => '価格',
            type        => PositiveInt,
            description => 'かかく',
        },
    ]
);

{
    $m->mock(sub { });

    my $ret = $t->run_command("circle.create", { exhibition_id => 'moge', data => {} });
    is_deeply $ret,
      {
        error => {
            name  => '「名前」は文字列で入力してください。',
            price => '「価格」は正の整数で入力してください。',
        }
      },
      'ok on api call is success';
}
{
    $m->mock(sub { });

    my $ret = $t->run_command("circle.create", { exhibition_id => 'moge', data => { name => 'moge', price => 'fuga' } });
    is_deeply $ret,
      {
        error => {
            price => '「価格」は正の整数で入力してください。',
        }
      },
      'ok on api call is success';
}
{
    $m->mock(sub { });

    my $ret = $t->run_command("circle.create", { exhibition_id => 'moge', data => { name => 'moge', price => '123' } });
    is_deeply $ret, { message => 'success' }, 'ok on api call is success';
}
