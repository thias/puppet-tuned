#### 2016-02-11 - 1.0.3
* Fix ordering, the service must be running to set profile with tuned-adm.

#### 2015-04-28 - 1.0.2
* Notify service(s) when the profile files change.

#### 2015-04-01 - 1.0.1
* Set default profile to 'balanced' on RHEL7 and Fedora.

#### 2014-11-11 - 1.0.0
* Add support for newer RHEL/CentOS 7 (#7, @stzilli).

#### 2014-04-08 - 0.2.1
* Make tuned fail gracefully on unsupported systems (idea from cstackpole).
* Add support for CloudLinux (#3, Maurits Landewers).
* Fix missing /sbin from tuned-adm profile exec (#5, @mlehner616).

#### 2013-03-07 - 0.2.0
* Support external custom profiles.
* Support ensure => absent for removal.
* Change to 2 space indent.
* Add examples and use markdown for the README.

#### 2012-10-11 - 0.0.1
* Initial module release.

