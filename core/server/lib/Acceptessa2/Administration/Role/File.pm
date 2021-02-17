package Acceptessa2::Administration::Role::File;
use Mouse::Role;

has file => (is => 'ro', isa => 'Str', required => 1);

requires 'validate';

1;
