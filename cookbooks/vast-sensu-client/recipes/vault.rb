# Install and include new chef-vault gem
# Note: If you want to use encrypted data bags (vault) without chef-vault cookbook then you have to 
#       edit chef-repo/cookbooks/sensu/libraries/sensu_helpers.rb and replace the line 
#       - chef_vault_item(data_bag_name, item)
#       + ChefVault::Item.load(data_bag_name, item)
chef_gem "chef-vault"
require "chef-vault"
