// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721Full, ERC721Mintable {
    constructor() public ERC721Full("MyNFT", "MNFT") {}
}
