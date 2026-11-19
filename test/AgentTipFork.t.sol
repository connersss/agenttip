// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/AgentTip.sol";

/// @notice Fork tests for AgentTip against the real Agent ID contract on BSC mainnet.
/// @dev Run with: forge test --fork-url https://bsc-dataseed1.bnbchain.org
///      (or set the bsc rpc endpoint in foundry.toml and use --fork-url bsc)
contract AgentTipForkTest is Test {
    AgentTip public tipper;

    address constant SO1INAA_OWNER =
        0x12e3C700DdB6F3b7B76BEF16e1a07f71B7aF7498;
    uint256 constant SO1INAA_TOKEN_ID =
        59088328980715246198704127149844337433332371872360914276839784929778082154039;

    event Tipped(
        address indexed sender,
        address indexed recipient,
        uint256 indexed tokenId,
        string agentId,
        uint256 amount
    );

    function setUp() public {
        vm.createSelectFork("bsc");
        tipper = new AgentTip();
    }

    function testResolveSo1inaa() public view {
        assertEq(tipper.resolve("so1inaa"), SO1INAA_OWNER);
    }

    function testResolveRevertsForNonexistentAgentId() public {
        vm.expectRevert();
        tipper.resolve("this-agent-id-does-not-exist-xyz");
    }

    function testTipForwardsExactAmount() public {
        uint256 amount = 0.01 ether;
        address sender = address(0xBEEF);
        vm.deal(sender, amount);
        uint256 ownerBefore = SO1INAA_OWNER.balance;

        vm.prank(sender);
        tipper.tip{value: amount}("so1inaa");

        assertEq(SO1INAA_OWNER.balance, ownerBefore + amount);
        assertEq(address(tipper).balance, 0, "contract must not hold funds");
    }

    function testTipEmitsEvent() public {
        uint256 amount = 0.005 ether;
        address sender = address(0xBEEF);
        vm.deal(sender, amount);

        vm.expectEmit(true, true, true, true, address(tipper));
        emit Tipped(sender, SO1INAA_OWNER, SO1INAA_TOKEN_ID, "so1inaa", amount);

        vm.prank(sender);
        tipper.tip{value: amount}("so1inaa");
    }

    function testTipRevertsForNonexistentAgentId() public {
        vm.expectRevert();
        tipper.tip{value: 0.01 ether}("this-agent-id-does-not-exist-xyz");
    }

    function testTipRevertsForZeroValue() public {
        vm.expectRevert("AgentTip: zero tip");
        tipper.tip{value: 0}("so1inaa");
    }
}
