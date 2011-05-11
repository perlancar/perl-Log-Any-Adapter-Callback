package Log::Any::Adapter::Callback;
# ABSTRACT: Send Log::Any logs to a subroutine

use 5.010;
use strict;
use warnings;

use Log::Any::Adapter::Util qw(make_method);
use base qw(Log::Any::Adapter::Base);

my ($logging_cb, $detection_cb);
sub init {
    my ($self) = @_;
    $logging_cb   = $self->{logging_cb}
        or die "Please provide logging_cb when initializing ".__PACKAGE__;
    if ($self->{detection_cb}) {
        $detection_cb = $self->{detection_cb};
    } else {
        $detection_cb = sub { 1 };
    }
}

for my $method (Log::Any->logging_methods()) {
    make_method($method, sub { $logging_cb->($method, @_) });
}

for my $method (Log::Any->detection_methods()) {
    make_method($method, sub { $detection_cb->($method, @_) });
}

1;
__END__

=head1 SYNOPSIS

 use Log::Any::Adapter;
 Log::Any::Adapter->set('Callback',
     logging_cb   => sub { ... },
     detection_cb => sub { ... }, # optional, default is: sub { 1 }
 );

=head1 DESCRIPTION

This adapter lets you specify callback subroutine to be called by Log::Any's
logging methods (like $log->debug(), $log->error(), etc) and detection methods
(like $log->is_warning(), $log->is_fatal(), etc.).

This adapter is used for customized logging, and is mostly a convenient
construct to save a few lines of code. You could achieve the same effect by
creating a full Log::Any adapter class.

Your logging callback subroutine will be called with these arguments:

 ($method, $self, $format, @params)

where $method is the name of method (like "debug") and ($self, $format, @params)
are given by Log::Any.

=for Pod::Coverage init

=head1 SEE ALSO

L<Log::Any>
