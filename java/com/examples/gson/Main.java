package com.examples.gson;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;
import java.lang.StringBuilder;

public class Main {
  public static void main(String[] args) {
    Gson gson = new Gson();
    Cart cart = buildCart();
    StringBuilder sb = new StringBuilder();
    sb.append("Gson.toJson() example: \n");
    sb.append("  Cart Object: ").append(cart).append("\n");
    sb.append("  Cart JSON: ").append(gson.toJson(cart)).append("\n");
    sb.append("\n\nGson.fromJson() example: \n");
    String json = "{buyer:'Happy Camper',creditCard:'4111-1111-1111-1111',"
      + "lineItems:[{name:'nails',priceInMicros:100000,quantity:100,currencyCode:'USD'}]}";
    sb.append("Cart JSON: ").append(json).append("\n");
    sb.append("Cart Object: ").append(gson.fromJson(json, Cart.class)).append("\n");
    System.out.println(sb.toString());
  }

  private static Cart buildCart() {
    List<LineItem> lineItems = new ArrayList<LineItem>();
    lineItems.add(new LineItem("hammer", 1, 12000000, "USD"));
    return new Cart(lineItems, "Happy Buyer", "4111-1111-1111-1111");
  }
}
