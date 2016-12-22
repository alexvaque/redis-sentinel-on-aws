#!/usr/bin/python

import os.path 
import sys
import boto.ec2

if len(sys.argv) < 2: 
    raise SystemExit

busqueda=sys.argv[1]
environment=""
if len(sys.argv)>2:
    environment=sys.argv[2]

conn = boto.ec2.connect_to_region('us-east-1')

#get the instances 
instances = [x for y in conn.get_all_instances() for x in y.instances]

#get the result
pre_res = [x for x in instances if busqueda in x.id or busqueda in x.tags.get('Name','') or busqueda in x.tags.get('app','')]

#check the environment
if environment:
    res = [x for x in pre_res if x.tags.get('Environment') == environment]
else:
    res = pre_res

if res and len(res):
    for instance in res:
        ipstring = str(instance.private_ip_address)
        if ipstring not in "None":
                print instance.private_ip_address 
else:
    print "noip"

