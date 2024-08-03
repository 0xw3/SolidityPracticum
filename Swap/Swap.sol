// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IERC20Extended is IERC20 {
    function decimals() external view returns (uint8);
}


contract SimpleSwap {

    using SafeERC20 for IERC20;

    address public owner;
    
    /**
    * @dev How many tokens you can get for 1 Ether
    * For example, ETHRATE=8 means that you can get 8 tokenA or 8 tokenB for 1 Ether.
    */
    uint256 immutable public ETHRATE;

    IERC20Extended public tokenA;
    IERC20Extended public tokenB;

    bool public isInitialized;

    event SwapInitialized(address indexed contractSwap, uint256 tokenAAmount, uint256 tokenBAmount);
    event Swap(address indexed contractSwap, address indexed sender, address indexed tokenLeft, uint256 amount);
    event Buy(address indexed contractSwap, address indexed buyer, IERC20Extended indexed token, uint256 tokenAmount);
    event Sell(address indexed contractSwap, address indexed seller, IERC20Extended indexed token, uint256 tokenAmount);

    modifier onlyInitialized() {
        require(isInitialized, "Swap contract has not yet been initialized");
        _;
    }

    constructor (address tokenA_, address tokenB_, uint256 ethRate_) {
        owner = msg.sender;
        tokenA = IERC20Extended(tokenA_);
        tokenB = IERC20Extended(tokenB_);
        ETHRATE = ethRate_;
    }

    /**
    * @dev Before initialize, approve tokenA and tokenB for Swap contract address
    */
    function initialize(uint256 tokenAAmount_, uint256 tokenBAmount_) external {

        require(msg.sender == owner, "Only owner can initialize");
        require(!isInitialized, "Already initialized");

        uint256 tokenABalance = tokenA.balanceOf(msg.sender);
        uint256 tokenBBalance = tokenB.balanceOf(msg.sender);

        require(tokenABalance >= tokenAAmount_, "Insufficient balance of Token A");
        require(tokenBBalance >= tokenBAmount_, "Insufficient balance of Token B");

        SafeERC20.safeTransferFrom(IERC20(address(tokenA)), msg.sender, address(this), tokenAAmount_);
        SafeERC20.safeTransferFrom(IERC20(address(tokenB)), msg.sender, address(this), tokenBAmount_);
        // tokenA.safeTransferFrom(msg.sender, address(this), tokenAAmount_);
        // tokenB.safeTransferFrom(msg.sender, address(this), tokenBAmount_);

        isInitialized = true;

        emit SwapInitialized(address(this), tokenAAmount_, tokenBAmount_);
    }

    /**
    * @dev 
    * For simplification, we assume that
    * 1. Exchange rate 1 to 1
    * 2. Decimal of both tokens are equal
    */
    function swap(IERC20 tokenLeft, uint256 amount) public onlyInitialized {

        IERC20 tokenRight = tokenLeft == tokenA ? tokenB : tokenA;
        require(isInitialized,"Contract not initialized");
        require(tokenLeft.balanceOf(msg.sender) >= amount,"You don't have enough balance");
        require(tokenRight.balanceOf(address(this)) >= amount,"The swap contract doesn't have enough balance");

        tokenLeft.safeTransferFrom(msg.sender, address(this), amount);
        tokenRight.safeTransfer(msg.sender, amount);

        emit Swap(address(this), msg.sender, address(tokenLeft), amount);
    }

    /**
    * @dev 
    * Buy token for Ether
    */
    function buy(IERC20Extended token) payable public onlyInitialized {

        uint256 tokenBalance = token.balanceOf(address(this));
        uint8 tokenDecimals = token.decimals();
        uint256 tokenAmountForTransfer = ( msg.value * ETHRATE * 10**tokenDecimals )/(10**18);
        
        require(tokenBalance > tokenAmountForTransfer, "The swap contract doesn't have enough balance");
        SafeERC20.safeTransfer(IERC20(address(token)),msg.sender, tokenAmountForTransfer);
        emit Buy(address(this), msg.sender, token, tokenAmountForTransfer);
    }

    /**
    * @dev 
    * Sell token for Ether
    */
    function sell(IERC20Extended token, uint256 tokenAmount) payable public onlyInitialized {

        uint256 tokenBalance = token.balanceOf(msg.sender);
        uint8 tokenDecimals = token.decimals();
        uint256 etherAmount = (tokenAmount * 10**18) / (ETHRATE * 10**tokenDecimals );
        
        require(tokenBalance > tokenAmount, "You don't have enough balance");
        require(address(this).balance > etherAmount, "The swap contract doesn't have enough ether balance");

        payable(msg.sender).transfer(etherAmount);
        IERC20(token).safeTransferFrom(msg.sender, address(this), tokenAmount);
        emit Sell(address(this), msg.sender, token, tokenAmount);
    }
}