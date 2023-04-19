
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../interfaces/IOwnerBadge.sol";

contract FriendBadge is ERC721, Ownable, ReentrancyGuard{

    uint256 public totalSupply;

    IOwnerBadge public ownerBadge;

    mapping (uint256 => uint256) public ownerBadgeIds;

    constructor(
        address _ownerBadge
    ) ERC721("Friend Badge", "FB") {
        ownerBadge = IOwnerBadge(_ownerBadge);
    }

    function friendBadgeMint(
        bytes32[] calldata _merkleProof,
        uint256 _ownerBadgeIds, 
        bytes32 _serialNumber
    ) external nonReentrant {
        require(ownerBadge.ownerBadgeExists(_ownerBadgeIds), "FriendBadge: Owner Badge does not exist");
        require(MerkleProof.verify(_merkleProof, ownerBadge.getMerkleRoot(),  keccak256(abi.encodePacked(_serialNumber))), "FriendBadge: Invalid Merkle Proof");

        _safeMint(msg.sender, totalSupply);

        ownerBadgeIds[totalSupply] = _ownerBadgeIds;
        totalSupply++;

    }

    function _minter(address _to, uint256 __ownerBadgeIds) internal {
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        uint256 ownerBadgeId = ownerBadgeIds[_tokenId];

        return string(
            abi.encodePacked(
                ownerBadge.FriendBadgeTokenURI(ownerBadgeId)
            )
        );
    }
    


}