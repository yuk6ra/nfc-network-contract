// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OwnerGoods is ERC721, Ownable, ReentrancyGuard{

    struct GoodsManagement {
        uint256 totalSupply;
        uint256 maxSupply;
        uint256 goodsPrice;
        address tokenAddress;
    }

    uint256 public totalSupply;
    bytes32[] public codes;
    bool public isActive;

    /// @dev your address => code
    // mapping (address => bytes32) public codes;

    // @dev your address => goods number
    mapping (address => uint256) public goodsNumber;

    mapping (uint256 => GoodsManagement) public goodsManagements;

    mapping (address => bool) public isAllowedERC20Token;

    constructor() ERC721("NFC Distribution", "NFC") {}

    function ownerGoods(
        bytes32 _serialNumber
    ) external payable nonReentrant {
        require(isActive, "OwnerGoods: Allowlist sale is not active");
        require(_check(_serialNumber), "OwnerGoods: Serial number is not valid");

        // require(MerkleProof.verify(_merkleProof, merkleRoot,  keccak256(abi.encodePacked(msg.sender))), "EternalMass: Invalid Merkle Proof");
        _safeMint(msg.sender, totalSupply++);
        goodsNumber[msg.sender]++;
    }

    function setGoodsManagement(
        uint256 tokenId,
        uint256 _totalSupply,
        uint256 _maxSupply,
        uint256 _goodsPrice,
        address _tokenAddress
    ) external onlyOwnerOf(tokenId) {
        goodsManagements[tokenId] = GoodsManagement(_totalSupply, _maxSupply, _goodsPrice, _tokenAddress);
    }

    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "OwnerGoods: caller is not the owner");
        _;
    }

    function GoodsManagementExist(uint256 _tokenId) public view returns (bool) {
        return goodsManagements[_tokenId].totalSupply > 0;
    }

    function _check(bytes32 _serialNumber) internal view returns (bool) {
        /// @dev check serial number
        return true;
    }

    function setCode(bytes32[] calldata _codes) external onlyOwner {
        codes = _codes;
    }
    
    function setIsActive(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function setERC20Token(address _tokenAddress, bool _isAllowed) external onlyOwner {
        isAllowedERC20Token[_tokenAddress] = _isAllowed;
    }

    function getERC20Token(address _tokenAddress) external view returns (bool) {
        return isAllowedERC20Token[_tokenAddress];
    }
}