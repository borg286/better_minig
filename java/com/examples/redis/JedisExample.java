package com.examples.redis;

import redis.clients.jedis.JedisCluster;
import redis.clients.jedis.HostAndPort;
import java.util.Set;
import java.util.HashSet;

public class JedisExample {
	public static void main(String[] args){
		System.out.println(args[0]);
		Set<HostAndPort> jedisClusterNodes = new HashSet<HostAndPort>();
		//Jedis Cluster will attempt to discover cluster nodes automatically
		jedisClusterNodes.add(new HostAndPort(args[0], 6379));
		JedisCluster jc = new JedisCluster(jedisClusterNodes);
		jc.set("foo", "bar");
		String value = jc.get("foo");
		System.out.println(value);
	}

}