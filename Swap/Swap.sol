// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SimpleSwap {
    
    address public owner;
    
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 tokenABalance;
    uint256 tokenBBalance;

    event SwapInitialized(address indexed contractAddress, uint256 tokenAAmount, uint256 tokenBAmount);

    constructor (address tokenA_, address tokenB_, uint256 tokenAAmount_, uint256 tokenBAmount_) {

        owner = msg.sender;
        tokenA = IERC20(tokenA_);
        tokenB = IERC20(tokenB_);

        uint256 _tokenABalance = tokenA.balanceOf(msg.sender);
        uint256 _tokenBBalance = tokenB.balanceOf(msg.sender);

        require(_tokenABalance >= tokenAAmount_, "Insufficient balance of Token A");
        require(_tokenBBalance >= tokenBAmount_, "Insufficient balance of Token B");

        require(tokenA.transferFrom(msg.sender, address(this), tokenAAmount_), "Failed to transfer Token A");
        require(tokenB.transferFrom(msg.sender, address(this), tokenBAmount_), "Failed to transfer Token B");

        tokenABalance = tokenAAmount_;
        tokenBBalance = tokenBAmount_;

        emit SwapInitialized(address(this), tokenAAmount_, tokenBAmount_);
    }
}