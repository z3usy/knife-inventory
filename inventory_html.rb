require 'chef/knife'
require 'highline'

module Limelight
  class InventoryHtml < Chef::Knife

    deps do
      require 'chef/search/query'
      require 'chef/knife/search'
      require 'chef/node'
      require 'chef/json_compat'
      require 'chef/knife/node_list'
    end

    banner "knife inventory html"

    def h
      @highline ||= Highline.new
    end

    def run

pageHeader = "<html>\n<head>\n<MEAT HTTP-EQUIV=PRAGMA CONTENT=NO-CACHE>
<style type='text/css'>\n
.heading {
color:#3366FF;
font-size:12.0pt;
font-weight:700;
font-family:sans-serif;
text-align:left;
vertical-align:middle;
height:20.0pt;
padding:0px 7px 0px 7px;
}
.bodytext {
color:#000000;
font-size:10.0pt;
font-weight:400;
font-family:Arial;
text-align:left;
vertical-align:middle;
height:30.0pt;
width:416pt;
}
.colnames {
color:#000000;
font-size:10.0pt;
font-family:sans-serif;
text-align:left;
vertical-align:top;
border:.5pt solid;
background:#EEEEEE;
padding:1px 2px 1px 2px;
}
.text {
font-size:10.0pt;font-family:Arial;
text-align:left;vertical-align:middle;
border:.5pt solid;background:#000000;
}</style>
<title>Chef Inventory</title>
</head>\n<body>\n"

      nodes = Hash.new
      content = ""

      ubuntuNodes = 0
      centosNodes = 0
      redhatNodes = 0
      unknownOS = 0

      totalNodes = 0

      Chef::Search::Query.new.search(:node, "name:*") do |n|
      node = n unless n.nil?
      totalNodes += 1

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

    if platform == "ubuntu"
          ubuntuNodes += 1
    elsif platform == "centos"
          centosNodes += 1
    elsif platform == "redhat"
          redhatNodes += 1
    else
          unknownOS += 1
    end

    content += "  <tr>
  <td class=colnames>#{fqdn}</td><td class=colnames>#{chef_version}</td><td class=colnames>#{environment}</td><td class=colnames>#{roles}</td><td class=colnames>#{run_list}</td><td class=colnames>#{platform}</td><td class=colnames>#{platform_ver}</td><td class=colnames>#{kernel}</td><td class=colnames>#{cpu_num}</td><td class=colnames>#{ram}</td><td class=colnames>#{swap}</td><td class=colnames>#{ip}</td><td class=colnames>#{macaddress}</td><td class=colnames>#{df_gateway}</td><td class=colnames>#{filtered_fs}</td>
</tr>\n"
      end
    countsTop = "<table border=0 cellpadding=0 cellspacing=0 style=\'border-collapse:collapse;\'>
  <tr><td>
    <table border=0 cellpadding=3 cellspacing=10 width=100% style=\'border-collapse:collapse;\'>
    </table>
  </td>&nbsp;&nbsp;&nbsp;&nbsp;<td>
    <table border=0 cellpadding=3 cellspacing=10 width=100% style=\'border-collapse:collapse;\'>
      <tr><td class=colnames>Total Servers</td><td class=colnames>#{totalNodes}</td></tr>
      <tr><td class=colname>OS</td><td class=colname>Count</td></tr>
      <tr><td class=colnames>Ubuntu</td><td class=colnames>#{ubuntuNodes}</td></tr>
      <tr><td class=colnames>CentOS</td><td class=colnames>#{centosNodes}</td></tr>
      <tr><td class=colnames>RedHat</td><td class=colnames>#{redhatNodes}</td></tr>
      <tr><td class=colnames>Unknown</td><td class=colnames>#{unknownOS}</td></tr>
    </table>
  </td></tr>
</table>"

    contentTop = "<table border=0 cellpadding=0 cellspacing=0 width=100% style=\'border-collapse:collapse;\'>
<tr><th class=heading>FQDN</th><th class=heading>Chef</th><th class=heading>Env.</th><th class=heading>Roles</th><th class=heading>Run List</th><th class=heading>Platform</th><th class=heading>Version</th><th class=heading>Kernel</th><th class=heading>CPUs</th><th class=heading>Memory</th><th class=heading>Swap</th><th class=heading>IP</th><th class=heading>MAC</th><th class=heading>Gateway</th><th class=heading>Filesystem</th></tr>"
    footer = "</table>\n</body>\n</html>\n"

    print "#{pageHeader}\n#{countsTop}\n#{contentTop}\n#{content}\n#{footer}"
    end
  end
end
