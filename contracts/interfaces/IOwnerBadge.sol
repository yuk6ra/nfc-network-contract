
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IOwnerBadge {
    function ownerBadgeMint(bytes32[] calldata _merkleProof, bytes32 _serialNumber) external payable;
    function ownerBadgeExists(uint256 _tokenId) external view returns (bool);
    function setIsActive(bool _isActive) external;
    function setMerkleRoot(bytes32 _merkleRoot) external;
    function FriendBadgeTokenURI(uint256 _tokenId) external view returns (string memory);
    function getMerkleRoot() external view returns (bytes32);
}