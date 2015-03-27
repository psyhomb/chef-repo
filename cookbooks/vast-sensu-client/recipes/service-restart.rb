### Trigger sensu-server restart
include_recipe "vast-sensu-client::service-trigger"

### Restart sensu-server (works with two service managers sysv and supervisord)
directory '/var/chef/run' do
  owner 'root'
  group 'root'
end

pid = `ps aux | grep [s]upervisord.conf | awk '{print $2}'`.to_i

if pid != 0
  bash 'sensu-server-restart' do
    user 'root'
    code <<-EOH
      # Modification time marker
      MMARKER="/var/chef/run/supervisor_status.mmarker"

      if [[ -e ${MMARKER} ]]; then
        MODIFIED=`find /etc/sensu/conf.d/checks -newer ${MMARKER}`
        if [[ -n ${MODIFIED} ]]; then
          supervisorctl restart sensu-server
          touch ${MMARKER}
        fi
      else
        supervisorctl restart sensu-server
        touch ${MMARKER}
      fi
      EOH
  end
else
  include_recipe 'sensu::server_service'
end