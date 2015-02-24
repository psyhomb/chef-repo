include_recipe 'sensu::rabbitmq'

# Set user tag
rabbitmq_user "#{node.sensu.rabbitmq.user}" do
  tag "#{node.rabbitmq.tag}"
  action :set_tags
end

# Delete guest user
rabbitmq_user 'guest' do
  action :delete
end
