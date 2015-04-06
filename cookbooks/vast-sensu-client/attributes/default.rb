##################
## Sensu Client ##
##################

### Plugins and client definition
# NOTE: This attribute MUST be set on every sensu server node with a value of false
# Example:      
#   knife node edit $sensu-server-name
#
#   "normal": {
#     "sensu": {
#       "sensu_client": false
#     },
#     "tags": [
#     ]
#   }
default.sensu.sensu_client = true

default.sensu.use_nagios_plugins = true
default.sensu.rhel.nagios_plugin_packages = ["nagios-plugins-all"]
default.sensu.debian.nagios_plugin_packages = ["nagios-plugins-basic"]

default.sensu.default_handlers = ["flapjack"]
default.sensu.metric_handlers = ["relay"]

default.sensu.use_local_ipv4 = false

default.sensu.additional_client_attributes = {
  "keepalive" => {
      "type" => "metric",
      "thresholds" => {
        "warning" => 120,
        "critical" => 180
      },
      "handlers" => node.sensu.default_handlers,
      "refresh" => 60
  },
  "graphite" => {
    "name" => "#{node.fqdn.gsub('.', '-')}"
  },
  "disk" => {
    "wspace" => 80,
    "cspace" => 90,
    "winode" => 80,
    "cinode" => 90,
    "mount" => "/$,/mnt$,/data"
  },
  "ssh" => {
    "port" => 22
  }
}

### Installation
default.sensu.admin_user = "root"
default.sensu.user = "sensu"
default.sensu.group = "sensu"
default.sensu.directory = "/etc/sensu"
default.sensu.log_directory = "/var/log/sensu"

default.sensu.version = "0.16.0-1"
default.sensu.use_unstable_repo = false
default.sensu.log_level = "info"
default.sensu.use_ssl = true
default.sensu.use_embedded_ruby = true
default.sensu.init_style = "sysv"
default.sensu.service_max_wait = 10
default.sensu.directory_mode = "0750"
default.sensu.log_directory_mode = "0750"

default.sensu.apt_repo_url = "http://repos.sensuapp.org/apt"
default.sensu.yum_repo_url = "http://repos.sensuapp.org"
default.sensu.msi_repo_url = "http://repos.sensuapp.org/msi"

### Rabbitmq
default.sensu.rabbitmq.host = "192.168.1.143"
default.sensu.rabbitmq.port = 15671
default.sensu.rabbitmq.vhost = "/sensu"
default.sensu.rabbitmq.user = "sensu"
default.sensu.rabbitmq.password = "sensu"

### Data bag
#default.sensu.data_bag.name = "sensu"
#default.sensu.data_bag.ssl_item = "ssl"
