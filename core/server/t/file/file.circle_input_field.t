use strict;
use warnings;
use Test::More;
use Path::Tiny;
use Acceptessa2::Administration::File::CircleInputField;

my $clazz = "Acceptessa2::Administration::File::CircleInputField";
my $dir   = path(__FILE__)->parent->path('toml');
my $tests = [
    {
        file     => 'mogemoge',
        expected => { error => 'file not exist' },
    },
    {
        file     => '01-empty.toml',
        expected => { error => 'invalid format: key "columns" not exist' },
    },
    {
        file     => '02-no_type.toml',
        expected => { error => "invalid format: Attribute (type) is required in columns[0]" },
    },
    {
        file     => '03-no_label.toml',
        expected => { error => "invalid format: Attribute (label) is required in columns[0]" },
    },
    {
        file     => '04-invalid_type.toml',
        expected => { error => "invalid format: unknown type 'piyo' in columns[0]" },
    },
    {
        file     => '05-valid.toml',
        expected => { success => 1 },
    },
];

plan tests => scalar @$tests;

for my $t (@$tests) {
    is_deeply $clazz->new(file => $dir->path($t->{file})->stringify)->validate(), $t->{expected};
}
