package Acceptessa2::Administration::Role::Command;
use Mouse::Role;

has ctx => (is => 'ro', isa => 'Acceptessa2::Administration', required => 1);

requires 'run';

1;
