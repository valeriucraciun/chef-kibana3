Chef::Log.info('------------------------ kibana3::default -----------------------')

include_recipe "git"
include_recipe "logrotate"

kibana_base = node['logstash']['kibana']['basedir']
kibana_version = node['logstash']['kibana']['sha']


kibana_log_dir = node['logstash']['kibana']['log_dir']
kibana_pid_dir = node['logstash']['kibana']['pid_dir']


if Chef::Config[:solo]
  es_server_ip = node['logstash']['elasticsearch_ip']
else
  es_server_results = search(:node, "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}")
  unless es_server_results.empty?
    es_server_ip = es_server_results[0]['ipaddress']
  else
    es_server_ip = node['logstash']['elasticsearch_ip'].empty? ? '127.0.0.1' : node['logstash']['elasticsearch_ip']
  end
end

Chef::Log.info('------------------------ es_server_ip: ${es_server_ip} -----------------------')

es_server_port = node['logstash']['elasticsearch_port'].empty? ? '9200' : node['logstash']['elasticsearch_port']

Chef::Log.info('------------------------ es_server_port: ${es_server_port} -----------------------')

include_recipe "apache2"

apache_site "default" do
  enable node['apache']['default_site_enabled']
end

directory "#{kibana_base}/#{kibana_version}" do
  owner node['logstash']['user']
  group node['logstash']['group']
  recursive true
end

git "#{kibana_base}/#{kibana_version}" do
  repository node['logstash']['kibana']['repo']
  reference kibana_version
  action :sync
  user node['logstash']['user']
  group node['logstash']['group']
end

link "#{kibana_base}/current" do
  to "#{kibana_base}/#{kibana_version}"
  notifies :restart, "service[apache2]"
end

template "#{node['apache']['dir']}/sites-available/kibana" do
  source node['logstash']['kibana']['apache_template']
  variables(:docroot => "#{kibana_base}/current",
            :server_name => node['logstash']['kibana']['server_name'])
end

apache_site "kibana"

template "#{kibana_base}/current/config.js" do
  source node['logstash']['kibana']['conf']['file_name']
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0755"
  variables(:es_server_ip => es_server_ip,
            :kibana_index => node['logstash']['kibana']['conf']['specific_index'])
end

if node['logstash']['kibana']['auth']['enabled']
  htpasswd_path     = "#{kibana_base}/#{kibana_version}/htpasswd"
  htpasswd_user     = node['logstash']['kibana']['auth']['user']
  htpasswd_password = node['logstash']['kibana']['auth']['password']

  file htpasswd_path do
    owner node['logstash']['user']
    group node['logstash']['group']
    mode "0755"
  end

  execute "add htpasswd file" do
    command "/usr/bin/htpasswd -b #{htpasswd_path} #{htpasswd_user} #{htpasswd_password}"
  end
end

service "apache2"