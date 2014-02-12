package Catalyst::View::RRDGraph;
{
  $Catalyst::View::RRDGraph::VERSION = '0.10';
}

use strict;
use warnings;

use base 'Catalyst::View';

use RRDs;
use File::Temp qw();
use MRO::Compat;

use Catalyst::Exception;

sub new {
    my ($class, $c, $arguments) = @_;
    my $config = {
        'IMG_DIR' => '/tmp/',
        'IMG_FORMAT' => 'PNG',
        'ON_ERROR_SERVE' => undef,
        %{ $class->config },
        (defined($arguments)?%{$arguments}:()),
    };

    my $self = $class->next::method(
        $c, { %$config },
    );

    $self->config($config);

    return ($self);
}

sub process {
    my ($self, $c) = @_;

    my $props = $c->stash->{'graph'};
    die "No graph in the stash" if (not defined $props);
    die "graph must be an ARRAYREF" if (ref($props) ne 'ARRAY');

    my $tempfile = File::Temp->new( TEMPLATE => 'cat_view_rrd_XXXXXX',
                                    DIR => $self->config->{'IMG_DIR'},
                                    SUFFIX => '.' . lc($self->config->{'IMG_FORMAT'}));

    RRDs::graph($tempfile->filename,
                '--imgformat', $self->config->{'IMG_FORMAT'},
                @$props);

    if (RRDs::error) {
        $self->_handle_error($c, RRDs::error);
        return;
    }
    if (-s $tempfile->filename == 0) {
        $self->_handle_error($c, "RRDgraph is 0 bytes");
        return;
    }

    $c->serve_static_file($tempfile->filename);
}

sub _handle_error {
    my ($self, $c, $error) = @_;
    if (not defined $self->config->{'ON_ERROR_SERVE'}){
        Catalyst::Exception->throw($error);
    } elsif (ref($self->config->{'ON_ERROR_SERVE'}) eq 'CODE') {
        #Call the custom handler
        $self->config->{'ON_ERROR_SERVE'}($self, $c, $error);
    } else {
        $c->log->error($error);
        $c->serve_static_file($self->config->{'ON_ERROR_SERVE'});
    }

}

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

Catalyst::View::RRDGraph - RRD Graph View Class

=head1 SYNOPSIS

use the helper to create your View myapp_create.pl view RRDGraph RRDGraph

from the controller:

  sub routine :Local {
    my ($self, $c) = @_;

    $c->stash->{'graph'} = [
            "--lower-limit", "0",
            "--start", "end-1d",
            "--vertical-label", "My Label",
            "--height", 600,
            "--width", 300,
            "DEF:Data=/path/to/rrd.rrd:data:AVERAGE",
            "AREA:Data#0000FF:Data "
    ];
    $c->forward('MyApp::View::RRDGraph');
  }

=head1 DESCRIPTION

This view generates RRD graph images from the graph defintion placed in the
stash. The controller is responsable of placing an ARRAYREF in
B<$c->stash->{'graph'}> with the same data as to generate a graph with the RRDs
module, except for I<filename>, that will be automatically generated by the
view.

It doesn't depend on RRDs, but I<does> need it to work (and for the tests to
pass). You can install RRDs, for instance, using L<Alien::RRDtool>, or
compiling it manually from L<http://oss.oetiker.ch/rrdtool/>

=head1 CONFIGURATION

Configurations for the view are:

=head2 IMG_DIR

Directory to generate temporary image files. Defaults to B</tmp/>

=head2 IMG_FORMAT

Image format for the generated files. 'PNG' by default. 

=head2 ON_ERROR_SERVE

On error, if this config value is set, the file to which it points will be
served (so you can serve an "error image" file to the user). Alternately, it
can be set to a code reference, that will called with B<$self>, B<$c> and
B<$error>. You can then generate your own content in this handler. Default
(leaving undefined) is to throw an expception.

See L<http://oss.oetiker.ch/rrdtool/doc/rrdgraph.en.html> for more info.

=head1 METHODS

=head2 new

Constructor.

=head2 process

Called internally by Catalyst when the view is used.

=head1 AUTHOR

    Jose Luis Martinez
    CPAN ID: JLMARTIN
    CAPSiDE
    jlmartinez@capside.com
    L<http://www.pplusdomain.net>

=head1 THANKS

To Ton Voon for sending in patches, tests, and ideas.

Alexander Kabenin

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

RRDs: L<http://oss.oetiker.ch/rrdtool/prog/RRDs.en.html>

RRD graph docs:
L<http://oss.oetiker.ch/rrdtool/doc/rrdgraph.en.html>,
L<http://oss.oetiker.ch/rrdtool/doc/rrdgraph_data.en.html>,
L<http://oss.oetiker.ch/rrdtool/doc/rrdgraph_graph.en.html>

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

