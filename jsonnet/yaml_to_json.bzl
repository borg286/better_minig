def yaml_to_json(name, src):
  native.genrule(
    name = name,
    srcs = [src],
    outs = [name + ".json"],
    tools = ["@gojsontoyaml//:gojsontoyaml"],
    cmd = "cat $< | $(location @gojsontoyaml//:gojsontoyaml) --yamltojson > $@",
  )

