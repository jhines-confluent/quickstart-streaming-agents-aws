terraform {
  required_version = ">= 1.0"
  required_providers {
    confluent = {
      source = "confluentinc/confluent"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.cloud_region
  alias  = "main"
}

# Confluent Provider Configuration
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# Random Provider Configuration
provider "random" {}

module "aws_deployment" {
  count       = local.cloud_provider == "AWS" ? 1 : 0
  source      = "./modules/aws"
  cloud_region = var.cloud_region
  random_id    = random_id.resource_suffix.hex
  prefix       = var.prefix
  model_prefix = local.model_prefix
  confluent_organization_id = data.confluent_organization.main.id
  confluent_environment_id = confluent_environment.staging.id
  confluent_compute_pool_id = confluent_flink_compute_pool.flinkpool-main.id
  confluent_service_account_id = confluent_service_account.app-manager.id
  confluent_flink_rest_endpoint = data.confluent_flink_region.demo_flink_region.rest_endpoint
  confluent_flink_api_key_id = confluent_api_key.app-manager-flink-api-key.id
  confluent_flink_api_key_secret = confluent_api_key.app-manager-flink-api-key.secret
  zapier_endpoint = local.ZAPIER_ENDPOINT
  zapier_sse_endpoint = var.ZAPIER_SSE_ENDPOINT
}
