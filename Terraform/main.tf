module "resource_group" {
  source = "./modules/resource_group"

  application = var.application
  environment = "all"
  owner       = var.owner
  location    = var.location
  prefix      = var.prefix
}

# module "la_resource_group" {
#   source = "./modules/resource_group"

#   application = "monitoring"
#   environment = "all"
#   owner       = var.owner
#   location    = var.location
#   prefix      = var.prefix
# }

module "networking" {
  source = "./modules/networking"

  application         = var.application
  environment         = var.environment
  owner               = var.owner
  location            = var.location
  prefix              = var.prefix
  resource_group_name = module.resource_group.resource_group_name
}

# module "postgres_server" {
#   source = "./modules/postgres_db"

#   resource_group_name = module.resource_group.resource_group_name
#   location            = var.location

#   environment = var.environment
#   application = var.application
#   owner       = var.owner
#   prefix      = var.prefix
# }

# module "web_app" {
#   source = "./modules/web_app"

#   prefix      = var.prefix
#   application = var.application
#   environment = var.environment
#   owner       = var.owner

#   resource_group_name = module.resource_group.resource_group_name
#   location            = var.location

#   postgres_user     = module.postgres_server.postgres_user
#   postgres_password = module.postgres_server.postgres_password
#   postgres_host     = module.postgres_server.postgres_host

#   log_analytics_workspace_id = module.log_analytics.la_id
#   critical_ag                = module.log_analytics.critical_ag
#   warning_ag                 = module.log_analytics.warning_ag
# }

# DEL - 2023.05.14 - ADD - 2023.05.20
module "bastion" {
  source = "./modules/virtual_machine"

  count = 2

  application         = "bastion"
  environment         = var.environment
  owner               = var.owner
  location            = var.location
  prefix              = var.prefix
  instances           = count.index
  admin_password      = var.admin_password
  resource_group_name = module.resource_group.resource_group_name
  subnet_id           = module.networking.subnet_id
  sg_id               = module.networking.sg_id
  create_public_ip    = true
  create_as           = false
}

# module "application_nodes" {
#   source = "./modules/virtual_machine"

#   count = 2

#   application         = "nginx"
#   environment         = var.environment
#   owner               = var.owner
#   location            = var.location
#   prefix              = var.prefix
#   instances           = count.index
#   admin_password      = var.admin_password
#   resource_group_name = module.resource_group.resource_group_name
#   subnet_id           = module.networking.subnet_id
#   sg_id               = module.networking.sg_id
#   create_public_ip    = false
#   create_as           = false
# }

# module "webserver_load_balancer" {
#   source = "./modules/load_balancer"

#   prefix              = var.prefix
#   application         = var.application
#   environment         = var.environment
#   resource_group_name = module.resource_group.resource_group_name
#   owner               = var.owner
#   location            = var.location

#   vm_names = [
#     module.application_nodes[0].vm_name,
#     module.application_nodes[1].vm_name
#   ]

#   vm_nic = [
#     module.application_nodes[0].vm_nic,
#     module.application_nodes[1].vm_nic
#   ]

#   depends_on = [
#     module.application_nodes
#   ]
# }

# module "log_analytics" {
#   source = "./modules/monitoring/log_analytics"

#   prefix      = var.prefix
#   application = var.application
#   owner       = var.owner

#   resource_group_name = module.la_resource_group.resource_group_name
#   location            = var.location
# }

# # module "frontend" {
# module "frontend-kk" {
#   source = "./modules/storage_account"

#   resource_group_name = module.resource_group.resource_group_name

#   application = var.application
#   environment = var.environment
#   owner       = var.owner
#   location    = var.location
# }

# module "acr_and_aks" {
#   source = "./modules/acr_aks"

#   resource_group_name = module.resource_group.resource_group_name

#   location    = var.location
#   prefix      = var.prefix
#   application = var.application
#   environment = var.environment
#   owner       = var.owner
# }

module "logic_app_startup" {
  source = "./modules/logic_app"

  resource_group_name = module.resource_group.resource_group_name
  environment         = var.environment
  application         = var.application
  owner               = var.owner
  prefix              = var.prefix
  location            = var.location

  stage = "startup"
  # path  = "./modules/logic_app/logic_app_code/start.json"
}

# new logic app
module "logic_app_shutdown" {
  source = "./modules/logic_app"

  resource_group_name = module.resource_group.resource_group_name
  environment         = var.environment
  application         = var.application
  owner               = var.owner
  prefix              = var.prefix
  location            = var.location

  stage = "shutdown"
  #path  = "./modules/logic_app/logic_app_code/stop.json"
}

module "logic_app" {
  source = "./modules/logic_app"

  resource_group_name = module.resource_group.resource_group_name
  environment         = var.environment
  application         = var.application
  owner               = var.owner
  prefix              = var.prefix
  location            = var.location

  stage = "shutdown"
  # path  = "./modules/logic_app/logic_app_code/shutdown.json"
}
