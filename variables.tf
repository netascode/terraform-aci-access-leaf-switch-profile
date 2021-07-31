variable "name" {
  description = "Leaf switch profile name"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.name))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "interface_profiles" {
  description = "List of interface profile names"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.interface_profiles : can(regex("^[a-zA-Z0-9_.-]{0,64}$", ip))
    ])
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "selectors" {
  description = "List of selectors, Allowed values `from`: 1-4000, Allowed values `to`: 1-4000."
  type = list(object({
    name   = string
    policy = optional(string)
    node_blocks = list(object({
      name = string
      from = number
      to   = optional(number)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for s in var.selectors : can(regex("^[a-zA-Z0-9_.-]{0,64}$", s.name))
    ])
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }

  validation {
    condition = alltrue([
      for s in var.selectors : can(regex("^[a-zA-Z0-9_.-]{0,64}$", s.policy))
    ])
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }

  validation {
    condition = alltrue(flatten([
      for s in var.selectors : [for nb in s.node_blocks : can(regex("^[a-zA-Z0-9_.-]{0,64}$", nb.name))]
    ]))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }

  validation {
    condition = alltrue(flatten([
      for s in var.selectors : [for nb in s.node_blocks : (nb.from >= 1 && nb.from <= 4000)]
    ]))
    error_message = "Minimum value: 1, Maximum value: 4000."
  }

  validation {
    condition = alltrue(flatten([
      for s in var.selectors : [for nb in s.node_blocks : (nb.to == null || (nb.to >= 1 && nb.to <= 4000))]
    ]))
    error_message = "Minimum value: 1, Maximum value: 4000."
  }
}
