// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AMM} from 'contracts/AMM.sol';
import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

abstract contract Base is Test {
  address internal _owner = makeAddr('owner');

  IERC20 internal _token = IERC20(makeAddr('token'));
  string internal _initialGreeting = 'hola';
  bytes32 internal _emptyString = keccak256(bytes(''));
  AMM internal _greeter;

  function setUp() public virtual {
    vm.etch(address(_token), new bytes(0x1)); // etch bytecode to avoid address collision problems
    vm.prank(_owner);
    _greeter = new AMM(address(0), address(0));
  }
}

contract UnitGreeterConstructor is Base {
  function test_TokenSet() public {
    _greeter = new AMM(address(0), address(0));

    assertEq(address(_greeter.token0()), address(0));
  }
}
