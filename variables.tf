variable "instance_type"{
    type="String"
}

variable "tags"{
    type="map(string)"
    default={}
}

variable "project"{
    type="String"
}

variable "env"{
    type="String"
}

variable "domain_name"{
    type="String"
}

variable "components"{
    type="String"
}