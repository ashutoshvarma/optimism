#!/usr/bin/env bash
set -euo pipefail

# Grab the script directory
SCRIPT_DIR=$(dirname "$0")

# Load common.sh
source "$SCRIPT_DIR/common.sh"

# Check required environment variables
reqenv "NETWORK"
reqenv "STORAGE_SETTER"
reqenv "DISPUTE_GAME_FACTORY_PROXY"
reqenv "DEPLOYMENTS_JSON_PATH"

# Load addresses from deployments json
PROXY_ADMIN=$(load_local_address $DEPLOYMENTS_JSON_PATH "ProxyAdmin")
OPTIMISM_PORTAL_PROXY=$(load_local_address $DEPLOYMENTS_JSON_PATH "OptimismPortalProxy")
SYSTEM_CONFIG_PROXY=$(load_local_address $DEPLOYMENTS_JSON_PATH "SystemConfigProxy")
L1_CROSS_DOMAIN_MESSENGER_PROXY=$(load_local_address $DEPLOYMENTS_JSON_PATH "L1CrossDomainMessengerProxy" "Proxy__OVM_L1CrossDomainMessenger")
L1_STANDARD_BRIDGE_PROXY=$(load_local_address $DEPLOYMENTS_JSON_PATH "L1StandardBridgeProxy" "Proxy__OVM_L1StandardBridge")
L1_ERC721_BRIDGE_PROXY=$(load_local_address $DEPLOYMENTS_JSON_PATH "L1ERC721BridgeProxy")
OPTIMISM_MINTABLE_ERC20_FACTORY_PROXY=$(load_local_address $DEPLOYMENTS_JSON_PATH "OptimismMintableERC20FactoryProxy")

# Fetch addresses from standard address toml
SYSTEM_CONFIG_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "system_config")
OPTIMISM_PORTAL_2_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "optimism_portal")
L1_CROSS_DOMAIN_MESSENGER_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "l1_cross_domain_messenger")
L1_STANDARD_BRIDGE_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "l1_standard_bridge")
L1_ERC721_BRIDGE_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "l1_erc721_bridge")
OPTIMISM_MINTABLE_ERC20_FACTORY_IMPL=$(fetch_standard_address $NETWORK "1.6.0" "optimism_mintable_erc20_factory")

# Fetch SuperchainConfigProxy address
SUPERCHAIN_CONFIG_PROXY=$(fetch_superchain_config_address $NETWORK)

# We need to re-generate the SystemConfig initialization call
# We want to use the exact same values that the SystemConfig is already using
SYSTEM_CONFIG_OWNER=$(cast call $SYSTEM_CONFIG_PROXY "owner()")
SYSTEM_CONFIG_OVERHEAD=$(cast call $SYSTEM_CONFIG_PROXY "overhead()")
SYSTEM_CONFIG_SCALAR=$(cast call $SYSTEM_CONFIG_PROXY "scalar()")
SYSTEM_CONFIG_BATCHER_HASH=$(cast call $SYSTEM_CONFIG_PROXY "batcherHash()")
SYSTEM_CONFIG_GAS_LIMIT=$(cast call $SYSTEM_CONFIG_PROXY "gasLimit()")
SYSTEM_CONFIG_UNSAFE_BLOCK_SIGNER=$(cast call $SYSTEM_CONFIG_PROXY "unsafeBlockSigner()")
SYSTEM_CONFIG_RESOURCE_CONFIG=$(cast call $SYSTEM_CONFIG_PROXY "resourceConfig()")
SYSTEM_CONFIG_BATCH_INBOX=$(cast call $SYSTEM_CONFIG_PROXY "batchInbox()")

# Now we generate the initialization calldata
SYSTEM_CONFIG_INITIALIZE_CALLDATA=$(cast calldata \
  "initialize(address,uint256,uint256,bytes32,uint64,address,(uint32,uint8,uint8,uint32,uint32,uint128),address,(address,address,address,address,address,address))" \
  $(cast parse-bytes32-address $SYSTEM_CONFIG_OWNER) \
  $SYSTEM_CONFIG_OVERHEAD \
  $SYSTEM_CONFIG_SCALAR \
  $SYSTEM_CONFIG_BATCHER_HASH \
  $SYSTEM_CONFIG_GAS_LIMIT \
  $(cast parse-bytes32-address $SYSTEM_CONFIG_UNSAFE_BLOCK_SIGNER) \
  "("$(cast abi-decode "null()(uint32,uint8,uint8,uint32,uint32,uint128)" $SYSTEM_CONFIG_RESOURCE_CONFIG --json | jq -r 'join(",")')")" \
  $(cast parse-bytes32-address $SYSTEM_CONFIG_BATCH_INBOX) \
  "($L1_CROSS_DOMAIN_MESSENGER_PROXY,$L1_ERC721_BRIDGE_PROXY,$L1_STANDARD_BRIDGE_PROXY,$DISPUTE_GAME_FACTORY_PROXY,$OPTIMISM_PORTAL_PROXY,$OPTIMISM_MINTABLE_ERC20_FACTORY_PROXY)"
)

# Generate JSON
cat << EOF
{
  "version": "1.0",
  "chainId": "11155111",
  "createdAt": $(date +%s%3N),
  "meta": {
    "name": "Transactions Batch",
    "description": "",
    "txBuilderVersion": "1.17.0",
    "createdFromSafeAddress": "",
    "createdFromOwnerAddress": ""
  },
  "transactions": [
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$OPTIMISM_PORTAL_PROXY",
        "_implementation": "$STORAGE_SETTER"
      }
    },
    {
      "to": "$OPTIMISM_PORTAL_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_slot",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "_value",
            "type": "bytes32",
            "internalType": "bytes32"
          }
        ],
        "name": "setBytes32",
        "payable": false
      },
      "contractInputsValues": {
        "_slot": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "_value": "0x0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "to": "$OPTIMISM_PORTAL_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_slot",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "_value",
            "type": "bytes32",
            "internalType": "bytes32"
          }
        ],
        "name": "setBytes32",
        "payable": false
      },
      "contractInputsValues": {
        "_slot": "0x0000000000000000000000000000000000000000000000000000000000000032",
        "_value": "0x0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$OPTIMISM_PORTAL_PROXY",
        "_implementation": "$OPTIMISM_PORTAL_2_IMPL"
      }
    },
    {
      "to": "$OPTIMISM_PORTAL_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_disputeGameFactory",
            "type": "address",
            "internalType": "contract DisputeGameFactory"
          },
          {
            "name": "_systemConfig",
            "type": "address",
            "internalType": "contract SystemConfig"
          },
          {
            "name": "_superchainConfig",
            "type": "address",
            "internalType": "contract SuperchainConfig"
          },
          {
            "name": "_initialRespectedGameType",
            "type": "uint32",
            "internalType": "GameType"
          }
        ],
        "name": "initialize",
        "payable": false
      },
      "contractInputsValues": {
        "_disputeGameFactory": "$DISPUTE_GAME_FACTORY_PROXY",
        "_systemConfig": "$SYSTEM_CONFIG_PROXY",
        "_superchainConfig": "$SUPERCHAIN_CONFIG_PROXY",
        "_initialRespectedGameType": "1"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$SYSTEM_CONFIG_PROXY",
        "_implementation": "$STORAGE_SETTER"
      }
    },
    {
      "to": "$SYSTEM_CONFIG_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_slot",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "_value",
            "type": "bytes32",
            "internalType": "bytes32"
          }
        ],
        "name": "setBytes32",
        "payable": false
      },
      "contractInputsValues": {
        "_slot": "0xe52a667f71ec761b9b381c7b76ca9b852adf7e8905da0e0ad49986a0a6871815",
        "_value": "0x0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "to": "$SYSTEM_CONFIG_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_slot",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "_address",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "setAddress",
        "payable": false
      },
      "contractInputsValues": {
        "_slot": "0x52322a25d9f59ea17656545543306b7aef62bc0cc53a0e65ccfa0c75b97aa906",
        "_address": "$DISPUTE_GAME_FACTORY_PROXY"
      }
    },
    {
      "to": "$SYSTEM_CONFIG_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_slot",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "_value",
            "type": "bytes32",
            "internalType": "bytes32"
          }
        ],
        "name": "setBytes32",
        "payable": false
      },
      "contractInputsValues": {
        "_slot": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "_value": "0x0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          },
          {
            "internalType": "bytes",
            "name": "_data",
            "type": "bytes"
          }
        ],
        "name": "upgradeAndCall",
        "payable": false
      },
      "contractInputsValues": {
        "_data": "$SYSTEM_CONFIG_INITIALIZE_CALLDATA",
        "_proxy": "$SYSTEM_CONFIG_PROXY",
        "_implementation": "$SYSTEM_CONFIG_IMPL"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$L1_CROSS_DOMAIN_MESSENGER_PROXY",
        "_implementation": "$STORAGE_SETTER"
      }
    },
    {
      "to": "$L1_CROSS_DOMAIN_MESSENGER_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_slot",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "_value",
            "type": "bytes32",
            "internalType": "bytes32"
          }
        ],
        "name": "setBytes32",
        "payable": false
      },
      "contractInputsValues": {
        "_slot": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "_value": "0x0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$L1_CROSS_DOMAIN_MESSENGER_PROXY",
        "_implementation": "$L1_CROSS_DOMAIN_MESSENGER_IMPL"
      }
    },
    {
      "to": "$L1_CROSS_DOMAIN_MESSENGER_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "internalType": "contract SuperchainConfig",
            "name": "_superchainConfig",
            "type": "address"
          },
          {
            "internalType": "contract OptimismPortal",
            "name": "_portal",
            "type": "address"
          }
        ],
        "name": "initialize",
        "payable": false
      },
      "contractInputsValues": {
        "_superchainConfig": "$SUPERCHAIN_CONFIG_PROXY",
        "_portal": "$OPTIMISM_PORTAL_PROXY"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$L1_STANDARD_BRIDGE_PROXY",
        "_implementation": "$STORAGE_SETTER"
      }
    },
    {
      "to": "$L1_STANDARD_BRIDGE_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_slot",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "_value",
            "type": "bytes32",
            "internalType": "bytes32"
          }
        ],
        "name": "setBytes32",
        "payable": false
      },
      "contractInputsValues": {
        "_slot": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "_value": "0x0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$L1_STANDARD_BRIDGE_PROXY",
        "_implementation": "$L1_STANDARD_BRIDGE_IMPL"
      }
    },
    {
      "to": "$L1_STANDARD_BRIDGE_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "internalType": "contract CrossDomainMessenger",
            "name": "_messenger",
            "type": "address"
          },
          {
            "internalType": "contract SuperchainConfig",
            "name": "_superchainConfig",
            "type": "address"
          }
        ],
        "name": "initialize",
        "payable": false
      },
      "contractInputsValues": {
        "_messenger": "$L1_CROSS_DOMAIN_MESSENGER_PROXY",
        "_superchainConfig": "$SUPERCHAIN_CONFIG_PROXY"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$L1_ERC721_BRIDGE_PROXY",
        "_implementation": "$STORAGE_SETTER"
      }
    },
    {
      "to": "$L1_ERC721_BRIDGE_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_slot",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "_value",
            "type": "bytes32",
            "internalType": "bytes32"
          }
        ],
        "name": "setBytes32",
        "payable": false
      },
      "contractInputsValues": {
        "_slot": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "_value": "0x0000000000000000000000000000000000000000000000000000000000000000"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$L1_ERC721_BRIDGE_PROXY",
        "_implementation": "$L1_ERC721_BRIDGE_IMPL"
      }
    },
    {
      "to": "$L1_ERC721_BRIDGE_PROXY",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_messenger",
            "type": "address",
            "internalType": "contract CrossDomainMessenger"
          },
          {
            "name": "_superchainConfig",
            "type": "address",
            "internalType": "contract SuperchainConfig"
          }
        ],
        "name": "initialize",
        "payable": false
      },
      "contractInputsValues": {
        "_messenger": "$L1_CROSS_DOMAIN_MESSENGER_PROXY",
        "_superchainConfig": "$SUPERCHAIN_CONFIG_PROXY"
      }
    },
    {
      "to": "$PROXY_ADMIN",
      "value": "0",
      "data": null,
      "contractMethod": {
        "inputs": [
          {
            "name": "_proxy",
            "type": "address",
            "internalType": "address payable"
          },
          {
            "name": "_implementation",
            "type": "address",
            "internalType": "address"
          }
        ],
        "name": "upgrade",
        "payable": false
      },
      "contractInputsValues": {
        "_proxy": "$OPTIMISM_MINTABLE_ERC20_FACTORY_PROXY",
        "_implementation": "$OPTIMISM_MINTABLE_ERC20_FACTORY_IMPL"
      }
    }
  ]
}
EOF
