package Acceptessa2::Administration;
use strictures 2;
use feature 'state';
use Mouse;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Validator;
use Paws;
use String::CamelCase;
use Class::Load;
use namespace::clean;

has paws       => (is => 'ro', isa => 'Paws',    default => sub { Paws->new });
has validators => (is => 'ro', isa => 'HashRef', default => sub { +{} });

method to_class_name(Str $val) {
    return join '::', 'Acceptessa2::Administration::Command', map { String::CamelCase::camelize $_ } split '\.', $val;
}

method to_command_name(Str $val) {
    $val =~ s/^Acceptessa2::Administration::Command:://;
    return join '.', map { String::CamelCase::decamelize $_ } split '::', $val;
}

sub load_class {
    my ($class, $type) = @_;

    unless ($type) {
        die("No class specified");

        # Acceptessa::Exception::SystemDefineException->throw("No class specified");
    }

    my $command_class = $class->to_class_name($type);
    my ($is_success, $error) = Class::Load::try_load_class($command_class);

    $is_success
      or die("Fail to load $type: $error");

    # or Acceptessa::Exception::SystemDefineException->throw("Fail to load $type: $error");

    $command_class->can('does') && $command_class->does('Acceptessa2::Administration::Role::Command')
      or die("$type is not a command class");

    # or Acceptessa::Exception::SystemDefineException->throw("$type is not a command class");

    $command_class;
}

sub aws_service {
    my ($self, $service, @args) = @_;
    $self->paws->service($service, region => 'ap-northeast-1', @args);
}

sub dynamodb {
    my ($self) = @_;
    $self->aws_service('DynamoDB');
}

sub run_command {
    my ($self, $command, $args) = @_;
    my $command_class = $self->load_class($command);

    my $param = {
        ctx => $self,

        %{ $args || {} },
    };

    $command_class->new(%$param)->run;
}

method get_validator(Str $exhibition_id) {
    if (!$self->validators->{$exhibition_id}) {
        $self->validators->{$exhibition_id} = 1;
    }

    return $self->validators->{$exhibition_id};
}

1;
