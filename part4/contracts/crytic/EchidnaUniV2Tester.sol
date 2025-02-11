pragma solidity ^0.6.0;
import "./Setup.sol";

contract EchidnaUniV2Tester is Setup {
    function test_provideLiquidity(uint amount1, uint amount2) public {
        // Pre-conditions
        amount1 = _between(amount1, 1000, uint(-1));
        amount2 = _between(amount2, 1000, uint(-1));

        if(!completed) {
            _init(amount1, amount2);
        }

        uint lpTokenBalanceBefore = pair.balanceOf(address(user));
        (uint reserve0Before, uint reserve1Before,) = pair.getReserves();
        uint kBefore = reserve0Before * reserve1Before;

        (bool success1,) = user.proxy(address(testToken1), abi.encodeWithSelector(testToken1.transfer.selector, address(pair), amount1));
        (bool success2,) = user.proxy(address(testToken2), abi.encodeWithSelector(testToken2.transfer.selector, address(pair), amount2));
        require(success1 && success2);

        // Actions
        (bool success3,) = user.proxy(address(pair), abi.encodeWithSelector(bytes4(keccak256("mint(address)")), address(user)));

        // Post-conditions
        if(success3) {
            uint lpTokenBalanceAfter = pair.balanceOf(address(user));
            (uint reserve0After, uint reserve1After,) = pair.getReserves();
            uint kAfter = reserve0After * reserve1After;
            assert(kAfter > kBefore);
            assert(lpTokenBalanceAfter > lpTokenBalanceBefore);
        }
    }

    function test_swapTokens(uint swapAmountIn) public {
        // Pre-conditions
        if(!completed) {
            _init(swapAmountIn, swapAmountIn);
        }

        address[] memory path = new address[](2);
        path[0] = address(testToken1);
        path[1] = address(testToken2);

        uint prevBal1 = testToken1.balanceOf(address(user));
        uint prevBal2 = testToken2.balanceOf(address(user));

        require(prevBal1 > 0);
        swapAmountIn = _between(swapAmountIn, 1, prevBal1);
        (uint reserve1Before, uint reserve2Before,) = UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));
        uint kBefore = reserve1Before * reserve2Before;
        
    }
}