/*
 * Copyright 2015 The gRPC Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.grpc.examples.grpc_redis;

import io.grpc.examples.routeguide.*;
import com.google.protobuf.util.JsonFormat;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Iterator;
import java.io.Reader;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.List;
import java.util.Map;

import org.redisson.api.RGeo;
import org.redisson.api.GeoUnit;
import org.redisson.api.GeoPosition;
import org.redisson.api.RScoredSortedSet;
import org.redisson.api.RedissonClient;
import org.redisson.client.RedisConnection;

/**
 * Common utilities for the RouteGuide demo.
 */
public class RouteGuideUtil {
  private static final double COORD_FACTOR = 1e7;

  /**
   * Gets the latitude for the given point.
   */
  public static double getLatitude(Point location) {
    return location.getLatitude() / COORD_FACTOR;
  }

  /**
   * Gets the longitude for the given point.
   */
  public static double getLongitude(Point location) {
    return location.getLongitude() / COORD_FACTOR;
  }
  /**
   * Makes a point for the given longitude and latitude.
   */
  public static Point getPoint(double longitude, double latitude) {
    return Point.newBuilder()
        .setLongitude((int) Math.round(longitude * COORD_FACTOR))
        .setLatitude((int) Math.round(latitude * COORD_FACTOR))
        .build();
  }


  /**
   * Gets the default features file from classpath.
   */
  public static URL getDefaultFeaturesFile() {
    String filename = "/com/examples/grpc_redis/route_guide_db.json";
    URL r = RouteGuideUtil.class.getResource(filename);
    if (r == null) {
      throw new NullPointerException("No resource found at " + filename);
    }
    return r;
  }

  public static RGeo<String> loadRedisGeo(RedissonClient redisson) throws IOException {
    RGeo<String> geo = redisson.getGeo("features");
    URL file = getDefaultFeaturesFile();
    List<Feature> features = parseFeatures(file);
    for (Feature feature : features) {

      geo.add(
        getLatitude(feature.getLocation()),
        getLongitude(feature.getLocation()),
        feature.getName());
    }
    return geo;
  }
  static class FeatureIterator implements Iterator<Feature> {
    private final Iterator<String> delegate;
    private final RGeo geo;

    public FeatureIterator(RGeo geo) {
      this.geo = geo;
      this.delegate = geo.iterator();
    }

    @Override
    public Feature next() {
      String nextElement = delegate.next();
      if (nextElement == null) {
        return null;
      }
      // return to redis with the name of an element and ask for the position.
      // redisson returns a map of elements to positions. We only have 1 which should exit.
      Map<String, GeoPosition> positions = geo.radiusWithPosition(nextElement, 10, GeoUnit.METERS);
      GeoPosition position = positions.get(nextElement);
      Point location = getPoint(position.getLongitude(), position.getLatitude());
      return Feature.newBuilder().setName(nextElement).setLocation(location).build();
    }
    @Override
    public boolean hasNext() {
      return delegate.hasNext();
    }
  }

  public static Iterator<Feature> featureIterator(RedissonClient redisson) {
    return new FeatureIterator(redisson.getGeo("features"));
  } 


  /**
   * Parses the JSON input file containing the list of features.
   */
  public static List<Feature> parseFeatures(URL file) throws IOException {
    System.out.println("Parsing feature db from " + file);

    InputStream input = file.openStream();
    try {
      Reader reader = new InputStreamReader(input, Charset.forName("UTF-8"));
      try {
        FeatureDatabase.Builder database = FeatureDatabase.newBuilder();
        JsonFormat.parser().merge(reader, database);
        return database.getFeatureList();
      } finally {
        reader.close();
      }
    } finally {
      input.close();
    }
  }

  /**
   * Indicates whether the given feature exists (i.e. has a valid name).
   */
  public static boolean validate(Feature feature) {
    return feature != null && !feature.getName().isEmpty();
  }
}
