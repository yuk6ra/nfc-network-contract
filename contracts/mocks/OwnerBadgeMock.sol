// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../interfaces/IFriendBadge.sol";

contract OwnerBadgeMock is ERC721, Ownable, ReentrancyGuard {
    uint256 public totalSupply;

    bytes32 public merkleRoot;

    IFriendBadge public friendBadge;

    bool public isActive = false;

    struct OwnerBadge {
        string username;
        string icon;
        string link;
    }

    /// @dev owner Id => OwnerBadge
    mapping(uint256 => OwnerBadge) public ownerBadges;

    /// @dev level => metadataURI
    mapping (uint256 => string) public metadataURIs;

    constructor() ERC721("Owner Badge Mock", "OBM") {}

    function ownerBadgeMint(
        bytes32[] calldata _merkleProof,
        bytes32 _serialNumber
    ) external payable nonReentrant {
        require(isActive, "OwnerButtonBadge: Sale is not active");
        require(
            MerkleProof.verify(
                _merkleProof,
                merkleRoot,
                keccak256(abi.encodePacked(_serialNumber))
            ),
            "OwnerButtonBadge: Invalid Merkle Proof"
        );

        _safeMint(msg.sender, totalSupply);
        totalSupply++;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        uint256 level = getLevel(_tokenId);
        string memory baseURI = metadataURIs[level];

        return
            string(
                abi.encodePacked(
                    baseURI, level
                )
            );
    }

    function getLevel(uint256 _ownerBadgeId) public view returns (uint256) {
        require(ownerBadgeExists(_ownerBadgeId), "ERC721Metadata: URI query for nonexistent token");

        uint256 _totalSupply = friendBadge.getTotalSupplyOfFriendBadge(_ownerBadgeId);

        if (_totalSupply <= 1) {
            return 1;
        } else if (_totalSupply <= 2) {
            return 2;
        } else if (_totalSupply <= 3) {
            return 3;
        } else if (_totalSupply <= 4) {
            return 4;
        } else {
            return 5;
        }
    }

    /// @dev level >= 1
    function setUsername(uint256 _ownerBadgeId, string calldata _username) external onlyOwnerBadge(_ownerBadgeId) {
        require(ownerBadgeExists(_ownerBadgeId), "OwnerBadge: Owner Badge does not exist");
        require(getLevel(_ownerBadgeId) >= 1, "OwnerBadge: Level is not enough");
        ownerBadges[_ownerBadgeId].username = _username;
    }

    /// @dev level >= 2
    function setLink(uint256 _ownerBadgeId, string calldata _link) external onlyOwnerBadge(_ownerBadgeId) {
        require(ownerBadgeExists(_ownerBadgeId), "OwnerBadge: Owner Badge does not exist");
        require(getLevel(_ownerBadgeId) >= 2, "OwnerBadge: Level is not enough");
        ownerBadges[_ownerBadgeId].link = _link;
    }

    /// @dev level >= 1
    function setIcon(uint256 _ownerBadgeId, string calldata _icon) external onlyOwnerBadge(_ownerBadgeId) {
        require(ownerBadgeExists(_ownerBadgeId), "OwnerBadge: Owner Badge does not exist");
        require(getLevel(_ownerBadgeId) >= 3, "OwnerBadge: Level is not enough");
        ownerBadges[_ownerBadgeId].icon = _icon;
    }

    
    function setOwnerBadgeMetadataURI(
        uint256[] calldata _level,
        string[] calldata _metadataURIs
    ) external onlyOwner {
        require(_level.length == _metadataURIs.length, "OwnerBadge: _level and _metadataURIs length must be equal");

        for (uint256 i = 0; i < _level.length; i++) {
            metadataURIs[_level[i]] = _metadataURIs[i];
        }
    }    

    function ownerBadgeExists(uint256 _ownerBadgeId) public view returns (bool) {
        return _exists(_ownerBadgeId);
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

    function setFriendBadge(address _friendBadge) external onlyOwner {
        friendBadge = IFriendBadge(_friendBadge);
    }

    modifier onlyOwnerBadge(
        uint256 _ownerBadgeId
    ) {
        require(msg.sender == ownerOf(_ownerBadgeId), "FriendBadge: Only owner badge owner can call this function");
        _;
    }

}
