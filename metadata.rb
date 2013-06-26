name			 "kibana3"
maintainer       "Valeriu Craciun"
maintainer_email "craciun_val@yahoo.com"
license          "All rights reserved"
description      "Installs/Configures kibana3"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%w{ apache2 git java logrotate}.each do |ckbk|
  depends ckbk
end