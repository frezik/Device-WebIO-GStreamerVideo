package Device::WebIO::GStreamerVideo::V4l2;

use v5.12;
use Moo;

use constant DEFAULT_KBPS => 0;
use constant vid_allowed_content_types => [qw{
    video/avi
    video/h264
}];

has '_kbps_by_channel' => (
    is      => 'rw',
    default => sub {[]},
);


sub vid_channels
{
    my ($self) = @_;
    my @vid_channels = glob( "/dev/video*" );
    my $count = scalar @vid_channels;
    return $count;
}

sub vid_kbps
{
    my ($self, $pin) = @_;
    return $self->_kbps_by_channel->[$pin];
}


{
    my %SUBS = (
        width  => qr!Width/Height\s*:\s* (\d+)/\d+ !x,
        height => qr!Width/Height\s*:\s* \d+/(\d+) !x,
        fps    => qr!Frames\s+per\s+second\s*:\s* ([\d\.]+)!x,
    );
    foreach (keys %SUBS) {
        no strict 'refs';
        my $slot = 'vid_' . $_;
        my $regex = $SUBS{$_};

        *$slot = sub {
            my ($self, $pin) = @_;
            my $v4l2_text = $self->_get_v4l_text( $pin );

            my ($value) = $v4l2_text =~ $regex;
            return $value;
        };
    }
}

sub vid_set_height
{
    my ($self, $pin, $height) = @_;
    $pin =~ s/\D//g;
    $height =~ s/\D//g;

    my $exec = 'v4l2-ctl -d /dev/video' . $pin
        . ' --set-fmt-video=height=' . $height;

    if( system( $exec ) != 0 ) {
        die "Could not execute '$exec': $!\n";
    }

    return 1;
}

sub vid_set_width
{
    my ($self, $pin, $width) = @_;
    $pin =~ s/\D//g;
    $width =~ s/\D//g;

    my $exec = 'v4l2-ctl -d /dev/video' . $pin
        . ' --set-fmt-video=width=' . $width;

    if( system( $exec ) != 0 ) {
        die "Could not execute '$exec': $!\n";
    }

    return 1;
}

sub vid_set_fps
{
    my ($self, $pin, $fps) = @_;
    $pin =~ s/\D//g;
    $fps =~ s/\D//g;

    my $exec = 'v4l2-ctl -d /dev/video' . $pin
        . ' --set-parm=' . $fps;

    if( system( $exec ) != 0 ) {
        die "Could not execute '$exec': $!\n";
    }

    return 1;
}

sub vid_set_kbps
{
    my ($self, $pin, $kbps) = @_;
    $self->_kbps_by_channel->[$pin] = $kbps;
    return 1;
}


sub vid_stream
{
    my ($self, $pin, $type) = @_;
    $pin =~ s/\D//g;
    my $width  = $self->vid_width( $pin );
    my $height = $self->vid_height( $pin );
    # v4l2-ctl may report decimal number places, but gst won't process that
    my $fps    = sprintf '%.0f', $self->vid_fps( $pin );
    my $fh;
    my $exec;

    if( $type eq 'video/avi' ) {
        $exec = "gst-launch-1.0 -e"
            . " v4l2src device=/dev/video$pin !"
            . " 'video/x-raw,width=$width,height=$height,framerate=$fps/1' !"
            . " x264enc !"
            . " avimux name=mux !"
            . " filesink location=/dev/stdout"
            . " alsasrc device=hw:1,0 !" # TODO audio device config
            . " audioconvert !"
            . " 'audio/x-raw,rate=44100,channels=2' !"
            . " lamemp3enc !"
            . " mux.";
    }
    elsif( $type eq 'video/h264' ) {
        $exec = "gst-launch-1.0 v4l2src device=/dev/video$pin !"
            . " queue !"
            . " 'video/x-raw,width=$width,height=$height,framerate=$fps/1' !"
            . " xvimagesink sync=false";
    }

    open( $fh, '-|', $exec )
        or die "Can't execute '$exec': $!\n";
    return $fh;
}


sub _get_v4l_text
{
    my ($self, $pin) = @_;
    $pin =~ s/\D//g;

    my $dev = '/dev/video' . $pin;
    my $exec = 'v4l2-ctl -d ' . $dev . ' --all';

    my $text = `$exec`;
    return $text;
}


with 'Device::WebIO::GStreamerVideo';
1;
