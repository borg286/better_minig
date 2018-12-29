local environment_names = import "prod/environment_names.json";

{
  toEnvironmentMap(prod="", staging="", dev="", myns="", def=""): {
    "prod":if prod == "" then def else prod,
    "staging": if staging == "" then def else staging,
    "dev": if dev == "" then def else dev,
    "myns": if myns == "" then def else myns
  },
  prod: {name: "prod"},
  staging: {name: "staging"},
  dev: {name: "dev"},
  // jsonnet_libraries don't allow passing ext_code through,
  // so we make a dummy json file that can use ext_code and import that.
  myns: {name: environment_names["myns"]},
  getName(env): environment_names[env],
}
