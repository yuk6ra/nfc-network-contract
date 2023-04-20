// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../interfaces/IOwnerBadge.sol";

contract FriendBadgeMock is ERC721, Ownable, ReentrancyGuard {
    
    struct FriendBadge {
        string name;
        uint256 metadataNumber;
        uint256 totalSupply;
        uint256 maxSupply;
        uint256 badgePrice;
        // address erc20tokenAddress;
    }

    uint256 public totalSupply;

    IOwnerBadge public ownerBadge;

    mapping(uint256 => uint256) public ownerBadgeIds;

    /// @dev owner badge id => friend badge
    mapping(uint256 => FriendBadge) public friendBadges;

    /// @dev owner badge id => msg.sender => is minted
    mapping(uint256 => string) public metadataURIs;

    /// @dev owner badge id => msg.sender => is minted
    mapping(uint256 => mapping(address => bool)) public isMinted;

    constructor(address _ownerBadge) ERC721("Friend Badge Mock", "FBM") {
        ownerBadge = IOwnerBadge(_ownerBadge);
    }

    function friendBadgeMint(
        bytes32[] calldata _merkleProof,
        uint256 _ownerBadgeId,
        bytes32 _serialNumber
    ) external nonReentrant {
        require(
            ownerBadge.ownerBadgeExists(_ownerBadgeId),
            "FriendBadge: Owner Badge does not exist"
        );
        require(
            !isMinted[_ownerBadgeId][msg.sender],
            "FriendBadge: Already minted"
        );
        require(
            MerkleProof.verify(
                _merkleProof,
                ownerBadge.getMerkleRoot(),
                keccak256(abi.encodePacked(_serialNumber))
            ),
            "FriendBadge: Invalid Merkle Proof"
        );
        require(
            ownerBadge.isValidSerialNumber(_ownerBadgeId, _serialNumber),
            "FriendBadge: Invalid serial number"
        );
        require(
            friendBadges[_ownerBadgeId].totalSupply <=
                friendBadges[_ownerBadgeId].maxSupply ||
                friendBadges[_ownerBadgeId].maxSupply == 0,
            "FriendBadge: Max supply reached"
        );
        require(
            ownerBadge.ownerOf(_ownerBadgeId) != msg.sender,
            "FriendBadge: Cannot mint your own badge"
        );

        _safeMint(msg.sender, totalSupply);

        ownerBadgeIds[totalSupply] = _ownerBadgeId;
        friendBadges[_ownerBadgeId].totalSupply++;
        isMinted[_ownerBadgeId][msg.sender] = true;
        totalSupply++;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        uint256 ownerBadgeId = ownerBadgeIds[_tokenId];
        string memory baseURI = metadataURIs[
            friendBadges[ownerBadgeId].metadataNumber
        ];

        return string(abi.encodePacked(baseURI));
    }

    function setFriendBadge(
        string calldata _name,
        uint256 _ownerBadgeId,
        uint256 _metadataNumber,
        uint256 _maxSupply,
        uint256 _badgePrice
    ) external onlyOwnerBadge(_ownerBadgeId) {
        require(
            ownerBadge.ownerBadgeExists(_ownerBadgeId),
            "FriendBadge: Owner Badge does not exist"
        );
        require(
            friendBadges[_ownerBadgeId].totalSupply <= _maxSupply,
            "FriendBadge: Max supply must be greater than total supply"
        );
        require(
            metadataURIExists(_metadataNumber),
            "FriendBadge: Metadata URI does not exist"
        );

        friendBadges[_ownerBadgeId] = FriendBadge({
            name: _name,
            metadataNumber: _metadataNumber,
            totalSupply: 0,
            maxSupply: _maxSupply,
            badgePrice: _badgePrice
        });
    }

    function setFriendBadgeMetadataURI(
        uint256[] calldata _metadtaNumbers,
        string[] calldata _metadataURIs
    ) external onlyOwner {
        require(
            _metadtaNumbers.length == _metadataURIs.length,
            "FriendBadge: _metadtaNumbers and _metadataURIs length must be equal"
        );

        for (uint256 i = 0; i < _metadtaNumbers.length; i++) {
            metadataURIs[_metadtaNumbers[i]] = _metadataURIs[i];
        }
    }

    function metadataURIExists(
        uint256 _metadataNumber
    ) public view returns (bool) {
        return bytes(metadataURIs[_metadataNumber]).length > 0;
    }

    modifier onlyOwnerBadge(uint256 _ownerBadgeId) {
        require(
            msg.sender == ownerBadge.ownerOf(_ownerBadgeId),
            "FriendBadge: Only owner badge owner can call this function"
        );
        _;
    }

    function getTotalSupplyOfFriendBadge(
        uint256 _ownerBadgeId
    ) external view returns (uint256) {
        return friendBadges[_ownerBadgeId].totalSupply;
    }

}
