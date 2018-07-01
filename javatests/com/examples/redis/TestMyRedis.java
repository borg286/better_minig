package com.examples.redis;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class TestMyRedis {
  @Test
  public void doTest() {
    String[] args = {"localhost", "6378"};
    MyRedis.main(args);
  }
}
