package com.examples.redis;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.Map.Entry;
import java.util.Set;

import org.redisson.Redisson;
import org.redisson.api.RMap;
import org.redisson.api.RGeo;
import org.redisson.api.GeoUnit;
import org.redisson.api.GeoPosition;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;
import org.redisson.client.RedisConnection;
import org.redisson.client.RedisClient;
import org.redisson.client.protocol.RedisCommand;
import org.redisson.client.codec.StringCodec;
import org.redisson.client.protocol.RedisCommands;
import org.redisson.client.RedisClientConfig;
import org.redisson.client.protocol.decoder.GeoPositionDecoder;
import org.redisson.client.protocol.decoder.ObjectListReplayDecoder;
import java.util.Arrays;
import org.redisson.client.protocol.decoder.MultiDecoder;
import org.redisson.client.protocol.decoder.GeoPositionMapDecoder;


public class RedissonExample {
    public static void main( String[] args ) {
        Config config = new Config();
        config.useSingleServer().setAddress("redis://" + args[0] + ":" + args[1]);
        RedissonClient redisson = Redisson.create(config);
        RedisClientConfig rawConfig = new RedisClientConfig();
        rawConfig.setAddress("redis://" + args[0] + ":" + args[1]);
        RedisClient rawClient = RedisClient.create(rawConfig);
        RedisConnection conn = rawClient.connect();

        RMap<String, Integer> map =  redisson.getMap("myMap");
        map.put("brian", 3);

        boolean contains = map.containsKey("brian");
        System.out.println("Map works: " + contains);

        RGeo<String> geo = redisson.getGeo("features");
        geo.add(0,0,"hi");
        System.out.println(geo.radiusWithPosition("hi", 10, GeoUnit.METERS));
/*
        List<Object> members = new ArrayList<Object>();
        members.add("hi");

        MultiDecoder<Map<Object, Object>> decoder = new ListMultiDecoder(
            new GeoPositionDecoder(),
            new ObjectListReplayDecoder(ListMultiDecoder.RESET),
            new GeoPositionMapDecoder(members));
        RedisCommand<Map<Object, Object>> command = new RedisCommand<Map<Object, Object>>("GEOPOS", decoder);

        Object o = conn.sync(StringCodec.INSTANCE, command, "features", "hi", 0, 0, "m", "WITHCOORD");
        System.out.println(o);*/

        redisson.shutdown();
        conn.closeAsync();
        rawClient.shutdown();
    }
}
