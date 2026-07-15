variable "instance_type"{
    type=string
}

variable "tags"{
    type=map(string)
    default={}
}

variable "project"{
    ttype=string
}

variable "env"{
    type=string
}

variable "domain_name"{
    type=string
}

variable "components"{
    type=string
}