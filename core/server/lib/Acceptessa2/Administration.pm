package Acceptessa2::Administration;
use strict;
use warnings;
use Mouse;
use String::CamelCase;
use Class::Load;

sub to_class_name   {
    my $class = shift;
    my $val = shift or return;
    return join '::', 'Acceptessa2::Administration::Command', map { String::CamelCase::camelize $_ } split '\.', $val;
}

sub to_command_name   {
    my $class = shift;
    my $val = shift or return;
    $val =~ s/^Acceptessa2::Administration::Command:://;
    return join '.', map { String::CamelCase::decamelize $_ } split '::', $val;
}

sub load_class  {
    my($class,$type) = @_; 

    unless ($type)  {
        die("No class specified");
        # Acceptessa::Exception::SystemDefineException->throw("No class specified");
    }   

    my $command_class      = $class->to_class_name($type);
    my($is_success,$error) = Class::Load::try_load_class($command_class);

    $is_success
        or die("Fail to load $type: $error");
        # or Acceptessa::Exception::SystemDefineException->throw("Fail to load $type: $error");

    $command_class->can('does') && $command_class->does('Acceptessa2::Administration::Role::Command')
        or die("$type is not a command class");
        # or Acceptessa::Exception::SystemDefineException->throw("$type is not a command class");

    $command_class;
}

sub run_command {
    my($self,$command,$args) = @_; 
    my $command_class = $self->load_class($command);

    my $param = { 
        # tessa => $self,
        # $self->can('loggin_user') && ref $self->loggin_user eq 'HASH'
        #     ? (run_by => $self->loggin_user->{member_id})
        #     : (),
        # $self->can('request') && ref $self->request eq 'Amon2::Web::Request'
        #     ? (domain => $self->request->uri->host)
        #     : (),
        %{$args || {}},
    };

    $command_class->new(%$param)->run;
}

1;
