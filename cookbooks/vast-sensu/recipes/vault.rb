# Install and include new chef-vault gem
# Note: If you want to use encrypted data bags (vault) you have to 
#       edit chef-repo/cookbooks/sensu/libraries/sensu_helpers.rb and replace these two lines 
#       - chef_vault_item("sensu", item)
#       + ChefVault::Item.load("sensu", item)
chef_gem "chef-vault"
require "chef-vault"
