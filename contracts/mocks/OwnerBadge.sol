// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract OwnerBadge is ERC721, Ownable, ReentrancyGuard {

    uint256 public totalSupply;

    bytes32 public merkleRoot;

    bool public isActive = false;

    struct OwnerBadge {
        string baseURI;
        string description;
        string image;
        string link;
        uint256 price;
        uint256 supply;
        uint256 minted;
        bool active;
    }

    /// @dev owner Id => OwnerBadge
    mapping (uint256 => OwnerBadge) public badges;

    constructor() ERC721("Owner Button Badge", "OBB") {}

    function ownerBadgeMint(bytes32[] calldata _merkleProof, bytes32 _serialNumber) external payable nonReentrant {
        require(isActive, "OwnerButtonBadge: Sale is not active");
        require(MerkleProof.verify(_merkleProof, merkleRoot,  keccak256(abi.encodePacked(_serialNumber))), "OwnerButtonBadge: Invalid Merkle Proof");
        _minter(msg.sender);
    }

    function ownerBadgeExists(uint256 _ownerId) public view returns (bool) {
        return _exists(_ownerId);
    }

    function _minter(address _to) internal {
        _safeMint(_to, totalSupply);
        totalSupply++;
    }

    function getMerkleRoot() public view returns (bytes32) {
        return merkleRoot;
    }

    function setIsActive(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function FriendBadgeTokenURI(uint256 _ownerBadgeIds) public view returns (string memory) {
        return string(
            abi.encodePacked(
                badges[_ownerBadgeIds].baseURI
            )
        );
    }

}
