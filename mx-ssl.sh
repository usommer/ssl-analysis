#!/bin/bash
## check expiry date for SSL certificates on Mailservers (OSX)
## Uwe Sommer
## uwe@usommer.de
## 01/2018

function mx_ssl()
{
## catch no parameter error
if [ "$#" -le "0" ]; then
    echo "domain-name required"
    return
fi
domain="$1"
## convert current date to seconds (Epoch time)
cur_date=$(date +%s)
## get mx server records from DNS
mx=$(dig mx "$domain" |awk '$4=="MX" {print $6}')
## get mx records and read hosts
printf "%s\n" "remaining days for SSL certificates on Mailservers" "" "Domain: $domain" "" "Servers:" "$mx" "" "" "Days remaining for certificates:" ""
## loop through all servers. This does not work on zsh shell because of worsplitting bug
## you need to set "setopt shwordsplit" in your .zshrc
for server in $mx
do
    ## get certificate end date from port connection via openssl
    date2=$(echo quit |openssl s_client -starttls smtp -connect "$server":25 2>/dev/null | openssl x509 -noout -enddate 2>null |cut -d"=" -f2)
    ## convert enddate to seconds. OSX uses special date conversion.
    if [[ $OSTYPE == darwin* ]]; then
    exp_date_smtp=$(LANG=C date -j -f "%b %d %T %Y %Z" "$date2" +"%s" 2>/dev/null)
    else
    exp_date_smtp=$(date -d "$date2" +"%s")
    fi
    ## calculate days remaining
    echo "scale=0; ($exp_date_smtp - $cur_date) / 86400" |bc -l 
done
}
