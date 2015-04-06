vast-sensu-client Cookbook
===================
This cookbook will install and configure sensu client on client nodes and add check definitions on sensu server nodes 


Requirements
------------
This cookbook depends on 'sensu' cookbook
Also this cookbook requires 'sensu' data bag with three items ( data_bag/sensu/{nagios,subscriptions,ssl}.json ):
  - nagios
  - subscriptions
  - ssl (created and managed by vault)

Note: JSON structure of the items is in Usage section


Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### vast-sensu-client::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['vast-sensu-client']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>


Usage
-----

Preparation:

You can use these scripts for generating ssl item automagically (recommended):
https://github.com/sensu/sensu-chef/tree/master/examples/ssl

After you generate ssl.json you have to run 'knife vault' command in order to create ssl encrypted item on chef server:
knife vault create sensu ssl -J chef-repo/data_bag/sensu/ssl/ssl.json -S 'role:awsbase' -A admin1,admin2,adminX

Then you can manualy create remaining items (nagios.json and subscriptions.json)

nagios:

```json
{
  "id": "nagios",
  "supports": {
    "rhel": {
      "plugins_path": "/usr/lib64/nagios/plugins"
    },
    "debian": {
      "plugins_path": "/usr/lib/nagios/plugins"
    }
  },
  "plugins": [
    "check_tcp",
    "check_ssh"
  ]
}
```


subscriptions:

```json
{
  "id": "subscriptions",
  "roles": [
    "awsbase"
  ]
}
```


This is just an example of ssl item structure if you for any reason want to create it manually
ssl:

```json
{
  "id": "ssl",
  "server": {
    "key": "SERVER KEY GOES HERE",
    "cert": "SERVER CERT GOES HERE",
    "cacert": "CA CERT GOES HERE"
  },
  "client": {
    "key": "CLIENT KEY GOES HERE",
    "cert": "CLIENT CERT GOES HERE"
  }
}
```


Adding recipe on new node:

Role:
Just include `vast-sensu-client` in your role's `run_list`

```json
{
  "name": "awsbase",
  "description": "The mess we've made",
  "json_class": "Chef::Role",
  "default_attributes": {
  },
  "override_attributes": {
  },
  "chef_type": "role",
  "run_list": [
    "recipe[vast-sensu-client]"
  ],
  "env_run_lists": {
  }
}
```


Server:
Just include `awsbase` role in your node's `run_list` and add `sensu_client` attribute with value of false:
NOTE: This attribute MUST be set on every sensu server node

```json
{
  "name": "my_sensu_server",
  "chef_environment": "prod",
  "normal": {
    "sensu": {
      "sensu_client": false
    },
    "tags": [

    ]
  },
  "run_list": [
    "role[awsbase]"
  ]
}
```json


Client:
Just include `awsbase` in your node's `run_list`:

```json
{
  "name": "my_sensu_client",
  "chef_environment": "prod",
  "normal": {
    "tags": [

    ]
  },
  "run_list": [
    "role[awsbase]"
  ]
}
```


Updating vault:

After you add recipe into the run_list of every new node and before chef-client restart on that node you have to run next command from local machine in order to populate encrypted data bag (vault) with new keys 
knife vault update sensu ssl -J chef-repo/data_bag/sensu/ssl/ssl.json -S 'role:awsbase' -A admin1,admin2,adminX


License and Authors
-------------------
Authors: Milos Buncic and Ivan Savcic
