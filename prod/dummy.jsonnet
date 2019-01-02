// We just need a simple way to assemble a map in the BUILD file
// with the username passed in via another BUILD rule that has
// access to the current build user.

local ret = std.extVar("ret") {
  myns : std.extVar("user")
};

ret
