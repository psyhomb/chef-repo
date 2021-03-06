###########
## Sensu ##
###########

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
default.sensu.rabbitmq.host = "localhost"
default.sensu.rabbitmq.port = 5671
default.sensu.rabbitmq.vhost = "/sensu"
default.sensu.rabbitmq.user = "sensu"
default.sensu.rabbitmq.password = "sensu"

### Redis
#default.sensu.redis.host = "localhost"
#default.sensu.redis.port = 6379
default.sensu.redis.host = "192.168.1.143"
default.sensu.redis.port = 16379

### API
default.sensu.api.host = "localhost"
default.sensu.api.bind = "0.0.0.0"
default.sensu.api.port = 4567

### Flapjack
default.sensu.handlers.directory = "#{node.sensu.directory}/extensions/handlers"
default.sensu.flapjack.host = "sensu-server1.buncici.com"
default.sensu.flapjack.port = 6380
default.sensu.flapjack.db = 0

### Data bag
default.sensu.data_bag.name = "sensu"
default.sensu.data_bag.ssl_item = "ssl"
default.sensu.data_bag.config_item = "config"
default.sensu.data_bag.enterprise_item = "enterprise"



############
## Uchiwa ##
############

# Uchiwa Settings
default['uchiwa']['settings']['user'] = ''
default['uchiwa']['settings']['pass'] = ''
default['uchiwa']['settings']['refresh'] = 5
default['uchiwa']['settings']['host'] = '0.0.0.0'
default['uchiwa']['settings']['port'] = 3000

# APIs Settings
default['uchiwa']['api'] = [
  {
    'name' => 'Sensu',
    'host' => '127.0.0.1',
    'port' => 4567,
    'path' => '',
    'ssl' => false,
    'timeout' => 5
  }
]



##############
## RabbitMQ ##
##############

### System 'initd' | 'upstart'
#if platform_family? "rhel"
#  default.rabbitmq.job_control = 'initd'
#elsif platform_family? "debian"
#  default.rabbitmq.job_control = 'upstart'
#end

### Use local config file (local template)
default.rabbitmq.config_template_cookbook = 'vast-sensu'

### Give user a role (default.sensu.rabbitmq.user)
default.rabbitmq.tag = "administrator"

### Clustering
default.rabbitmq.cluster = true
default.rabbitmq.erlang_cookie = 'SWBKXWNOPYMBCSIUUDYW'
default.rabbitmq.cluster_disk_nodes = nil
default.rabbitmq.cluster_partition_handling = nil

# Node type : master | slave
default['rabbitmq-cluster']['node_type'] = 'slave'

# Master node name : rabbit@rabbit1
default['rabbitmq-cluster']['master_node_name'] = 'rabbit@sensu-server1'

# Cluster node type : disc | ram
default['rabbitmq-cluster']['cluster_node_type'] = 'disc'

### Resources management 
default.rabbitmq.vm_memory_high_watermark = 0.4
default.rabbitmq.vm_memory_high_watermark_paging_ration = 0.2
default.rabbitmq.disk_free_limit_relative = 2.0
default.rabbitmq.max_file_descriptors = 1024
