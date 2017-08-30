The purpose of this script is to make sshing easier.

You will probably only find this useful as a sysadmin, release engineer, or other DevOps professional. Or just someone who must frequently ssh into many instances.

It will try to append a configured list of prefixes, as well as postpend a configured list of suffixes, to the hostname you entered if it cannot find the host.

Furthermore, it will use ssh-copy-id to save your public ssh key to the remote instance so that you may ssh without authentication in the future provided you authenticate successfully the first time.

Installation:
`cp s.sh /usr/local/bin`

Configuration:
Edit PREFIXES=() to contain your list of prefixes, double quoted, comma separated.
Edit SUFFIXES=() to contain your list of suffixes, double quoted, comma separated.

I found this useful as a developer at Constant Contact, since I often had to ssh into our privately hosted cloud instances for a variety of purposes, and many of the hostnames followed a particular pattern which I didn't want to have to type every time out of laziness.

