package com.examples.redis;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.redisson.Redisson;
import org.redisson.api.RMap;
import org.redisson.api.RGeo;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;


public class MyRedis {
    public static void main( String[] args ) {
        Config config = new Config();
        config.useSingleServer().setAddress("redis://" + args[0] + ":" + args[1]);
        RedissonClient redisson = Redisson.create(config);

        RMap<String, Integer> map =  redisson.getMap("myMap");
        map.put("brian", 3);

        boolean contains = map.containsKey("brian");
        System.out.println("Map works: " + contains);

        RGeo geo = redisson.getGeo("features");
        geo.add(0,0,"hi");
        geo.pos("hi");


        redisson.shutdown();
    }
}
