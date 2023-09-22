// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import { CarbonController } from "../carbon/CarbonController.sol";
import { IVoucher } from "../voucher/interfaces/IVoucher.sol";
import { Token } from "../token/Token.sol";

contract TestCarbonController is CarbonController {
    constructor(
        IVoucher initVoucher,
        address payable initTank,
        address proxy
    ) CarbonController(initVoucher, initTank, proxy) {}

    function version() public pure virtual override returns (uint16) {
        return 2;
    }

    receive() external payable {}
}
