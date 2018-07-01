package com.example.guava;

import com.google.common.math.IntMath;

public class Library {
    public static String Hello = "Hello";

    public static String AppendWorld(String word) {
        return word + " World!";
    }
    public static String Add() {
        return IntMath.checkedAdd(1,2) + "";
    }
}
