# a rule that can copy a file to be local to the current directory.
# The primary use case is to copy .proto files into the same folder as the server and client
# code so that import calls can refer to the .proto file locally instead of needing to know the absolute path
# within the workspace.

# Status: I need to figure out how to reference the src files in the cp command

def make_local(name, src=None, visibility=None):
  # Creating a native genrule.
  native.genrule(
      name = name,
      outs = [name],
      cmd = "cp {} .".format(),
      visibility = visibility,
  )
