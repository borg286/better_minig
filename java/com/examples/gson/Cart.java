package com.examples.gson;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.lang.reflect.WildcardType;
import java.util.List;

import com.google.gson.annotations.SerializedName;

public class Cart {
  public final List<LineItem> lineItems;

  @SerializedName("buyer")
  private final String buyerName;

  private final String creditCard;

  public Cart(List<LineItem> lineItems, String buyerName, String creditCard) {
    this.lineItems = lineItems;
    this.buyerName = buyerName;
    this.creditCard = creditCard;
  }

  public List<LineItem> getLineItems() {
    return lineItems;
  }

  public String getBuyerName() {
    return buyerName;
  }

  public String getCreditCard() {
    return creditCard;
  }


  /**
   * This is not necessary for gson operaitons. It is only to show the user the innards of a Cart
   * object and gain comfort that the gson is extracting all the information, and regenerating it
   * when decoded.
   */
  @Override
  public String toString() {
    StringBuilder itemsText = new StringBuilder();
    boolean first = true;
    if (lineItems != null) {
      try {
        Class<?> fieldType = Cart.class.getField("lineItems").getType();
        System.out.println("LineItems CLASS: " + getSimpleTypeName(fieldType));
      } catch (SecurityException e) {
      } catch (NoSuchFieldException e) {
      }
      for (LineItem item : lineItems) {
        if (first) {
          first = false;
        } else {
          itemsText.append("; ");
        }
        itemsText.append(item);
      }
    }
    return "[BUYER: " + buyerName + "; CC: " + creditCard + "; "
    + "LINE_ITEMS: " + itemsText.toString() + "]";
  }

  @SuppressWarnings("unchecked")
  public static String getSimpleTypeName(Type type) {
    if (type == null) {
      return "null";
    }
    if (type instanceof Class) {
      return ((Class)type).getSimpleName();
    } else if (type instanceof ParameterizedType) {
      ParameterizedType pType = (ParameterizedType) type;
      StringBuilder sb = new StringBuilder(getSimpleTypeName(pType.getRawType()));
      sb.append('<');
      boolean first = true;
      for (Type argumentType : pType.getActualTypeArguments()) {
        if (first) {
          first = false;
        } else {
          sb.append(',');
        }
        sb.append(getSimpleTypeName(argumentType));
      }
      sb.append('>');
      return sb.toString();
    } else if (type instanceof WildcardType) {
      return "?";
    }
    return type.toString();
  }

}
