default[:rabbitmq][:dir][:ssl] = "/tmp/sensu/ssl"

default[:rabbitmq][:cert] = "/tmp/sensu/ssl/cert.pem"
default[:rabbitmq][:key] = "/tmp/sensu/ssl/key.pem"

default[:rabbitmq][:ip] = "192.168.1.144"
default[:rabbitmq][:port] = 5671
default[:rabbitmq][:vhost] = "/sensu"
default[:rabbitmq][:user] = "sensu"
default[:rabbitmq][:password] = "sensu"
