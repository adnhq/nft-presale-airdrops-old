// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PasswordPresale is ERC721Enumerable {
    using Strings for uint256;
    uint256 public cost = 0.05 ether; 
    uint256 public reserve = 77;
    bytes32 private _presaleHash = 0xb7845733ba102a68c6eb21c3cd2feafafd1130de581d7e73be60b76d775b6704; //Sample hash
    address private _owner; 
    uint8 public maxMintAmount = 10;
    uint8 public presaleMintLimit = 5;
    uint16 public maxSupply = 7777;
    bool public presaleActive = true;
    bool public paused = false;
    string private baseUri = "sample_base_uri/"; 

    constructor() ERC721("Demo Token", "DMO") {
      _owner = msg.sender;
    }
    modifier onlyOwner {
      require(msg.sender == _owner);
      _;
    } 
    function mint(address _recipient, uint256 _amount, string memory _password) external payable {
      require(!paused);
      require(_amount>0);
      if(msg.sender != _owner) require(msg.value >= cost * _amount);
      if(presaleActive && msg.sender != _owner) {
        require(balanceOf(msg.sender) + _amount <= presaleMintLimit);
        require(_presaleHash == keccak256(abi.encodePacked(_password)));
      }else {
        require(balanceOf(msg.sender) + _amount <= maxMintAmount);
      }
      uint256 supply = totalSupply();
      require(supply + _amount <= maxSupply - reserve);
      for (uint256 i = 1; i <= _amount; i++) {
        _safeMint(_recipient, supply + i);
      }
    }
    function mintReserveTokens(uint256 _amount) external onlyOwner {
        //Mint the tokens reserved for the owner
        require(_amount <= reserve);
        reserve -= _amount;
        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, totalSupply());
        }
    }
    function setReserve(uint256 _amount) external onlyOwner {
        require(totalSupply() + _amount <= maxSupply);
        reserve = _amount;
    }
    function setBaseURI(string memory _newUri) external onlyOwner {
      baseUri = _newUri;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
      require( _exists(tokenId));
      return bytes(baseUri).length > 0 ? string(abi.encodePacked(baseUri, tokenId.toString(), ".json")) : "";
    }
    function togglePause() external onlyOwner {
      paused = paused ? false : true; 
    }
    function setMaxMintAmount(uint8 _newMax) external onlyOwner {
      maxMintAmount = _newMax;
    }
    function setPresaleHash(string memory _newPass) external onlyOwner {
      _presaleHash = keccak256(abi.encodePacked(_newPass));
    }
    function setPresaleMintLimit(uint8 _newLimit) external onlyOwner {
      presaleMintLimit = _newLimit;
    }
    function endPresale() external onlyOwner {
      require(presaleActive);
      presaleActive = false;
    }
    function withdraw() external onlyOwner {
      payable(_owner).transfer(address(this).balance);
    }
}
