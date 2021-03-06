#
# Cookbook Name:: vxfld
# Recipe:: vxsnd
#
# Copyright 2015, Dreamhost LLC
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node['vxfld']['vxsnd']['packages'].each do |p|
  package p do
    action :upgrade
  end
end

package node['vxfld']['vxsnd']['packages'] do
  action :upgrade
end

# logs may not go here based on logdest configuration, but at least
# we'll have a directory in place to catch the default configuration
# and follow a relatively normal logging file structure
directory '/var/log/vxfld' do
  action :create
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/vxsnd.conf' do
  source 'vxsnd.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

file '/etc/default/vxsnd' do
  content 'START=yes'
end

service 'vxsnd' do
  supports :status => true, :restart => true
  action :enable
  subscribes :restart, resources(:template => '/etc/vxsnd.conf'), :delayed
  node['vxfld']['vxsnd']['packages'].each do |p|
    subscribes :restart, resources(:package => p), :delayed
  end
end
