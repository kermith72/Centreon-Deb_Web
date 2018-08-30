#
# Copyright 2018 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package hardware::server::huawei::hmm::snmp::mode::components::disk;

use strict;
use warnings;

my %map_status = (
    1 => 'normal',
    2 => 'minor',
    3 => 'major',
    4 => 'critical',
);

my %map_installation_status = (
    0 => 'absence',
    1 => 'presence',
    2 => 'poweroff',
);

my $mapping = {
    bladeDiskMark            => { oid => '.1.3.6.1.4.1.2011.2.82.1.82.4.#.2009.1.2' },
    bladeDiskPresent         => { oid => '.1.3.6.1.4.1.2011.2.82.1.82.4.#.2009.1.4', map => \%map_installation_status },
    bladeDiskHealth          => { oid => '.1.3.6.1.4.1.2011.2.82.1.82.4.#.2009.1.5', map => \%map_status },
};
my $oid_bladeDiskTable = '.1.3.6.1.4.1.2011.2.82.1.82.4.#.2009.1';

sub load {
    my ($self) = @_;

    $oid_bladeDiskTable =~ s/#/$self->{blade_id}/;
    push @{$self->{request}}, { oid => $oid_bladeDiskTable };
}

sub check {
    my ($self) = @_;

    foreach my $entry (keys $mapping) {
        $mapping->{$entry}->{oid} =~ s/#/$self->{blade_id}/;
    }

    $self->{output}->output_add(long_msg => "Checking disks");
    $self->{components}->{disk} = {name => 'disks', total => 0, skip => 0};
    return if ($self->check_filter(section => 'disk'));

    foreach my $oid ($self->{snmp}->oid_lex_sort(keys %{$self->{results}->{$oid_bladeDiskTable}})) {
        next if ($oid !~ /^$mapping->{bladeDiskHealth}->{oid}\.(.*)$/);
        my $instance = $1;
        my $result = $self->{snmp}->map_instance(mapping => $mapping, results => $self->{results}->{$oid_bladeDiskTable}, instance => $instance);

        next if ($self->check_filter(section => 'disk', instance => $instance));
        next if ($result->{bladeDiskPresent} !~ /presence/);
        $self->{components}->{disk}->{total}++;
        
        $self->{output}->output_add(long_msg => sprintf("Disk '%s' status is '%s' [instance = %s]",
                                    $result->{bladeDiskMark}, $result->{bladeDiskHealth}, $instance, 
                                    ));
   
        my $exit = $self->get_severity(label => 'default', section => 'disk', value => $result->{bladeDiskHealth});
        if (!$self->{output}->is_status(value => $exit, compare => 'ok', litteral => 1)) {
            $self->{output}->output_add(severity => $exit,
                                        short_msg => sprintf("Disk '%s' status is '%s'", $result->{bladeDiskMark}, $result->{bladeDiskHealth}));
        }
    }
}

1;