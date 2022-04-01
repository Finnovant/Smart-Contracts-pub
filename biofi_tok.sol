// SPDX-License-Identifier: none
pragma solidity 0.8.11;

import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract BiofiTok is ERC20PresetMinterPauser {

    //adjust name and symbol for actual deployment values
    constructor() ERC20PresetMinterPauser("BioFi Test for Audit", "BioFiTest")  {
        uint256 initialSupply = 10 * 1000 * 1000 * 1000;   //10 billion tokens
        initialSupply *= 1000 * 1000;                     //decimalize to 10**6
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

}
