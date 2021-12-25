// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTContract is ERC721Enumerable, Ownable {
    using Strings for uint256;
    uint16 public maxSupply = 500;
    uint8 public maxMintAmount = 20;
    uint8 private airdropCounter; 
    uint8 public presaleMintLimit = 5;
    bool public presaleActive = true;
    bool private paused = false;
    string private baseUri = "sample_base_uri/";
    address[] public presaleUsers; 
    uint256[] private airdropIds;
    
    mapping(address=>bool) public airdropUsers;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
      mint(msg.sender, 10);
    }

    function mint(address _recipient, uint256 _amount) public {
      require(!paused);
      require(_amount>0 && _amount<=maxMintAmount);
      uint256 supply = totalSupply();
      require(supply + _amount <= maxSupply);
      if(msg.sender != owner() && presaleActive) {
        require(_isPresaleUser(msg.sender));
        require(balanceOf(msg.sender) + _amount <= presaleMintLimit);
      }
      for (uint256 i = 1; i <= _amount; i++) {
        _safeMint(_recipient, supply + i);
      }
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
    function addAirDrops(uint256[] calldata _dropIds) external onlyOwner {
      uint256 index = airdropIds.length;
      for(uint i=0; i<_dropIds.length; i++) {
        airdropIds[index] = _dropIds[i];
        index++;
        transferFrom(msg.sender, address(this), _dropIds[i]);
      }
    }
    function addAirdropUsers(address[] calldata _users) external onlyOwner{
      for(uint i=0; i<_users.length; i++) {
        airdropUsers[_users[i]] = true;
      }
    }
    function removeAirdropUsers(address[] calldata _users) external onlyOwner {
      for(uint i=0; i<_users.length; i++) {
        airdropUsers[_users[i]] = false;
      }
    }
    function claimDrop() external {
      require(!paused);
      require(airdropUsers[msg.sender]);
      airdropUsers[msg.sender] = false;
      transferFrom(address(this), msg.sender, airdropIds[airdropCounter]);
      airdropCounter++;
    }
    function _isPresaleUser(address _user) private view returns (bool) {
      for(uint256 i=0; i<presaleUsers.length; i++){
        if(presaleUsers[i] == _user) return true;
      }
      return false;
    }
    function setMaxMintAmount(uint8 _newMax) external onlyOwner {
      maxMintAmount = _newMax;
    }
    function setPresaleUsers(address[] calldata _users) external onlyOwner {
      delete presaleUsers;
      presaleUsers = _users; 
    }
    function setPresaleMintLimit(uint8 _newLimit) external onlyOwner {
      presaleMintLimit = _newLimit;
    }
    function endPresale() external onlyOwner {
      require(presaleActive, "Presale already ended");
      presaleActive = false;
    }
}