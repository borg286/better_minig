package com.examples.gson;

public class LineItem {
  private final String name;
  private final int quantity;
  private final long priceInMicros;
  private final String currencyCode;

  public LineItem(String name, int quantity, long priceInMicros, String currencyCode) {
    this.name = name;
    this.quantity = quantity;
    this.priceInMicros = priceInMicros;
    this.currencyCode = currencyCode;
  }

  public String getName() {
    return name;
  }

  public int getQuantity() {
    return quantity;
  }

  public long getPriceInMicros() {
    return priceInMicros;
  }

  public String getCurrencyCode() {
    return currencyCode;
  }

  @Override
  public String toString() {
    return String.format("(item: %s, qty: %s, price: %.2f %s)",
        name, quantity, priceInMicros / 1000000d, currencyCode);
  }
}
