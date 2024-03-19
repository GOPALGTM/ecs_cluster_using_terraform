variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "ecsTaskExecutionRole"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "ingress_ports" {
  default = [22, 80, 443, 8000]
}

variable "ttl" {
  default = 300
}

variable "domain_name" {
  description = "domain name"
  default     = "myapp.devtool.site"
}

