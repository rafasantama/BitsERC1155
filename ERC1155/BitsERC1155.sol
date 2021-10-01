pragma solidity 0.8.0;

import "./ERC1155.sol";


contract BITSFactory is ERC1155 {

    constructor(string memory _uri, bytes memory _data, uint _native_token_supply) ERC1155(_uri) public {
        owner=msg.sender;
        address2state[msg.sender]=true;
        _mint(owner, 0, _native_token_supply, _data);
    }

    // declare our event here

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    address contract_address;
    address owner;
    bool set_state=false;
    uint fee=10;
    uint id=0;
    
    struct BIT {
        string name;
        bytes data;
    }
    BIT[] public BITS;
    
    struct publisher{
        string name;
        string ID;
        address partner_address;
    }
    
    publisher[] public publishers;
    
    mapping (address => mapping( string => bool)) created_name;
    mapping (address => bool) address2state;
    mapping (uint => uint) BITSID2price;
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

    function add_publisher_owner(string memory _name, string memory _ID, address _partner_address) public {
        require(msg.sender==owner, "debes ser el owner");
        publishers.push(publisher(_name, _ID, _partner_address));
        address2state[_partner_address]=true;
    }
    // function partner_register( string memory _name, string memory _ID) public{
    //     partners.push(partner(_name, _ID, msg.sender));
    //     address2state[msg.sender]=true;
    // }

    function _createBITS(string memory _name, bytes memory _data, uint _price) private {
        id++;
        BITS.push(BIT(_name,_data));
        BITSID2price[id]=_price;
        // and fire it here
        created_name[msg.sender][_name]=true;
        _mint(contract_address, id, 1, _data);
    }

    //function _generateRandomDna(string memory _str) private view returns (uint) {
    //    uint rand = uint(keccak256(abi.encodePacked(_str)))+uint(keccak256(abi.encodePacked(msg.sender)))+uint(keccak256(abi.encodePacked(block.difficulty, now)));
    //    return rand % dnaModulus;
    //}

    function createUniqueBITS(string memory _name, bytes memory _data, uint _price) public {
        require(_price>=0,"el precio debe ser positivo");
        require(set_state==true,"El contrato debe estar configurado");
        require(created_name[msg.sender][_name]==false, "You cannot create the same repeated name with the same address");
        require(address2state[msg.sender]==true,"debes estar registrarte como partner");
        //uint randDna = _generateRandomDna(_name);
        _createBITS(_name, _data, _price);
    }
    function buy_NFT(uint _NFTid, bytes memory _data) public {
        require(BITSID2price[_NFTid]<=balanceOf(msg.sender,0));
        safeTransferFrom(contract_address,  msg.sender, _NFTid, 1 , _data);
        safeTransferFrom(msg.sender,  msg.sender, 0, BITSID2price[_NFTid], _data);
    }
}