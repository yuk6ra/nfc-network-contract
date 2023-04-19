
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../interfaces/IOwnerBadge.sol";

contract FriendBadgeMock is ERC721, Ownable, ReentrancyGuard{

    struct FriendBadge {
        uint256 metadataURI;
        uint256 totalSupply;
        uint256 maxSupply;
        uint256 badgePrice;
        // address erc20tokenAddress;
    }

    uint256 public totalSupply;

    IOwnerBadge public ownerBadge;

    mapping (uint256 => uint256) public ownerBadgeIds;

    /// @dev owner badge id => friend badge
    mapping (uint256 => FriendBadge) public friendBadges;

    /// @dev owner badge id => msg.sender => is minted
    mapping (uint256 => mapping(address => bool)) public isMinted;

    constructor(
        address _ownerBadge
    ) ERC721("Friend Badge Mock", "FBM") {
        ownerBadge = IOwnerBadge(_ownerBadge);
    }

    function friendBadgeMint(
        bytes32[] calldata _merkleProof,
        uint256 _ownerBadgeId,
        bytes32 _serialNumber
    ) external nonReentrant {
        require(ownerBadge.ownerBadgeExists(_ownerBadgeId), "FriendBadge: Owner Badge does not exist");
        require(!isMinted[_ownerBadgeId][msg.sender], "FriendBadge: Already minted");
        require(MerkleProof.verify(_merkleProof, ownerBadge.getMerkleRoot(),  keccak256(abi.encodePacked(_serialNumber))), "FriendBadge: Invalid Merkle Proof");
        require(friendBadges[_ownerBadgeId].totalSupply < friendBadges[_ownerBadgeId].maxSupply || friendBadges[_ownerBadgeId].maxSupply == 0, "FriendBadge: Max supply reached");


        _safeMint(msg.sender, totalSupply);

        ownerBadgeIds[totalSupply] = _ownerBadgeId;
        friendBadges[_ownerBadgeId].totalSupply++;
        isMinted[_ownerBadgeId][msg.sender] = true;
        totalSupply++;
    }

    function _minter(address _to, uint256 __ownerBadgeIds) internal {
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        uint256 ownerBadgeId = ownerBadgeIds[_tokenId];

        return string(
            abi.encodePacked(
                friendBadges[ownerBadgeId].metadataURI
            )
        );
    }

    function setFriendBadge(
        uint256 _ownerBadgeId,
        uint256 _metadataURI,
        uint256 _maxSupply,
        uint256 _badgePrice
    ) external onlyOwnerBadge(_ownerBadgeId) {
        friendBadges[_ownerBadgeId] = FriendBadge({
            metadataURI: _metadataURI,
            totalSupply: 0,
            maxSupply: _maxSupply,
            badgePrice: _badgePrice
        });
    }

    // function setFriendBadgeMetadataURI(
    //     uint256 _ownerBadgeId,
    //     uint256 _metadataURI
    // ) external onlyOwnerBadge(_ownerBadgeId) {
    //     friendBadges[_ownerBadgeId].metadataURI = _metadataURI;
    // }

    modifier onlyOwnerBadge(
        uint256 _ownerBadgeId
    ) {
        require(msg.sender == ownerBadge.ownerOf(_ownerBadgeId), "FriendBadge: Only owner badge owner can call this function");
        _;
    }

}