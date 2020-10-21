local env = "myns";//std.extVar("env");

{
    splitByEnvironment(prod="", staging="", dev="", myns="", def=""): {
        "prod":if prod == "" then def else prod,
        "staging": if staging == "" then def else staging,
        "dev": if dev == "" then def else dev,
        "myns": if myns == "" then def else myns
    }[env]
}
