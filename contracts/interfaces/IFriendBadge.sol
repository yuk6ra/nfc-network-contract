
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IFriendBadge is IERC721{
    function getTotalSupplyOfFriendBadge(
        uint256 _ownerBadgeId
    ) external view returns (uint256);
}