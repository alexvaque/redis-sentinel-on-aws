class letredis::initialslaves (
  $asgservername = "stg-redismaster",
  $asgslavesname = "stg-redis",
  $elbservername = undef,
  $elbslavesname = undef,
  $clustername   = "mycluster",
){

  class { 'letredis::base':
    asgservername => $asgservername ,
    asgslavesname => $asgslavesname ,
    elbservername => $elbservername ,
    elbslavesname => $elbslavesname ,
  }

  class { 'redis':
    bind     => $ipaddress,
    slaveof  => "${ec2_tag_redismaster} 6379",
    require  =>  File['/etc/facter/facts.d/ec2_tag_redismaster.sh'] ,
  }

  class { 'redis::sentinel':
    master_name => $clustername,
    redis_host  => "${ec2_tag_redismaster}",    
    require  =>  File['/etc/facter/facts.d/ec2_tag_redismaster.sh'] ,
  }

  class { 'monitoring_client::redismaster':
    redis_host            =>  $ipaddress,
    redis_memory_warning  => '59500000',
    redis_memory_critical => '65000000',
  }

}

