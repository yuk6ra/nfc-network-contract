
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IOwnerBadge is IERC721{
    function ownerBadgeMint(bytes32[] calldata _merkleProof, bytes32 _serialNumber) external payable;
    function ownerBadgeExists(uint256 _tokenId) external view returns (bool);
    function setIsActive(bool _isActive) external;
    function setMerkleRoot(bytes32 _merkleRoot) external;
    function FriendBadgeTokenURI(uint256 _tokenId) external view returns (string memory);
    function getMerkleRoot() external view returns (bytes32);
    function isValidSerialNumber(uint256 _ownerBadgeId, bytes32 _serialNumber) external view returns (bool);
    function getSerialNumberToOwnerBadgeId(bytes32 _serialNumber) external view returns (uint256);
}