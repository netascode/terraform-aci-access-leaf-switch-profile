terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "netascode/aci"
      version = ">=0.2.0"
    }
  }
}

module "main" {
  source = "../.."

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

data "aci_rest" "infraNodeP" {
  dn = "uni/infra/nprof-${module.main.name}"

  depends_on = [module.main]
}

resource "test_assertions" "infraNodeP" {
  component = "infraNodeP"

  equal "name" {
    description = "name"
    got         = data.aci_rest.infraNodeP.content.name
    want        = module.main.name
  }
}

data "aci_rest" "infraLeafS" {
  dn = "${data.aci_rest.infraNodeP.id}/leaves-SEL1-typ-range"

  depends_on = [module.main]
}

resource "test_assertions" "infraLeafS" {
  component = "infraLeafS"

  equal "name" {
    description = "name"
    got         = data.aci_rest.infraLeafS.content.name
    want        = "SEL1"
  }
}

data "aci_rest" "infraNodeBlk" {
  dn = "${data.aci_rest.infraLeafS.id}/nodeblk-BLOCK1"

  depends_on = [module.main]
}

resource "test_assertions" "infraNodeBlk" {
  component = "infraNodeBlk"

  equal "name" {
    description = "name"
    got         = data.aci_rest.infraNodeBlk.content.name
    want        = "BLOCK1"
  }

  equal "from_" {
    description = "from_"
    got         = data.aci_rest.infraNodeBlk.content.from_
    want        = "101"
  }

  equal "to_" {
    description = "to_"
    got         = data.aci_rest.infraNodeBlk.content.to_
    want        = "101"
  }
}

data "aci_rest" "infraRsAccPortP" {
  dn = "${data.aci_rest.infraNodeP.id}/rsaccPortP-[uni/infra/accportprof-PROF1]"

  depends_on = [module.main]
}

resource "test_assertions" "infraRsAccPortP" {
  component = "infraRsAccPortP"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.infraRsAccPortP.content.tDn
    want        = "uni/infra/accportprof-PROF1"
  }
}
