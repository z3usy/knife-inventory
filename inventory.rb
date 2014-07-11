require 'chef/knife'
require 'highline'

module Limelight
  class Inventory < Chef::Knife

    deps do
      require 'chef/search/query'
      require 'chef/knife/search'
      require 'chef/node'
      require 'chef/json_compat'
      require 'chef/knife/node_list'
    end

    banner "knife inventory"

    def h
      @highline ||= Highline.new
    end

    def run

      print "FQDN;Chef;Environment;Roles;Run List;Platform;Version;Kernel;CPUs;Memory;Swap;IP;MAC;Gateway;Filesystem\n"

      nodes = Hash.new
      Chef::Search::Query.new.search(:node, "name:*.*") do |n|
        node = n unless n.nil?

        fqdn = node['fqdn'] || 'empty'
        environment = node.chef_environment || 'empty'
        roles = node['roles'] || 'empty'
        run_list = node.run_list || 'empty'
        platform = node['platform'] || 'empty'
        platform_ver = node['platform_version'] || 'empty'
        kernel = node.fetch('kernel', {})['release'] || 'empty'
        cpu_num = node['cpu']['total'] || 'empty'
        ram = node.fetch('memory', {})['total'] || 'empty'
        swap = node.fetch('memory', {}).fetch('swap', {})['total'] || 'empty'
        ip = node['ipaddress'] || 'empty'
        macaddress = node['macaddress'] || 'empty'
        df_gateway = node.fetch('network', {})['default_gateway'] || 'empty'
        chef_version = node.fetch('chef_packages', {}).fetch('chef', {})['version'] || 'empty'

        all_fs = node.fetch('filesystem', {})

        filtered_fs = all_fs.select do |volume, properties|
          %w[xfs ext3 ext4].include?(properties['fs_type'])
        end

        fs_fields = %w[mount fs_type kb_size percent_used]
        filtered_fs.each do |volume, properties|
          filtered_fs[volume] = Hash[properties.select do |key, value|
            fs_fields.include?(key)
          end.sort_by { |key, value| fs_fields.index(key) }]
        end

        print "#{fqdn};#{chef_version};#{environment};#{roles};#{run_list};#{platform};#{platform_ver};#{kernel};#{cpu_num};#{ram};#{swap};#{ip};#{macaddress};#{df_gateway};#{filtered_fs}\n"

      end
    end
  end
end
