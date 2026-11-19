// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AgentTip
/// @notice Tip any Agent ID holder by their .ai name, on BNB Chain.
/// @dev An Agent ID's tokenId is uint256(keccak256(label)), where label is the
///      name WITHOUT the ".ai" suffix. For example, keccak256("so1inaa") is the
///      tokenId of so1inaa.ai. The Agent ID contract is SPACE ID Agent ID
///      (ERC-721, non-transferable) on BNB Chain mainnet.
///      No owner, no admin, no fees, non-upgradeable. No funds are ever held:
///      the full msg.value is forwarded to the Agent ID owner in the same call.
interface IAgentID {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract AgentTip {
    /// @notice The Agent ID contract (SPACE ID Agent ID, ERC-721) on BNB Chain.
    address public constant AGENT_ID =
        0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;

    /// @notice Emitted when a tip is sent.
    /// @param sender The address that sent the tip.
    /// @param recipient The Agent ID owner who received the tip.
    /// @param tokenId The Agent ID tokenId (uint256(keccak256(label))).
    /// @param agentId The Agent ID label as given (without ".ai").
    /// @param amount The tipped amount in wei.
    event Tipped(
        address indexed sender,
        address indexed recipient,
        uint256 indexed tokenId,
        string agentId,
        uint256 amount
    );

    /// @notice Tip an Agent ID holder by their .ai name.
    /// @param agentId The Agent ID label WITHOUT the ".ai" suffix, e.g. "so1inaa".
    /// @dev Reverts if the Agent ID does not exist (ownerOf reverts) or if the
    ///      value is zero. The full msg.value is forwarded to the recipient.
    function tip(string calldata agentId) external payable {
        require(msg.value > 0, "AgentTip: zero tip");
        uint256 tokenId = uint256(keccak256(bytes(agentId)));
        address recipient = IAgentID(AGENT_ID).ownerOf(tokenId);
        emit Tipped(msg.sender, recipient, tokenId, agentId, msg.value);
        (bool ok, ) = recipient.call{value: msg.value}("");
        require(ok, "AgentTip: transfer failed");
    }

    /// @notice Resolve an Agent ID label to its owner's address.
    /// @param agentId The Agent ID label WITHOUT the ".ai" suffix, e.g. "so1inaa".
    /// @return The address that owns the Agent ID. Reverts if it does not exist.
    function resolve(string calldata agentId) external view returns (address) {
        uint256 tokenId = uint256(keccak256(bytes(agentId)));
        return IAgentID(AGENT_ID).ownerOf(tokenId);
    }
}
