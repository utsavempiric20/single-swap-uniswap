// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
     function transfer(address to, uint256 value) external returns (bool);
     function approve(address spender, uint256 value) external returns (bool);
}

contract Singleswap {
    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    ISwapRouter public immutable swapRouter = ISwapRouter(routerAddress);

    address public constant LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address public constant WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;

    IERC20 public linkToken = IERC20(LINK);

    uint24 public constant poolFee = 3000;

    constructor() {
    }


    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {

        linkToken.approve( address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: LINK,
                tokenOut: WETH,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {

        linkToken.approve( address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: LINK,
                tokenOut: WETH,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            linkToken.approve(address(swapRouter), 0);
            linkToken.transfer(address(this), amountInMaximum - amountIn);
        }
    }
}