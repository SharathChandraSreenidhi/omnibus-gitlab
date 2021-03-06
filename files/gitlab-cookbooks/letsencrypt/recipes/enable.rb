site = URI(node['gitlab']['external-url'])

ruby_block 'http external-url' do
  block do
    LoggingHelper.warning("Let's Encrypt is enabled, but external_url is using http")
  end
  only_if { site.port == 80 }
end

# If we're using SSL, force http redirection to https
node.default['gitlab']['nginx']['redirect_http_to_https'] = true

include_recipe 'nginx::enable'

# We assume that the certificate and key will be stored in the same directory
ssl_dir = File.dirname(node['gitlab']['nginx']['ssl_certificate'])

directory ssl_dir do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# If this is the first run, then nginx won't be working due to missing certificates
acme_selfsigned site.host do
  crt node['gitlab']['nginx']['ssl_certificate']
  key node['gitlab']['nginx']['ssl_certificate_key']
  notifies :restart, 'service[nginx]', :immediately
end

include_recipe "letsencrypt::#{node['letsencrypt']['authorization_method']}_authorization"

ruby_block 'display_le_message' do
  block do
    LoggingHelper.warning("Let's Encrypt integration does not setup any automatic renewal. Please see https://docs.gitlab.com/omnibus/settings/ssl.html#lets-encrypt-integration for more information")
  end
  action :nothing
end

ruby_block 'save_auto_enabled' do
  block do
    LetsEncrypt.save_auto_enabled
  end
end
