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

      print "FQDN;Chef;Environment;Virtualization;VM Type;Roles;Run List;Platform;Version;Kernel;CPUs;Memory;Swap;IP;MAC;Gateway;Filesystem\n"

      nodes = Hash.new
      Chef::Search::Query.new.search(:node, "name:*.*") do |n|
        node = n unless n.nil?

        fqdn = node['fqdn'] || 'n/a'
        environment = node.chef_environment || 'n/a'
        virtualization = node.fetch('virtualization', {})['role'] || 'n/a'
        virt_type = node.fetch('virtualization', {})['system'] || 'n/a'
        roles = node['roles'] || 'n/a'
        run_list = node.run_list || 'n/a'
        platform = node['platform'] || 'n/a'
        platform_ver = node['platform_version'] || 'n/a'
        kernel = node.fetch('kernel', {})['release'] || 'n/a'
        cpu_num = node['cpu']['total'] || 'n/a'
        ram = node.fetch('memory', {})['total'] || 'n/a'
        swap = node.fetch('memory', {}).fetch('swap', {})['total'] || 'n/a'
        ip = node['ipaddress'] || 'n/a'
        macaddress = node['macaddress'] || 'n/a'
        df_gateway = node.fetch('network', {})['default_gateway'] || 'n/a'
        chef_version = node.fetch('chef_packages', {}).fetch('chef', {})['version'] || 'n/a'

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

        print "#{fqdn};#{chef_version};#{environment};#{virtualization};#{virt_type};#{roles};#{run_list};#{platform};#{platform_ver};#{kernel};#{cpu_num};#{ram};#{swap};#{ip};#{macaddress};#{df_gateway};#{filtered_fs}\n"

      end
    end
  end
end
