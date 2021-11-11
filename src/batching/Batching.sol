// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Staking} from "../Staking.sol";
contract Batching {
    function deposit(address _token, address _stakeContract, uint _amount) public {
        IERC20(_token).approve(_stakeContract, _amount);
        Staking(_stakeContract).deposit(_amount);
    }

    function withdraw(address _stakeContract, uint _amount) public {
        Staking(_stakeContract).withdraw(_amount);
    }
}