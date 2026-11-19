// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/AgentTip.sol";

/// @notice Deploy AgentTip to BNB Chain mainnet.
/// @dev DO NOT run this without the user's explicit confirmation.
///      It broadcasts a real transaction and spends real BNB for gas.
///      Dry-run first:
///        forge script script/Deploy.s.sol --rpc-url bsc --dry-run
///      Then, only with confirmation, deploy:
///        forge script script/Deploy.s.sol --rpc-url bsc --broadcast \
///          --account <account> --sender <address>
///      Verify on BscScan after deploy:
///        forge verify-contract <address> contracts/AgentTip.sol:AgentTip \
///          --chain-id 56 --etherscan-api-key <key>
contract Deploy is Script {
    function run() external returns (AgentTip) {
        vm.startBroadcast();
        AgentTip tipper = new AgentTip();
        vm.stopBroadcast();
        console.log("AgentTip deployed at:", address(tipper));
        return tipper;
    }
}
