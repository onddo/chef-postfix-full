#
# Cookbook Name:: postfix-full
# Recipe:: default
#
# Copyright 2013, Malte Swart
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'postfix'

service 'postfix' do
  supports :status => true, :restart => true, :reload => true
  action :enable
end

file ::File.join(node['postfix']['base_dir'], 'main.cf') do
  content node.generate_postfix_main_cf
  user 'root'
  group 0
  mode 00644
  notifies :reload, "service[postfix]"
end

file ::File.join(node['postfix']['base_dir'], 'master.cf') do
  content node.generate_postfix_master_cf
  user 'root'
  group 0
  mode 00644
  notifies :restart, "service[postfix]"
end


directory ::File.join(node['postfix']['base_dir'], 'tables') do
  owner "root"
  group "root"
  mode 00755
  action :create
end

node.get_postfix_tables.each do |table|
  table.generate_resources self
end

service 'postfix' do
  action :start
end