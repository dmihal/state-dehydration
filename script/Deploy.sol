// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AMM} from 'contracts/AMM.sol';
import {Script} from 'forge-std/Script.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract Deploy is Script {
  /// @notice Deployment parameters for each chain
  // mapping(uint256 _chainId => DeploymentParams _params) internal _deploymentParams;

  function setUp() public {}

  function run() public {
    vm.startBroadcast();
    new AMM(address(0), address(0));
    vm.stopBroadcast();
  }
}
