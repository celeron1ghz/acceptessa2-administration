use strict;
use warnings;
use Test::More;
use Path::Tiny;
use Acceptessa2::Administration::File::ExhibitionLogo;

my $clazz = "Acceptessa2::Administration::File::ExhibitionLogo";
my $dir   = path(__FILE__)->parent->path('image');
my $tests = [
    { file => 'mogemoge',      expected => { error   => 'file not exist' } },
    { file => '90x60jpg.jpg',  expected => { error   => 'width/height ratio should 2' } },
    { file => '120x60bmp.bmp', expected => { success => 1 } },
    { file => '120x60jpg.jpg', expected => { success => 1 } },
    { file => '120x60png.png', expected => { success => 1 } },
];

plan tests => scalar @$tests;

for my $t (@$tests) {
    is_deeply $clazz->new(file => $dir->path($t->{file})->stringify)->validate(), $t->{expected};
}
