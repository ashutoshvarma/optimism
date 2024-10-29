#!/usr/bin/env bash
set -euo pipefail

# Grab the script directory
SCRIPT_DIR=$(dirname "$0")

# Load common.sh
source "$SCRIPT_DIR/common.sh"

# Check required environment variables
reqenv "ETH_RPC_URL"
reqenv "PRIVATE_KEY"
reqenv "ETHERSCAN_API_KEY"
reqenv "DEPLOY_CONFIG_PATH"
reqenv "DEPLOYMENTS_JSON_PATH"
reqenv "NETWORK"
reqenv "IMPL_SALT"
reqenv "SYSTEM_OWNER_SAFE"

# Load addresses from deployments json
PROXY_ADMIN=$(load_local_address $DEPLOYMENTS_JSON_PATH "ProxyAdmin")

# Fetch addresses from standard address toml
# DISPUTE_GAME_FACTORY_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "dispute_game_factory")
DISPUTE_GAME_FACTORY_IMPL="0xEbEB3bf4f4C33db8Ba391af22e19EBc8d12B4d8A"
# DELAYED_WETH_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "delayed_weth")
DELAYED_WETH_IMPL="0xe3d56b7763d42Aa9B4f5263caD8A53C8E1035484"
# PREIMAGE_ORACLE_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "preimage_oracle")
PREIMAGE_ORACLE_IMPL="0xcEa1076De00f4E4a6E473D0D16D45B0E8844E088"
# MIPS_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "mips")
MIPS_IMPL="0x620A4D0c9f4703F00906bC02fb83EE11c5cCAc4c"
# OPTIMISM_PORTAL_2_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "optimism_portal")
OPTIMISM_PORTAL_2_IMPL="0x6b82F0Ff7bD6F4D8EcCAa0c322B328AF9e3F93b4"

# Fetch the SuperchainConfigProxy address
SUPERCHAIN_CONFIG_PROXY=$(fetch_superchain_config_address $NETWORK)

# Run the upgrade script
forge script DeployUpgrade.s.sol \
  --rpc-url $ETH_RPC_URL \
  --private-key $PRIVATE_KEY \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --sig "deploy(address,address,address,address,address,address,address,address)" \
  $PROXY_ADMIN \
  $SYSTEM_OWNER_SAFE \
  $SUPERCHAIN_CONFIG_PROXY \
  $DISPUTE_GAME_FACTORY_IMPL \
  $DELAYED_WETH_IMPL \
  $PREIMAGE_ORACLE_IMPL \
  $MIPS_IMPL \
  $OPTIMISM_PORTAL_2_IMPL \
  --broadcast \
  --slow \
  --verify
