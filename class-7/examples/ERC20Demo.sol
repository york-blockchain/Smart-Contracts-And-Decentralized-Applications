// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

interface IERC20 {
    // optional
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    
    // mandatory
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function transfer(address recipient, uint256 amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);
    function approve(address spender, uint256 amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 remaining);
    
    // events
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

contract StandardERC20 is IERC20 {
    
    uint256 public _totalSupply; 
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    
    mapping(address => uint256) public _balances;
    
    mapping(address => mapping(address => uint)) public _allowances;
    
    constructor(string memory _name_, uint8 _decimals_, string memory _symbol_, uint256 _totalSupply_) {
        _name = _name_;
        _symbol = _symbol_;
        _decimals = _decimals_;
        _totalSupply = _totalSupply_;
        _balances[msg.sender]  += _totalSupply_;
    }
    
    function name() public view override returns (string memory) {
        return _name;    
    }
    
    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address _account) public view override returns (uint256) {
        return _balances[_account];
    }
    
    function transfer(address _receipient, uint256 _amount) public override returns (bool) {
        _transfer(msg.sender, _receipient, _amount);
        return true;
    }
    
    function approve(address _spender, uint256 _amount) public override returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return _allowances[_owner][_spender];
    }
    
    function transferFrom(address _owner, address _recipient, uint256 _amount) public override returns (bool) {
        _transfer(_owner, _recipient, _amount);
        _approve(_owner, msg.sender, _allowances[_owner][msg.sender] - _amount);
        return true;
    }
    
    function _approve(address _owner,address _spender, uint256 _amount) internal {
        require(_spender != address(0),"ERC20: approve to zero address");
        require(_owner != address(0),"ERC20: approve from zero address");
        require(_balances[_owner] >= _amount,"ERC20: sender does not have enough balance");
        
        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }
    
    function _transfer(address _owner, address _recipient, uint256 _amount) internal {
        require(_owner != address(0),"ERC20: transfer from zero address");
        require(_recipient != address(0),"ERC20: transfer from zero address");
        require(_balances[_owner] >= _amount,"ERC20: sender does not have enough balance");
        _balances[_owner] -= _amount;
        _balances[_recipient] += _amount;
        emit Transfer(_owner, _recipient, _amount);
    }
}

contract TokenSale {
    
    IERC20 public tokenContract;
    uint256 public price;
    uint256 public tokensSold;
    
    event Sold(address indexed buyer, uint256 amount);
    
    address public owner;
    
    constructor(IERC20 _tokenContract, uint256 _price) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
    }
    
    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == _numberOfTokens * price);
        
        uint256 _scaledAmount = _numberOfTokens * (10**tokenContract.decimals());
        
        require(tokenContract.balanceOf(address(this)) >= _scaledAmount);
        require(tokenContract.transfer(msg.sender, _scaledAmount));
        tokensSold += _scaledAmount;
        emit Sold(msg.sender, _scaledAmount);
    }
    
    function endSale() public {
        require(msg.sender == owner,"restricted access");
        uint256 _amount = tokenContract.balanceOf(address(this));
        
        // Sending unsold tokens to the owner
        require(tokenContract.transfer(msg.sender, _amount));
        
        // destroy , send the balance of ether from this contract
        selfdestruct(payable(owner));
    }
    
}

contract TokenFaucet is StandardERC20{
    
    uint256 public drop;
    
    constructor(
        string memory _name_, 
        uint8 _decimals_, 
        string memory _symbol_, 
        uint256 _totalSupply_) StandardERC20(_name_,_decimals_,_symbol_,_totalSupply_) {
            drop = 10 ** decimals();
        }
        
    function _mint(address _toAccount, uint256 _amount) internal returns(bool) {
        _balances[_toAccount] += _amount;
        _totalSupply += _amount;
        emit Transfer(address(0),_toAccount, _amount);
        return false;
    }
        
    fallback() external payable {
        _mint(msg.sender, drop);
        if(msg.value > 0) {
            msg.sender.transfer(msg.value);
        }    
    }
        
    receive() external payable {}
}