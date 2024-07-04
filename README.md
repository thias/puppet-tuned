# puppet-tuned

## Overview

Install, enable and configure the tuned adaptive system tuning daemon found in
Red Hat Enterprise Linux.

* `tuned` : Class to install and enable tuned

## Examples

Install and enable tuned with the ''default'' profile :

```puppet
include '::tuned'
```

Install and enable tuned with the ''virtual-host'' profile :

```puppet
class { '::tuned': profile => 'virtual-host' }
```

Check the output of `tuned-adm list` to see the available profiles on your
systems.

Install and enable tuned with a custom profile, contained in another module :

```puppet
class { '::tuned':
  profile => 'my-super-tweaks',
  source  => 'puppet:///modules/mymodule/tuned-profiles/my-super-tweaks',
}
```

The above expects
`modules/mymodule/files/tuned-profiles/my-super-tweaks/tuned.conf` and may
include additional scripts next to `tuned.conf`.

Install and enable tuned with a custom profile :

```puppet
class { '::tuned':
  profile  => 'my-super-tweaks',
  settings => {
    'main'   => {
      'include' => 'virtual-guest',
    },
    'sysctl' => {
      'vm.dirty_ratio' => '30',
      'vm.swappiness'  => '30',
    },
  },
}
```

To completely stop, disable and remove tuned :

```puppet
class { '::tuned': ensure => 'absent' }
```

