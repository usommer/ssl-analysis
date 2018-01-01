#!/bin/bash
## check expiry date for SSL certificates on Mailservers (OSX)
## Uwe Sommer
## uwe@usommer.de
## 01/2018

## todo: 
## more error checks
## display complete TLS analysis

if [ "$#" -le "0" ]; then
	echo "domain-name required"
		else
			domain="$1"
			cur_date=$(date +%s)														## convert current date to seconds (Epoch time)
			mx=$(dig +short mx "$domain" | awk '{print $2}') 							## get mx records and read hosts
			echo "remaining days for SSL certificates on Mailservers"
			echo ""
			echo "Domain: $domain"
			echo ""
			printf "Servers: \n$mx"
			echo ""
			echo ""
			echo "Days remaining for certificates:"
			echo ""
			for server in $mx
				do
					date2=$(echo quit |openssl s_client -starttls smtp -connect "$server":25 2>/dev/null | openssl x509 -noout -dates | grep notAfter |cut -d"=" -f2) 			## get SSL expiry date from TLS connection
					exp_date_smtp=$(date -j -f "%b %d %T %Y %Z" "$date2" +"%s") 		## convert expiry date timestamp to seconds
					echo "scale=0; ($exp_date_smtp - $cur_date) / 86400" |bc -l			## calculate expiry time and convert result to days
			done
fi
