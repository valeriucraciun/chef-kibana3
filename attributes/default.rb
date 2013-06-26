# Apache overwrites
default['apache']['default_site_enabled'] = false

# Kibana 3
default['logstash']['kibana']['repo'] = 'git://github.com/elasticsearch/kibana.git'
default['logstash']['kibana']['sha'] = '0803ed1baa74d63fd9d24440cb7029a5a238b39d'
default['logstash']['kibana']['basedir'] = "#{node['logstash']['basedir']}/kibana"
default['logstash']['kibana']['apache_template'] = 'kibana.conf.erb'
default['logstash']['kibana']['server_name'] = node['ipaddress']
default['logstash']['kibana']['server_hostname'] = node['ipaddress']
default['logstash']['kibana']['http_port'] = 80

default['logstash']['kibana']['auth']['enabled'] = true
default['logstash']['kibana']['auth']['user'] = 'admin'
default['logstash']['kibana']['auth']['password'] = 'admin'

default['logstash']['kibana']['conf']['file_name'] = 'kibana-config.js.erb'
default['logstash']['kibana']['conf']['specific_index'] = 'kibana-int'
#default['logstash']['kibana']['conf']['modules'] = ['histogram','map','pie','table','stringquery','sort',
#                    'timepicker','text','fields','hits','dashcontrol','column','derivequeries','trends']