pragma solidity 0.8.0;

import "./ERC1155.sol";


contract PROXFactory is ERC1155 {

    constructor(string memory _Url, string) ERC1155(_Url) public {
        owner=msg.sender;
        address2state[msg.sender]=true;
    }

    // declare our event here

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    address contract_address;
    address owner;
    bool set_state=false;
    uint fee=10;
    
    struct PRX {
        string name;
        uint dna;
        uint attCode;
    }
    PRX[] public PROXs;
    
    struct partner{
        string name;
        string ID;
        address partner_address;
    }
    
    partner[] public partners;
    
    mapping (address => mapping( string => bool)) created_name;
    mapping (address => bool) address2state;
    mapping (uint => uint) PRXID2price;
    mapping (address => uint) balance;

    
    function setup_address(address _contract_address) public {
        require(set_state==false,"El contrato ya fue configurado");
        require(msg.sender==owner, "debes ser el owner");
        contract_address=_contract_address;
        set_state=true;
    }
    function set_fee(uint _new_fee) public{
        require(msg.sender==owner, "debes ser el owner");
        fee=_new_fee;
    }
    
    function add_balance(uint _amount, address _reciever) public {
        require(msg.sender==owner, "debes ser el owner");
        require(_amount>=0,"la cantidad debe ser positiva");
        balance[_reciever]+=_amount;
    }

    function add_partner_owner(string memory _name, string memory _ID, address _partner_address) public {
        require(msg.sender==owner, "debes ser el owner");
        partners.push(partner(_name, _ID, _partner_address));
        address2state[msg.sender]=true;
    }
    // function partner_register( string memory _name, string memory _ID) public{
    //     partners.push(partner(_name, _ID, msg.sender));
    //     address2state[msg.sender]=true;
    // }

    function _createPRX(string memory _name, uint _dna, uint _attCode, uint _price) private {
        uint _id=PROXs.push(PRX(_name, _dna,_attCode));
        PRXID2price[_id]=_price;
        // and fire it here
        created_name[msg.sender][_name]=true;
        _mint(contract_address, _id);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)))+uint(keccak256(abi.encodePacked(msg.sender)))+uint(keccak256(abi.encodePacked(block.difficulty, now)));
        return rand % dnaModulus;
    }

    function createUniquePRX(string memory _name, uint _attCode, uint _price) public {
        require(_price>=0,"el precio debe ser positivo");
        require(set_state==false,"El contrato ya fue configurado");
        require(created_name[msg.sender][_name]==false, "You cannot create the same repeated name with the same address");
        require(address2state[msg.sender]==true,"debes estar registrarte como partner");
        uint randDna = _generateRandomDna(_name);
        _createPRX(_name, randDna, _attCode, _price);
    }
    function buy_NFT(uint _NFTid) public {
        require(PRXID2price[_NFTid]<=balance[msg.sender]);
        transferFrom( contract_address,  msg.sender, _NFTid);
    }
}