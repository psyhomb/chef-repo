### Triggers sensu-server restart (sysv)
include_recipe "vast-sensu-client::service-trigger"

### Restart sensu-server (works with two service managers sysv and supervisord)
directory '/var/chef/run' do
  owner 'root'
  group 'root'
end

pid = `ps aux | grep -w [/]usr/bin/supervisord | awk '{print $2}'`.to_i

if pid != 0
  bash 'sensu-server-restart' do
    user 'root'
    cwd '/var/chef/run'
    code <<-EOH
      supervisorctl restart sensu-server sensu-api
      touch sensu-checks.mmarker
    EOH
    only_if '[[ ! -e sensu-checks.mmarker ]] || [[ -n `find /etc/sensu/conf.d/checks -newer sensu-checks.mmarker` ]]'
  end
else
  include_recipe 'sensu::server_service'
end
