knife-inventory
===============

A Chef Knife Plugin to Inventory Your Environment and Output to CSV or HTML

## Installation

Copy these files to the plugin directory of your chef installation.

## Usage

```
knife inventory
knife inventory html
```

Results will print to STDOUT, use redirection to output to file or generate an email, for example...

```
knife inventory > chef-inventory_$(date +%Y-%m-%d).csv
knife inventory html > chef-inventory_$(date +%Y-%m-%d).html
```

or

```
knife inventory | mail -s "Chef Inventory for $(date +%Y-%m-%d)" user@example.com
knife inventory html | mail -s "Chef Inventory HTML for $(date +%Y-%m-%d)" user@example.com
```
