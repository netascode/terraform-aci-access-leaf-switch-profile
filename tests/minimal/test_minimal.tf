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

  name = "LEAF101"
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
