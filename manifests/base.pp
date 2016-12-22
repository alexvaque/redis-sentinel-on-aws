class letredis::base (
  $asgservername = $letredis::initialserver::asgservername, 
  $asgslavesname = $letredis::initialslaves::asgslavesname,
  $elbservername = $letredis::initialserver::elbservername, 
  $elbslavesname = $letredis::initialslaves::elbslavesname,
){ 

  if ( $elbservername == undef ) {

    file { '/etc/facter/facts.d/ec2_tag_redismaster.sh':
      ensure  => present,
      mode   => 744,
      owner  => puppet,
      group  => puppet,
      content => template('letredis/facter/facts.d/ec2_tag_redismaster.sh.erb'),
    }

  } else {

    file { '/root/rediselbregister.sh':
      ensure  => present,
      mode   => 744,
      owner  => root,
      group  => root,
      content => template('letredis/rediselbregister.sh.erb'),
    }

    file { '/etc/facter/facts.d/ec2_tag_redismaster.sh':
      ensure  => present,
      mode   => 744,
      owner  => puppet,
      group  => puppet,
      content => template('letredis/facter/facts.d/ec2_tag_redismaster.sh.erb'),
    }

    cron { "redis_check_elb":
      ensure  => absent,
      command => "/root/rediselbregister.sh",
      user    => 'root',
      minute  => '*/2',
    }
  }

}

