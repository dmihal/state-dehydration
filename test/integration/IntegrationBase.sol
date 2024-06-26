// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AMM} from 'contracts/AMM.sol';
import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract IntegrationBase is Test {
  uint256 internal constant _FORK_BLOCK = 18_920_905;

  string internal _initialGreeting = 'hola';
  address internal _user = makeAddr('user');
  address internal _owner = makeAddr('owner');
  address internal _daiWhale = 0x42f8CA49E88A8fd8F0bfA2C739e648468b8f9dec;
  IERC20 internal _dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  AMM internal _amm;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), _FORK_BLOCK);
    vm.prank(_owner);
    _amm = new AMM(address(0), address(0));
  }
}
