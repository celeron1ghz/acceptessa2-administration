package Acceptessa2::Administration::Command::Circle::Create;
use strictures 2;
use feature 'state';
use Mouse;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Validator;
use namespace::clean;

with 'Acceptessa2::Administration::Role::Command';

sub run {
    my $self = shift;
    # my $ddb  = $self->ctx->aws_service('DynamoDB');
    # warn @{ $ddb->ListTables->TableNames };
}

1;
