# platform linux
default.sensu.admin_user = "root"
default.sensu.user = "sensu"
default.sensu.group = "sensu"
default.sensu.directory = "/etc/sensu"
default.sensu.log_directory = "/var/log/sensu"

# installation
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

# rabbitmq
default.sensu.rabbitmq.host = "sensu-server1.buncici.com"
default.sensu.rabbitmq.port = 5671
default.sensu.rabbitmq.vhost = "/sensu"
default.sensu.rabbitmq.user = "sensu"
default.sensu.rabbitmq.password = "sensu"

# redis
default.sensu.redis.host = "sensu-server1.buncici.com"
default.sensu.redis.port = 6379

# api
default.sensu.api.host = "localhost"
default.sensu.api.bind = "0.0.0.0"
default.sensu.api.port = 4567

# Vast flapjack
default.sensu.handlers.directory = "#{node.sensu.directory}/extensions/handlers"
default.sensu.flapjack.host = "sensu-server1.buncici.com"
default.sensu.flapjack.port = 6380
default.sensu.flapjack.db = 0
