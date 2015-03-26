##################
## Sensu Client ##
##################

### Plugins and client definition
default.monitor.use_nagios_plugins = true
default.monitor.rhel.nagios_plugin_packages = ["nagios-plugins-all"]
default.monitor.debian.nagios_plugin_packages = ["nagios-plugins-basic"]

default.monitor.use_system_profile = true
default.monitor.use_statsd_input = false

default.monitor.default_handlers = ["flapjack"]
default.monitor.metric_handlers = ["debug"]

### Client definition (additional attributes)
default.monitor.use_local_ipv4 = false
default.monitor.additional_client_attributes = {
    "disk" => {
            "wspace" => 80,
            "cspace" => 90,
            "winode" => 80,
            "cinode" => 90,
            "mount" => "/$,/mnt$,/data"
        }
}

### Platform Linux
default.sensu.admin_user = "root"
default.sensu.user = "sensu"
default.sensu.group = "sensu"
default.sensu.directory = "/etc/sensu"
default.sensu.log_directory = "/var/log/sensu"

### Installation
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
default.sensu.data_bag.name = "sensu"
default.sensu.data_bag.ssl_item = "ssl"
default.sensu.data_bag.config_item = "config"
default.sensu.data_bag.enterprise_item = "enterprise"
