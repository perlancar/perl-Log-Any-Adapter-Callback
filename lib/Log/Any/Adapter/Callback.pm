package Log::Any::Adapter::Callback;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

use Log::Any::Adapter::Util qw(make_method);
use base qw(Log::Any::Adapter::Base);

my @logging_methods = Log::Any->logging_methods;
my %logging_levels;
for my $i (0..@logging_methods-1) {
    $logging_levels{$logging_methods[$i]} = $i;
}

sub _default_level {
    return $ENV{LOG_LEVEL}
        if $ENV{LOG_LEVEL} && $logging_levels{$ENV{LOG_LEVEL}};
    return 'trace' if $ENV{TRACE};
    return 'debug' if $ENV{DEBUG};
    return 'info'  if $ENV{VERBOSE};
    return 'error' if $ENV{QUIET};
    'warning';
}

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
    if (!defined($self->{min_level})) { $self->{min_level} = _default_level() }
}

for my $method (Log::Any->logging_methods()) {
    make_method(
        $method,
        sub {
            my $self = shift;
            return if $logging_levels{$method} <
                $logging_levels{ $self->{min_level} };
            $logging_cb->($method, $self, @_);
        });
}

for my $method (Log::Any->detection_methods()) {
    make_method(
        $method,
        sub {
            $detection_cb->($method, @_);
        });
}

1;
# ABSTRACT: (DEPRECATED) Send Log::Any logs to a subroutine

=for Pod::Coverage init

=head1 SYNOPSIS

 # say, let's POST each log message to an HTTP API server
 use LWP::UserAgent;
 my $ua = LWP::UserAgent->new;

 use Log::Any::Adapter;
 Log::Any::Adapter->set('Callback',
     min_level    => 'warn',
     logging_cb   => sub {
         my ($method, $self, $format, @params) = @_;
         $ua->post("https://localdomain/log", level=>$method, Content=>$format);
         sleep 1; # don't overload the server
     },
     detection_cb => sub { ... }, # optional, default is: sub { 1 }
 );


=head1 DESCRIPTION

DEPRECATION NOTICE: Log::Any distribution since 1.708 comes with
L<Log::Any::Adapter::Capture> which does the same thing. I'm deprecating this
adapter now.

This adapter lets you specify callback subroutine to be called by L<Log::Any>'s
logging methods (like $log->debug(), $log->error(), etc) and detection methods
(like $log->is_warning(), $log->is_fatal(), etc.).

This adapter is used for customized logging, and is mostly a convenient
construct to save a few lines of code. You could achieve the same effect by
creating a full Log::Any adapter class.

Your logging callback subroutine will be called with these arguments:

 ($method, $self, $format, @params)

where $method is the name of method (like "debug") and ($self, $format, @params)
are given by Log::Any.


=head1 SEE ALSO

L<Log::Any::Adapter::Capture>

L<Log::Any>
