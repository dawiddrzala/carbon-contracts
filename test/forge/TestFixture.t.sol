// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";

import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { ITransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { OptimizedTransparentUpgradeableProxy } from "hardhat-deploy/solc_0.8/proxy/OptimizedTransparentUpgradeableProxy.sol";

import { Utilities } from "./Utilities.t.sol";

import { TestBNT } from "../../contracts/helpers/TestBNT.sol";
import { TestERC20Burnable } from "../../contracts/helpers/TestERC20Burnable.sol";
import { TestERC20FeeOnTransfer } from "../../contracts/helpers/TestERC20FeeOnTransfer.sol";
import { MockBancorNetworkV3 } from "../../contracts/helpers/MockBancorNetworkV3.sol";

import { TestVoucher } from "../../contracts/helpers/TestVoucher.sol";
import { CarbonVortex } from "../../contracts/vortex/CarbonVortex.sol";
import { TestCarbonController } from "../../contracts/helpers/TestCarbonController.sol";

import { IVoucher } from "../../contracts/voucher/interfaces/IVoucher.sol";
import { ICarbonController } from "../../contracts/carbon/interfaces/ICarbonController.sol";

import { Token, NATIVE_TOKEN } from "../../contracts/token/Token.sol";

/**
 * @dev Deploys tokens and system contracts
 */
contract TestFixture is Test {
    Utilities private utils;
    Token internal bnt;
    Token internal token0;
    Token internal token1;
    Token internal token2;
    Token internal nonTradeableToken;
    Token internal feeOnTransferToken;

    TestVoucher internal voucher;
    CarbonVortex internal carbonVortex;
    TestCarbonController internal carbonController;

    ProxyAdmin internal proxyAdmin;

    address payable internal admin;
    address payable internal user1;
    address payable internal user2;
    address payable internal emergencyStopper;
    address payable internal tank;
    address payable internal admin2;

    address internal constant NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 internal constant MAX_SOURCE_AMOUNT = 100_000_000 ether;

    function systemFixture() internal {
        utils = new Utilities();
        // create 4 users
        address payable[] memory users = utils.createUsers(6);
        admin = users[0];
        user1 = users[1];
        user2 = users[2];
        emergencyStopper = users[3];
        tank = users[4];
        admin2 = users[5];

        // deploy contracts from admin
        vm.startPrank(admin);

        // deploy proxy admin
        proxyAdmin = new ProxyAdmin();

        // deploy BNT
        bnt = Token.wrap(address(new TestBNT("Bancor Network Token", "BNT", 1_000_000_000 ether)));
        // deploy test tokens
        token0 = Token.wrap(address(new TestERC20Burnable("TKN", "TKN", 1_000_000_000 ether)));
        token1 = Token.wrap(address(new TestERC20Burnable("TKN1", "TKN1", 1_000_000_000 ether)));
        token2 = Token.wrap(address(new TestERC20Burnable("TKN2", "TKN2", 1_000_000_000 ether)));
        nonTradeableToken = Token.wrap(address(new TestERC20Burnable("NONTRTKN", "NONTRTKN", 1_000_000_000 ether)));
        feeOnTransferToken = Token.wrap(address(new TestERC20FeeOnTransfer("FEETKN", "FEETKN", 1_000_000_000 ether)));

        // transfer tokens to user
        nonTradeableToken.safeTransfer(user1, MAX_SOURCE_AMOUNT * 2);
        feeOnTransferToken.safeTransfer(user1, MAX_SOURCE_AMOUNT * 2);
        token0.safeTransfer(user1, MAX_SOURCE_AMOUNT * 2);
        token1.safeTransfer(user1, MAX_SOURCE_AMOUNT * 2);
        token2.safeTransfer(user1, MAX_SOURCE_AMOUNT * 2);
        bnt.safeTransfer(user1, MAX_SOURCE_AMOUNT * 5);

        vm.stopPrank();
    }

    /**
     * @dev deploys carbon controller and voucher
     */
    function setupCarbonController() internal {
        // Deploy Voucher
        voucher = deployVoucher();

        // Deploy Carbon Controller
        carbonController = deployCarbonController(voucher);

        // setup contracts from admin
        vm.startPrank(admin);

        // Deploy new Carbon Controller to set proxy address in constructor
        address carbonControllerImpl = address(
            new TestCarbonController(IVoucher(address(voucher)), address(carbonController))
        );

        // Upgrade Carbon Controller to set proxy address in constructor
        proxyAdmin.upgrade(ITransparentUpgradeableProxy(address(carbonController)), carbonControllerImpl);

        // Set Carbon Controller address
        carbonController = TestCarbonController(payable(address(carbonController)));

        // Grant minter role for voucher to carbon controller
        voucher.grantRole(voucher.roleMinter(), address(carbonController));

        vm.stopPrank();
    }

    /**
     * @dev deploys carbon vortex
     */
    function deployCarbonVortex(address _carbonController) internal {
        // deploy contracts from admin
        vm.startPrank(admin);
        // Deploy Carbon Vortex
        carbonVortex = new CarbonVortex(ICarbonController(_carbonController));
        bytes memory vortexInitData = abi.encodeWithSelector(carbonVortex.initialize.selector);
        // Deploy Carbon Vortex proxy
        address carbonVortexProxy = address(
            new OptimizedTransparentUpgradeableProxy(
                address(carbonVortex),
                payable(address(proxyAdmin)),
                vortexInitData
            )
        );

        // Set Carbon Vortex address
        carbonVortex = CarbonVortex(payable(carbonVortexProxy));

        // Set tank in Carbon Vortex
        carbonVortex.setTank(tank);

        // grant fee manager role to carbon vortex
        carbonController.grantRole(carbonController.roleFeesManager(), address(carbonVortex));

        vm.stopPrank();
    }

    /**
     * @dev deploys a new instance of the carbon controller
     */
    function deployCarbonController(TestVoucher _voucher) internal returns (TestCarbonController controller) {
        // deploy contracts from admin
        vm.startPrank(admin);
        // Deploy Carbon Controller
        TestCarbonController newCarbonController = new TestCarbonController(IVoucher(address(_voucher)), address(0));
        bytes memory carbonInitData = abi.encodeWithSelector(carbonController.initialize.selector);
        // Deploy Carbon proxy
        address carbonControllerProxy = address(
            new OptimizedTransparentUpgradeableProxy(
                address(newCarbonController),
                payable(address(proxyAdmin)),
                carbonInitData
            )
        );
        controller = TestCarbonController(payable(carbonControllerProxy));
        vm.stopPrank();
    }

    /**
     * @dev deploys a new instance of the voucher
     */
    function deployVoucher() internal returns (TestVoucher _voucher) {
        // deploy contracts from admin
        vm.startPrank(admin);
        // Deploy Voucher
        _voucher = new TestVoucher();
        bytes memory voucherInitData = abi.encodeWithSelector(voucher.initialize.selector, true, "ipfs://xxx", "");
        // Deploy Voucher proxy
        address voucherProxy = address(
            new OptimizedTransparentUpgradeableProxy(address(_voucher), payable(address(proxyAdmin)), voucherInitData)
        );
        _voucher = TestVoucher(voucherProxy);
        vm.stopPrank();
    }

    function transferTokensToCarbonController() internal {
        vm.startPrank(admin);
        // transfer tokens
        nonTradeableToken.safeTransfer(address(carbonController), MAX_SOURCE_AMOUNT * 2);
        token1.safeTransfer(address(carbonController), MAX_SOURCE_AMOUNT * 2);
        token2.safeTransfer(address(carbonController), MAX_SOURCE_AMOUNT * 2);
        bnt.safeTransfer(address(carbonController), MAX_SOURCE_AMOUNT * 5);
        // transfer eth
        vm.deal(address(carbonController), MAX_SOURCE_AMOUNT);
        vm.stopPrank();
    }
}
