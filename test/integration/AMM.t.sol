// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IntegrationBase} from 'test/integration/IntegrationBase.sol';

contract IntegrationGreeter is IntegrationBase {
  function test_Greet() public {
    vm.prank(_daiWhale);

    // assertEq(_whaleBalance, _balance);
    // assertEq(_initialGreeting, _greeting);
  }
}
