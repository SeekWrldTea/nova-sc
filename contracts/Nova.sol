// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Nova is ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;
  
  string internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  mapping(address => bool) public controllers;
  mapping(uint256 => string) public descriptions;
  mapping(uint256 => bool) public described;

  Counters.Counter private _tokenIdCounter;


  constructor() ERC721("Nova", "NOVA") payable {
    controllers[msg.sender] = true;
  }

  function safeMint(address _to) public returns (uint256) {
    require(controllers[msg.sender], "Only controller can mint");
    _tokenIdCounter.increment();
    uint256 tokenId = _tokenIdCounter.current();
    _safeMint(_to, tokenId);
    return tokenId;
  }
  
  function burn(uint256 tokenId) public {
    require(ownerOf(tokenId) == msg.sender, "Only the owner of the token can burn it.");
    super._burn(tokenId);
  }

  function setController(address _controller, bool value) public onlyOwner{
    controllers[_controller] = value;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {

    string memory metadata = string(
        abi.encodePacked(
          '{',
          '"name": "Nova Token",',
          '"description": "',
          "An NFT Token by Nova",
          '",',
          '"external_url": "",',// URL TO ADD
          '"image": "",', // IMAGE TO ADD
          '"attributes":',
          "[",
          '{"trait_type":"Rate",',
          '"value": ""}',// Add income return rate
          "]"
          '}'
        )
      );
      return
        string(
          abi.encodePacked(
            "data:application/json;base64,",
            base64(bytes(metadata))
          )
      );
  }

  function base64(bytes memory data) internal pure returns (string memory) {
    if (data.length == 0) return "";

    // load the table into memory
    string memory table = TABLE;

    // multiply by 4/3 rounded up
    uint256 encodedLen = 4 * ((data.length + 2) / 3);

    // add some extra buffer at the end required for the writing
    string memory result = new string(encodedLen + 32);

    assembly {
        // set the actual output length
        mstore(result, encodedLen)

        // prepare the lookup table
        let tablePtr := add(table, 1)

        // input ptr
        let dataPtr := data
        let endPtr := add(dataPtr, mload(data))

        // result ptr, jump over length
        let resultPtr := add(result, 32)

        // run over the input, 3 bytes at a time
        for {

        } lt(dataPtr, endPtr) {

        } {
            dataPtr := add(dataPtr, 3)

            // read 3 bytes
            let input := mload(dataPtr)

            // write 4 characters
            mstore(
                resultPtr,
                shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
            )
            resultPtr := add(resultPtr, 1)
            mstore(
                resultPtr,
                shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
            )
            resultPtr := add(resultPtr, 1)
            mstore(
                resultPtr,
                shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
            )
            resultPtr := add(resultPtr, 1)
            mstore(
                resultPtr,
                shl(248, mload(add(tablePtr, and(input, 0x3F))))
            )
            resultPtr := add(resultPtr, 1)
        }

        // padding with '='
        switch mod(mload(data), 3)
        case 1 {
            mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
        }
        case 2 {
            mstore(sub(resultPtr, 1), shl(248, 0x3d))
        }
    }

    return result;
  }
}