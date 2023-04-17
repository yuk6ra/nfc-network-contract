// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFCDistribution is ERC721, Ownable, ReentrancyGuard{

    bytes32[] public code;

    uint256 public totalSupply;

    string public metadataURI;

    // @dev your address => goods number
    mapping (address => uint256) public goodsNumber;

    constructor(
        string memory _metadataURI
    ) ERC721("NFC Distribution", "NFC") {
        metadataURI = _metadataURI;
    }

    function frendGoods(
        bytes32 _code
    ) external payable nonReentrant {
        /// @dev check ERC20 token
        // require();
        // require(_check(_code), "OwnerGoods: Serial number is not valid");
        _safeMint(msg.sender, totalSupply++);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "Nonexistent token");
        return string(abi.encodePacked(metadataURI, tokenId, ".json"));
    }

    // function setCode(bytes32[] _code) external onlyOwner {        
    // }

}