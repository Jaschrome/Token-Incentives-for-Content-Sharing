// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ContentSharingToken {
    string public name = "ContentToken";
    string public symbol = "CTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ContentShared(address indexed sharer, string contentHash, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function rewardContentSharer(address sharer, string memory contentHash, uint256 reward) public onlyOwner {
        require(balanceOf[owner] >= reward, "Insufficient contract balance");
        balanceOf[owner] -= reward;
        balanceOf[sharer] += reward;
        emit ContentShared(sharer, contentHash, reward);
        emit Transfer(owner, sharer, reward);
    }

    function mint(uint256 amount) public onlyOwner {
        totalSupply += amount * 10 ** uint256(decimals);
        balanceOf[owner] += amount * 10 ** uint256(decimals);
        emit Transfer(address(0), owner, amount * 10 ** uint256(decimals));
    }

    function burn(uint256 amount) public onlyOwner {
        require(balanceOf[owner] >= amount * 10 ** uint256(decimals), "Insufficient balance to burn");
        totalSupply -= amount * 10 ** uint256(decimals);
        balanceOf[owner] -= amount * 10 ** uint256(decimals);
        emit Transfer(owner, address(0), amount * 10 ** uint256(decimals));
    }
}
