module "aci_access_leaf_switch_profile" {
  source = "netascode/access-leaf-switch-profile/aci"

  name               = "LEAF101"
  interface_profiles = ["PROF1"]
  selectors = [{
    name   = "SEL1"
    policy = "POL1"
    node_blocks = [{
      name = "BLOCK1"
      from = 101
      to   = 101
    }]
  }]
}
