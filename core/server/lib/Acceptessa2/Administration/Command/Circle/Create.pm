package Acceptessa2::Administration::Command::Circle::Create;
use Mouse;

with 'Acceptessa2::Administration::Role::Command';

sub run {
    my $self = shift;
    my $ddb  = $self->ctx->aws_service('DynamoDB');
    warn @{ $ddb->ListTables->TableNames };
}

1;
