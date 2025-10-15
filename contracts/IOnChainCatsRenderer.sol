// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IOnChainCatsRenderer {
    function tokenURI(uint256 tokenId, uint256 seed) external view returns (string memory);
    function attributesJSON(uint256 tokenId, uint256 seed) external view returns (string memory);
    function image(uint256 tokenId, uint256 seed) external view returns (string memory); // raw SVG
}
