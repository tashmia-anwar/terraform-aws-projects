variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default = ""
}

variable "assume_role_policy" {
  description = "Trust policy that defines who can assume this IAM role (JSON)"
  type = string
}

variable "tags" {
  description = "Tags to apply to the IAM role"
  type = map(string)
  default = {}
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the IAM role"
  type = list(string)
  default = []
}