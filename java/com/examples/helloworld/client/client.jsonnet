
local kube = import "external/kube_jsonnet/kube.libsonnet";
local backend_service = std.extVar("backend_service");
local params = std.extVar("params");
local PROD = params.env.PROD;
local STAGING = params.env.STAGING;
local DEV = params.env.DEV;
local LOCAL = params.env["local"];

local main_container = kube.Container("client") {
  local images = {
    PROD: params.image_base + "some_prod_tag",
    STAGING: params.image_base + "some_staging_tag",
    DEV: params.image_base + "some_dev_tag",
    LOCAL: params.local_image_name
  },
  image: images[params.env],
  # I can switch on params.env to get environment specific configuration.
  args: [backend_service.metadata.name,  std.toString(backend_service.spec.ports[0].port)],
};


local deployment = std.prune(kube.Deployment(params.name) {
  spec+: {
    template+: {
      spec+: {
        containers_+: {
          foo_cont: main_container,
        },
      },
    },
  },
});

// render the deployment object as the output json.
deployment
