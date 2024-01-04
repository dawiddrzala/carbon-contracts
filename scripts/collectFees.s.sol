// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import "forge-std/console2.sol";
import {ICarbonController} from "../contracts/carbon/interfaces/ICarbonController.sol";

contract ClaimFees is Script {
    address private constant BASECONTROLLER = 0xfbF069Dbbf453C1ab23042083CFa980B3a672BbA;
    address private constant FTMCONTROLLER = 0xf37102e11E06276ac9D393277BD7b63b3393b361;
    address private constant MANTLECONTROLLER = 0x7900f766F06e361FDDB4FdeBac5b138c4EEd8d4A;
    address private constant CANTOCONTROLLER = 0xE6b17973eE994C2EC7E69Aa3e1A612aF16253da1;
    address private constant ARB1CONTROLLER = 0x6bD85183abBF0990955cFce1cf0674D1d6c30E05;

    //BASE TOKENS
    address private constant bWETH = 0x4200000000000000000000000000000000000006;
    address private constant USDbC = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA;
    address private constant cbETH = 0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22;
    address private constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address private constant wBLT = 0x4E74D4Db6c0726ccded4656d0BCE448876BB4C7A;
    address private constant DAI = 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb;

    mapping(uint256 => address) baseTokens;

    function run() external {
        uint256 pKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pKey);

        claimBase();


        vm.stopBroadcast();
    }

    function claimBase() internal {
        buildBaseTokens();
        for(uint i=0;i<baseTokens.length;i++) {
        uint256 temp = ICarbonController(BASECONTROLLER).accumulatedFees(baseTokens);
        console2.log(baseTokens, "has", temp);
    }

    function buildBaseTokens() internal {
        baseTokens[1] = bWETH;
        baseTokens[2] = USDbC;
        baseTokens[3] = cbETH;
        baseTokens[4] = USDC;
        baseTokens[5] = wBLT;
        baseTokens[6] = DAI;
    }

}