locals {
  leaf_interface_profiles = [for v in var.interface_profiles : "uni/infra/accportprof-${v}"]
  node_blocks = flatten([
    for selector in var.selectors : [
      for node_block in selector.node_blocks : {
        key = "${selector.name}/${node_block.name}"
        value = {
          selector = selector.name
          name     = node_block.name
          from     = node_block.from
          to       = lookup(node_block, "to", node_block.from)
        }
      }
    ]
  ])
}

resource "aci_rest" "infraNodeP" {
  dn         = "uni/infra/nprof-${var.name}"
  class_name = "infraNodeP"
  content = {
    name = var.name
  }
}

resource "aci_rest" "infraLeafS" {
  for_each   = { for sel in var.selectors : sel.name => sel }
  dn         = "${aci_rest.infraNodeP.id}/leaves-${each.value.name}-typ-range"
  class_name = "infraLeafS"
  content = {
    name = each.value.name
  }
}

resource "aci_rest" "infraRsAccNodePGrp" {
  for_each   = { for sel in var.selectors : sel.name => sel if sel.policy_group != null }
  dn         = "${aci_rest.infraLeafS[each.value.name].id}/rsaccNodePGrp"
  class_name = "infraRsAccNodePGrp"
  content = {
    tDn = "uni/infra/funcprof/accnodepgrp-${each.value.policy_group}"
  }
}
resource "aci_rest" "infraNodeBlk" {
  for_each   = { for item in local.node_blocks : item.key => item.value }
  dn         = "${aci_rest.infraLeafS[each.value.selector].id}/nodeblk-${each.value.name}"
  class_name = "infraNodeBlk"
  content = {
    name  = each.value.name
    from_ = each.value.from
    to_   = each.value.to
  }
}

resource "aci_rest" "infraRsAccPortP" {
  for_each   = toset(local.leaf_interface_profiles)
  dn         = "${aci_rest.infraNodeP.id}/rsaccPortP-[${each.value}]"
  class_name = "infraRsAccPortP"
  content = {
    tDn = each.value
  }
}
