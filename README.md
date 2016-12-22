
# LetRedis Module ( Redis Sentinel )



	#   888 88e  888'Y88 888 88e   888  dP"8 
	#   888 888D 888 ,'Y 888 888b  888 C8b Y 
	#   888 88"  888C8   888 8888D 888  Y8b  
	#   888 b,   888 ",d 888 888P  888 b Y8D 
	#   888 88b, 888,d88 888 88"   888 8edP  



## Dependencies 


My personal tests with Redis Sentinel.

I am using arioch-redis Puppet Module. LetRedis module add the logic to change the redis master when the master faulti. How? So a Script was checking the service and if this script detects that the master faults, the script promotes a RedisSlave to be a Redis Master. 

Needs improvements and maybe we can use some service discovery like Consul or similars to improve the module. Althought the best solution is to use Redis Cluster. 


AWS Linux on AWS
AWS Infrastructure
Redis Module:

	  "name": "arioch-redis",
	  "version": "1.2.1",
	  "author": "Tom De Vylder",
	  "summary": "Redis module",
	  "license": "Apache-2.0",
	  "source": "https://github.com/arioch/puppet-redis",



#### HOW TO PREPARE THE REDIS CLUSTER 

	node /^proredis-sentinel-master\-i\-\w+/ inherits default {
	    class { 'letredis::initialserver':
		asgservername => "pro-redis-sentinel-master",
		asgslavesname => "pro-redis-sentinel-slave",
		elbservername => "pro-redismaster-sentinel",
		elbslavesname => "pro-redisslave-sentinel",
		clustername   => "clustersentinel",
	    }
	}


	node /^proredis-sentinel-slave\-i\-\w+/ inherits default {
	    class { 'letredis::initialslaves':
		asgservername => "pro-redis-sentinel-master",
		asgslavesname => "pro-redis-sentinel-slave",
		elbservername => "pro-redismaster-sentinel",
		elbslavesname => "pro-redisslave-sentinel",
		clustername   => "clustersentinel",
	    }
	}

