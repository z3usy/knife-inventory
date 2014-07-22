knife-inventory
===============

A Chef Knife Plugin to Inventory Your Environment and Output to CSV or HTML

 ** Note: The output is technically an SSV (semi-colon seperated values) as the Roles, Run List, and Filesystem are comma seperated hashes within a single column so we've used a semi-colon as a column delimiter. The bash below will convert everything to a true CSV. (this will be fixed up in future versions)

## Installation

Copy the inventory.rb file to the plugin directory of your chef installation.

## Usage

```
knife inventory -c
knife inventory -h
```

Results will print to STDOUT, use redirection to output to file, for example...

```
knife inventory -c | sed 's/,//g' | sed 's/;/,/g' > chef-inventory_$(date +%Y-%m-%d).csv
knife inventory -h > chef-inventory_$(date +%Y-%m-%d).html
```
