# puppet-tuned

## Overview

Install, enable and configure the tuned adaptive system tuning daemon found in
Red Hat Enterprise Linux.

* `tuned` : Class to install and enable tuned

## Examples

Install and enable tuned with the ''default'' profile :

    include tuned

Install and enable tuned with the ''virtual-host'' profile :

    class { 'tuned': profile => 'virtual-host' }

Check the output of `tuned-adm list` to see the available profiles on your
systems.

