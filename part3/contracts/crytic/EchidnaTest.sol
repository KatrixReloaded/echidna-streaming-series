pragma solidity ^0.6.0;

import "./Setup.sol";

contract EchidnaTest is Setup {
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

    function test_swap(uint amount1, uint amount2) public {
        // Pre-conditions
        if(!completed) {
            _init(amount1, amount2);
        }

        // Echidna will make sure to call the previous function with the amounts in order to get pair liquidity
        // we minted both tokens to the user, user transfers the tokens to the pair contract in the previous test function, we get pair tokens
        // this test will basically see if we get any tokens out without transferring any tokens in
        require(pair.balanceOf(address(user)) > 0); // there is liquidity 
        pair.sync(); // match the balances with the reserves

        // Actions
        (bool success,) = user.proxy(address(pair), abi.encodeWithSelector(pair.swap.selector, amount1, amount2, address(user), ""));

        // Post-conditions
        assert(!success);
    }
}

// @note READ UP ON SLIPPAGE