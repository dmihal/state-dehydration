// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import './libraries/UQ112x112.sol';
import {IERC20} from 'isolmate/interfaces/tokens/IERC20.sol';

contract AMM {
  using UQ112x112 for uint224;

  address public immutable token0;
  address public immutable token1;

  uint112 private reserve0; // uses single storage slot, accessible via getReserves
  uint112 private reserve1; // uses single storage slot, accessible via getReserves
  uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

  uint256 public price0CumulativeLast;
  uint256 public price1CumulativeLast;

  function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
    _reserve0 = reserve0;
    _reserve1 = reserve1;
    _blockTimestampLast = blockTimestampLast;
  }

  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  constructor(address _token0, address _token1) {
    token0 = _token0;
    token1 = _token1;
  }

  // update reserves and, on the first call per block, price accumulators
  function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) private {
    require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, 'UniswapV2: OVERFLOW');
    uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
    uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
    if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
      // * never overflows, and + overflow is desired
      price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
      price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
    }
    reserve0 = uint112(balance0);
    reserve1 = uint112(balance1);
    blockTimestampLast = blockTimestamp;
    emit Sync(reserve0, reserve1);
  }

  // this low-level function should be called from a contract which performs important safety checks
  function swap(uint256 amount0Out, uint256 amount1Out, address to) external {
    require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
    (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
    require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');

    uint256 balance0;
    uint256 balance1;
    {
      // scope for _token{0,1}, avoids stack too deep errors
      address _token0 = token0;
      address _token1 = token1;
      require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
      if (amount0Out > 0) IERC20(_token0).transfer(to, amount0Out); // optimistically transfer tokens
      if (amount1Out > 0) IERC20(_token1).transfer(to, amount1Out); // optimistically transfer tokens

      balance0 = IERC20(_token0).balanceOf(address(this));
      balance1 = IERC20(_token1).balanceOf(address(this));
    }
    uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
    uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
    require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
    {
      // scope for reserve{0,1}Adjusted, avoids stack too deep errors
      uint256 balance0Adjusted = balance0 * 1000 - (amount0In * 3);
      uint256 balance1Adjusted = balance1 * 1000 - (amount1In * 3);
      require(balance0Adjusted * balance1Adjusted >= uint256(_reserve0) * _reserve1 * (1000 ** 2), 'UniswapV2: K');
    }

    _update(balance0, balance1, _reserve0, _reserve1);
    emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
  }

  // force reserves to match balances
  function sync() external {
    _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
  }
}
