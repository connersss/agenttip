// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/AgentTip.sol";

/// @notice A stateless stand-in for the Agent ID contract.
/// @dev ownerOf is a pure function of the tokenId, so the mock can be etched
///      at the real Agent ID address with vm.etch (no storage to copy).
contract MockAgentID {
    uint256 public constant SO1INAA_TOKEN_ID =
        59088328980715246198704127149844337433332371872360914276839784929778082154039;
    address public constant SO1INAA_OWNER =
        0x12e3C700DdB6F3b7B76BEF16e1a07f71B7aF7498;

    function ownerOf(uint256 tokenId) external pure returns (address) {
        if (tokenId == SO1INAA_TOKEN_ID) return SO1INAA_OWNER;
        revert("ERC721: invalid token ID");
    }
}

/// @notice Unit tests for AgentTip against a mocked Agent ID contract.
/// @dev No fork needed. The mock is etched at the real Agent ID address.
contract AgentTipTest is Test {
    AgentTip public tipper;

    address constant AGENT_ID =
        0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;
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
        MockAgentID mock = new MockAgentID();
        vm.etch(AGENT_ID, address(mock).code);
        tipper = new AgentTip();
    }

    function testResolveSo1inaa() public view {
        assertEq(tipper.resolve("so1inaa"), SO1INAA_OWNER);
    }

    function testResolveRevertsForNonexistentAgentId() public {
        vm.expectRevert("ERC721: invalid token ID");
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
        vm.expectRevert("ERC721: invalid token ID");
        tipper.tip{value: 0.01 ether}("this-agent-id-does-not-exist-xyz");
    }

    function testTipRevertsForZeroValue() public {
        vm.expectRevert("AgentTip: zero tip");
        tipper.tip{value: 0}("so1inaa");
    }

    function testTokenIdMatchesKeccak() public pure {
        assertEq(
            uint256(keccak256(bytes("so1inaa"))),
            SO1INAA_TOKEN_ID
        );
    }
}
