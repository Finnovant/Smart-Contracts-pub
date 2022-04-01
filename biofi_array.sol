// SPDX-License-Identifier: none
pragma solidity 0.8.11;

//ERC Token Standard #20 Interface

abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint remaining);
    function transfer(address to, uint tokens) public virtual returns (bool success);
    function approve(address spender, uint tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

abstract contract ERC20Burnable {
    function burn(uint256 tokens) public virtual returns (bool);
    function burnFrom(address account, uint256 tokens) public virtual returns (bool);
}

abstract contract ERC20Mintable {
    function mint(address account, uint256 amount) external virtual returns (bool);
}

//Actual token contract

contract BiofiTok is ERC20Interface, ERC20Burnable, ERC20Mintable {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    address owner;
    bool isPaused;
    uint256 private guardCounter;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    event Burn(address indexed tokenOwner, uint tokens);

    constructor() {
        //we willl change the next two lines for actual ICO launch.  The name & symbol are for test purposes only
        symbol = "BioFiTest";
        name = "BioFi Test for Audit";
        //ten billion tokens, dividable to 0.000001
        decimals = 6;
        _totalSupply = 10000000000000000;
        owner = msg.sender;
        balances[msg.sender] = _totalSupply;
        isPaused = false;
        guardCounter = 1;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * Calling a `nonReentrant` function from another `nonReentrant`
    * function is not supported. It is possible to prevent this from happening
    * by making the `nonReentrant` function external, and make it call a
    * `private` function that does the actual work.
    */
    modifier nonReentrant() {
        guardCounter += 1;
        uint256 localCounter = guardCounter;
        _;
        require(localCounter == guardCounter);
    }

    function totalSupply() public override view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

     function mint(address _to, uint256 tokens) external override returns (bool) {
         require(msg.sender == owner, "Not the owner...");
         require(tokens < _totalSupply, "Too many tokens to mint at once");
         _totalSupply = _totalSupply + tokens;
         balances[_to] = balances[_to] + tokens;
         return true;
     }

    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        require(!isPaused, "Paused");
        require(tokens < _totalSupply, "Too many tokens");
        balances[msg.sender] = balances[msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    //We are aware of ERC20 API: An Attack Vector on Approve/TransferFrom Methods
    //As this requires a person to change the number of tokens, this does not app
    function approve(address spender, uint tokens) public override returns (bool success) {
        require(!isPaused, "Paused");
        require(tokens < _totalSupply, "Too many tokens");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        require(!isPaused, "Paused");
        require(tokens < _totalSupply, "Too many tokens");
        balances[from] = balances[from] - tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    //This is a Burn function, compliant with the ERC20Burnable interface definition
    function burn(uint256 tokens) public override returns (bool) {
        require(!isPaused, "Paused");
        require(msg.sender == owner, "Not the owner...");
        require(tokens < _totalSupply, "Too many tokens to mint at once");
        _totalSupply = _totalSupply - tokens;
        balances[owner] = balances[owner] - tokens;
        //Emitting the Burn event is not part of the ERC2Burnable standard
        emit Burn(owner, tokens);
        return true;
    }

    //we provide a burnFrom function that is guaranteed to fail so that we are compliant with the ERC20Burnable interface
    function burnFrom(address account, uint256 tokens) public override virtual returns (bool) {
        require(!isPaused, "Paused");  //we want this check in every function without a view signature, that isn't part of ERD20Pausable
        require(false, "Only the owner can burn by calling the burn function itself");
        //control will never reach this point
        //following two lines silence warnings about account and tokens no being used
        require(account == owner, "Not the Account Owner");
        require(tokens == 0, "Nonzero token amount");
        return false;
    }

    // ****** transferArray function ***********//
    //This function let's us do airdrops with less gas, since gas usage is driven primarily
    //by writing to storage.  We can reduce that by almos 2x by reducing the owner's balance
    //just once instead of once per aidrop recipient

    //re-entrancy from another contract not possible because call must come from owner
    //also not calling another contract
    //also have implemented the nonReentrant mutex

    function transferArray(address [] memory addresses, uint tokens) external nonReentrant returns (bool success) {
        require(!isPaused, "Paused");
        require(msg.sender == owner, "Not the owner...");
        require(tokens * addresses.length < _totalSupply, "Too many tokens");
        uint count = addresses.length;
        require(count <= 100, "Too many addresses, must be <= 100");
        balances[msg.sender] = balances[msg.sender] - count * tokens;
        for(uint i = 0; i < count; i++) {
            address to = addresses[i];
            balances[to] = balances[to] + tokens;
            emit Transfer(msg.sender, to, tokens);
        }
        return true;
    }
}
