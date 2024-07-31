// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MyERC20Token is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private _decimals;

    constructor (
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address initialOwner
    ) Ownable( initialOwner) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        // _totalSupply = totalSupply_;
        _mint(initialOwner, totalSupply_);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Sender cannot be the zero address");
        require(to != address(0), "Receiver cannot be the zero address");
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            require(fromBalance >= value, "Insufficient balance");
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            _totalSupply -= value;
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal virtual {
        _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal {
        require(owner != address(0), "Sender cannot be the zero address");
        require(spender != address(0), "Receiver cannot be the zero address");
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= value, "Insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - value, false);
        }
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0), "Invalid receiver");
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "Invalid sender");
        _update(account, address(0), value);
    }

    function mint(address account, uint256 value) public onlyOwner {
        _mint(account, value);
    }

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function rename(string memory name_) public onlyOwner {
        _name = name_;
    }

}
