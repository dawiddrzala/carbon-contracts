// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

import { Token } from "../token/Token.sol";

import { Vault } from "../vaults/Vault.sol";

import { IVersioned } from "../utility/interfaces/IVersioned.sol";
import { Upgradeable } from "../utility/Upgradeable.sol";

import { MAX_GAP } from "../utility/Constants.sol";

contract TestVault is Vault {
    bool private _isAuthorizedWithdrawal;
    bool private _isPayable;

    uint256[MAX_GAP - 1] private __gap;

    constructor() Vault() {}

    function initialize() external initializer {
        __TestVault_init();
    }

    // solhint-disable func-name-mixedcase

    function __TestVault_init() internal onlyInitializing {
        __Vault_init();

        __TestVault_init_unchained();
    }

    function __TestVault_init_unchained() internal onlyInitializing {}

    // solhint-enable func-name-mixedcase

    function setAuthorizedWithdrawal(bool state) external {
        _isAuthorizedWithdrawal = state;
    }

    function setPayable(bool state) external {
        _isPayable = state;
    }

    function version() public pure override(IVersioned, Upgradeable) returns (uint16) {
        return 1;
    }

    function isPayable() public view override returns (bool) {
        return _isPayable;
    }

    function isAuthorizedWithdrawal(
        address, /* caller */
        Token, /* reserverToken */
        address, /* target */
        uint256 /* amount */
    ) internal view override returns (bool) {
        return _isAuthorizedWithdrawal;
    }
}
