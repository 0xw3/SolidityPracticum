// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./MyERC20Token.sol";

contract TokenHi is MyERC20Token {
    constructor (
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address initialOwner
    ) MyERC20Token(name_, symbol_, decimals_, totalSupply_, initialOwner) {
    }
}