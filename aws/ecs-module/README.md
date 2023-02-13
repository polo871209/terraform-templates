EXAMPLE USAGE:
```hcl
module "ecs-module" {
  source  = "./ecs-module"
  # Name of the usage
  app_name           = "po-test" 
  # Staging, production or testing
  app_env            = "staging"
  # Region
  region             = "ap-northeast-3"
  # az in list format
  availability_zones = ["ap-northeast-3a", "ap-northeast-3b"]
  # private subnet cidr range in list format
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  # public subnet cidr range in list format      
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]   
  # container port      
  container_port     = "8080"
}
```