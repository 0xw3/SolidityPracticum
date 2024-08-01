// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleSwap {
    
    address public owner;
    
    IERC20 public tokenA;
    IERC20 public tokenB;

    bool public isInitialized;

    event SwapInitialized(address indexed contractSwap, uint256 tokenAAmount, uint256 tokenBAmount);
    event Swap(address indexed contractSwap, address indexed sender, address indexed tokenLeft, uint256 amount);

    constructor (address tokenA_, address tokenB_) {
        owner = msg.sender;
        tokenA = IERC20(tokenA_);
        tokenB = IERC20(tokenB_);
    }


    /**
    * @dev Before initialize, approve tokenA and tokenB for Swap contract address
    */
    function initialize(uint256 tokenAAmount_, uint256 tokenBAmount_) external {

        require(msg.sender == owner, "Only owner can initialize");
        require(tokenAAmount_ == tokenBAmount_, "The balances must be equal");
        require(!isInitialized, "Already initialized");

        uint256 tokenABalance = tokenA.balanceOf(msg.sender);
        uint256 tokenBBalance = tokenB.balanceOf(msg.sender);

        require(tokenABalance >= tokenAAmount_, "Insufficient balance of Token A");
        require(tokenBBalance >= tokenBAmount_, "Insufficient balance of Token B");

        require(tokenA.transferFrom(msg.sender, address(this), tokenAAmount_), "Failed to transfer Token A");
        require(tokenB.transferFrom(msg.sender, address(this), tokenBAmount_), "Failed to transfer Token B");

        isInitialized = true;

        emit SwapInitialized(address(this), tokenAAmount_, tokenBAmount_);
    }

    /**
    * @dev 
    * For simplification, we assume that
    * 1. Exchange rate 1 to 1
    * 2. Decimal of both tokens are equal
    */
    function swap(IERC20 tokenLeft, uint256 amount) public {
        IERC20 tokenRight = tokenLeft == tokenA ? tokenB : tokenA;
        require(isInitialized,"Contract not initialized");
        require(tokenLeft.balanceOf(msg.sender) >= amount,"You don't have enough balance");
        require(tokenRight.balanceOf(address(this)) >= amount,"The swap contract doesn't have enough balance");
        require(
            tokenLeft.transferFrom(msg.sender, address(this), amount)
            && tokenRight.transfer(msg.sender, amount)
            , "Something is wrong"
        );
        emit Swap(address(this), msg.sender, address(tokenLeft), amount);
    }
}