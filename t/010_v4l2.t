# Copyright (c) 2014  Timm Murray
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
use Test::More;
use v5.14;
use Device::WebIO;
use Device::WebIO::GStreamerVideo::V4l2;

if( -e '/dev/video0' ) {
    plan tests => 4;
}
else {
    plan skip_all => 'Need at least one /dev/video* device to test';
}


my $vid = Device::WebIO::GStreamerVideo::V4l2->new({
});
my $webio = Device::WebIO->new;
$webio->register( 'foo', $vid );

ok( $vid->does( 'Device::WebIO::Device' ), "Does Device role" );
ok( $vid->does( 'Device::WebIO::Device::VideoOutput' ),
    "Does VideoOutput role" );
ok( $vid->does( 'Device::WebIO::GStreamerVideo' ),
    "Does GStreamerVideo role" );

my $fh = $webio->vid_stream( 'foo', 0, 'video/avi' );
cmp_ok( ref($fh), 'eq', 'GLOB', "Got video stream" );
close $fh;
