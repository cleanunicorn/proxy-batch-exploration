// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import {TokenERC20} from "./test/utils/tokens/TokenERC20.sol";
import {Staking} from "./Staking.sol";
import {Hevm} from "./test/utils/Hevm.sol";
import {PRBProxy} from "@prb-proxy/contracts/PRBProxy.sol";
import {Batching} from "./batching/Batching.sol";

contract BatchingTest is DSTest {
    TokenERC20 internal tokenerc20;
    Staking internal staking;
    Hevm internal hevm = Hevm(HEVM_ADDRESS);
    Batching internal batching = new Batching();
    PRBProxy internal proxy = new PRBProxy();


    function setUp() public {
        tokenerc20 = new TokenERC20("Mock Token", "MOCK");
        staking = new Staking(address(tokenerc20));
    }

    function test_DepositWithdrawValueDirectly() public {
        uint amount = 100;

        tokenerc20.mint(address(this), amount);

        tokenerc20.approve(address(staking), amount);
        staking.deposit(amount);

        uint warpSeconds = 5;
        hevm.warp(block.timestamp + warpSeconds);

        staking.withdraw(amount);

        uint rewardAmount = staking.balanceOf(address(this));
        assertEq(rewardAmount, amount * staking.rewardPerSecond() * warpSeconds);
    }

    function test_DepositAndWithdrawContract() public {
        uint amount = 100;

        bool ok;
        bytes memory data;

        // Create tokens
        tokenerc20.mint(address(this), amount);

        // Deposit tokens
        (ok, data) = address(batching).delegatecall(
            abi.encodeWithSelector(
                batching.deposit.selector,
                tokenerc20,
                staking,
                amount
            )
        );

        assertTrue(ok);
        assertTrue(keccak256(data) == keccak256(bytes("")));

        // Travel in time
        uint warpSeconds = 5;
        hevm.warp(block.timestamp + warpSeconds);

        // Withdraw tokens and reward
        (ok, data) = address(batching).delegatecall(
            abi.encodeWithSelector(
                batching.withdraw.selector,
                staking,
                amount
            )
        );

        uint rewardAmount = staking.balanceOf(address(this));
        assertEq(rewardAmount, amount * staking.rewardPerSecond() * warpSeconds);
    }

    function test_DepositAndWithdrawProxy() public {
        uint amount = 100;

        // Create tokens
        tokenerc20.mint(address(proxy), amount);

        // Deposit tokens
        proxy.execute(
            address(batching),
            abi.encodeWithSelector(
                batching.deposit.selector,
                tokenerc20,
                staking,
                amount
            )
        );

        // Travel in time
        uint warpSeconds = 5;
        hevm.warp(block.timestamp + warpSeconds);

        // Withdraw tokens and reward
        proxy.execute(
            address(batching),
            abi.encodeWithSelector(
                batching.withdraw.selector,
                staking,
                amount
            )
        );

        uint rewardAmount = staking.balanceOf(address(proxy));
        assertEq(rewardAmount, amount * staking.rewardPerSecond() * warpSeconds);        
    }
}
