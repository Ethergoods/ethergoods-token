pragma solidity ^0.4.24;

import "./ERC721Token.sol";





contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract EtherGoodsToken is ERC721Token {

  using SafeMath for uint256;

  //goodtypeid => ipfs hash
  mapping(uint256 => GoodType) public goodTypes;
  uint256 public nextGoodTypeId;

  //goodtypeid => cost
  mapping(uint256 => GoodTypeCost) public goodTypeCosts;

  //721 token id  => goodtype data
  mapping(uint256 => GoodOwnership) public goodIndex;

  //for IPFS, future-proof format
  //https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes
 struct Multihash {
  bytes32 hashHex;   //convert the base 58 string representation to hex
  uint8 hashFunction;
  uint8 hashSize;
}

struct GoodType {
   
    uint256 typeId;
    Multihash ipfsHash;
    address owner;
    uint32 totalSupply;
    uint32 nextTypeTokenIndex;

}

struct GoodTypeCost {

     address tokenAddress;
     uint256 tokenAmount;

}

struct GoodOwnership {

    uint256 typeId;
    address owner;
    uint32 typeTokenIndex;

}

  event DefineType(address indexed from, uint256 typeId, uint256 totalSupply);

  event DefineCost(address indexed from, uint256 typeId, address tokenAddress, uint256 tokenAmount );

  event Mint(address indexed from, uint256 goodTypeId, uint32 typeTokenindex, uint256 tokenId);



  /**
   * @dev Constructor function
   */
  constructor(string _name, string _symbol) public {
    name_ = _name;
    symbol_ = _symbol;

    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721Enumerable);
    _registerInterface(InterfaceId_ERC721Metadata);
  }

  /**
   * Mint an instance of an EtherGood based on the type
   * Reverts if there are not enough supply left to mint
   */
  function defineType(bytes32 hashHex,uint8 hashFunction, uint8 hashSize, uint32 totalSupply) public returns (uint256 success)
  {
    require( goodTypes[nextGoodTypeId].typeId == 0x0 );


    //TODO : MAKE SURE NOBODY HAS SUBMITTED THIS IPFS HASH BEFORE



    uint256 typeId = nextGoodTypeId;

    goodTypes[typeId].typeId = typeId;
    goodTypes[typeId].ipfsHash.hashHex = hashHex;
    goodTypes[typeId].ipfsHash.hashFunction = hashFunction;
    goodTypes[typeId].ipfsHash.hashSize = hashSize;
    goodTypes[typeId].owner = msg.sender;
    goodTypes[typeId].totalSupply = totalSupply;

    DefineType(msg.sender, typeId, totalSupply ); // define this

    nextGoodTypeId = nextGoodTypeId.add(1);

    return typeId ;
  }

  function setMintCost(uint256 typeId, address tokenAddress, uint256 tokenAmount) public
  {
    require(msg.sender == goodTypes[typeId].owner);

    goodTypeCosts[typeId].tokenAddress = tokenAddress;
    goodTypeCosts[typeId].tokenAmount = tokenAmount;

    DefineCost(msg.sender, typeId, tokenAddress, tokenAmount ); // define this
  }

  function transferTypeOwnership(address newOwner, uint256 typeId) public
  {
    require(msg.sender == goodTypes[typeId].owner);
    goodTypes[typeId].owner = newOwner;
  }



  /**
   * Mint an instance of an EtherGood based on the type
   * Reverts if there are not enough supply left to mint
   */
  function mintInstance(uint256 typeId, address minter ) public
  {
    //pay the tokens to the owner, requires a good type cost to be defined
    require( goodTypeCosts[typeId].tokenAddress != 0x0 );
    require( ERC20Interface( goodTypeCosts[typeId].tokenAddress ).transferFrom( minter, goodTypes[typeId].owner, goodTypeCosts[typeId].tokenAmount   ) );

    uint32 nextTypeTokenIndex = goodTypes[typeId].nextTypeTokenIndex;
    goodTypes[typeId].nextTypeTokenIndex = goodTypes[typeId].nextTypeTokenIndex + 1 ;

    require( goodTypes[typeId].nextTypeTokenIndex > nextTypeTokenIndex ); //makes it safe
    require( goodTypes[typeId].nextTypeTokenIndex < goodTypes[typeId].totalSupply );

    bytes32 tokenHash = keccak256( typeId, nextTypeTokenIndex );
    uint256 tokenId = uint256(tokenHash);

    goodIndex[tokenId].owner = minter;
    goodIndex[tokenId].typeId = typeId;
    goodIndex[tokenId].typeTokenIndex = nextTypeTokenIndex;

    _mint(minter, tokenId);


    bytes memory metadata = new bytes(typeId);
    _setTokenURI(tokenId, string(metadata) );
    //set metadata

    Mint(minter, typeId, nextTypeTokenIndex, tokenId);
  }



}
