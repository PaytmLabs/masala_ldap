# masala_ldap

This is a component of the [masala toolkit](https://github.com/PaytmLabs/masala).

This is a [wrapper cookbook](http://blog.vialstudios.com/the-environment-cookbook-pattern/#thewrappercookbook) for providing recipes for openldap for server deployment, an LWRP for user management in LDAP, and client auth setup 

## Supported Platforms

The platforms supported are:
- Centos 6.7+ / Centos 7.1+
- Ubuntu 14.04 LTS (And future LTS releases)
- Debioan 8.2+

## Attributes

Please also see the documentation for the cookbooks included by masala_ldap. (See [metadata.rb](https://github.com/PaytmLabs/masala_ldap/blob/develop/metadata.rb) file)

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['masala_ldap']['slapd_type']</tt></td>
    <td>String</td>
    <td>Used internally in the cookbook to indicate type of openldap server to manage. Valid values are "master", "slave", or nil for a standalone LDAP instance. Not normally set by other recipes.</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['masala_ldap']['rootpw_clear']</tt></td>
    <td>String</td>
    <td>Non-hashed version of the password in node['openldap']['rootpw'], used by the providers to access the LDAP server for writing data.</td>
    <td><tt>devuser</tt></td>
  </tr>
  <tr>
    <td><tt>['masala_ldap']['org_name']</tt></td>
    <td>String</td>
    <td>The organization name that will be set on the top level LDAP base DN record's "o" attribute</td>
    <td><tt>Masala</tt></td>
  </tr>
  <tr>
    <td><tt>['masala_ldap']['data_bag_item']</tt></td>
    <td>String</td>
    <td>The name of the data bag in ldap_data that should be used as a source with which to populate user data</td>
    <td><tt>example_users</tt></td>
  </tr>
  <tr>
    <td><tt>['masala_ldap']['service']['sshd']</tt></td>
    <td>String</td>
    <td>Used internally in the cookbook to send the correct restart signal to openssh after enabling ssh key from LDAP. Do not set.</td>
    <td><tt>Depends on platform</tt></td>
  </tr>
</table>

## Usage

### masala_ldap::master

Installs/Configures an openldap slapd in master mode and populates user data from a data bag

Include `masala_ldap::master` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[masala_ldap::master]"
  ]
}
```

### masala_ldap::slave

Installs/Configures an openldap slapd in replica (slave) mode.

Include `masala_ldap::slave` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[masala_ldap::slave]"
  ]
}
```
### masala_ldap::auth_sssd

Installs/Configures sssd and configures to allow for LDAP-based authentication to login to a system .

Include `masala_ldap::auth_sssd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[masala_ldap::auth_sssd]"
  ]
}
```

## License, authors, and how to contribute

See:
- [LICENSE](https://github.com/PaytmLabs/masala_ldap/blob/develop/LICENSE)
- [MAINTAINERS.md](https://github.com/PaytmLabs/masala_ldap/blob/develop/MAINTAINERS.md)
- [CONTRIBUTING.md](https://github.com/PaytmLabs/masala_ldap/blob/develop/CONTRIBUTING.md)

