// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staking is ERC20 {
    IERC20 public token;

    uint public constant rewardPerSecond = 1;

    struct Stake {
        address owner;
        uint256 amount;
        uint256 stakeTime;
    }

    mapping(address => Stake) stakes;

    constructor(address _token) ERC20("Reward Token", "RWRD") {
        token = IERC20(_token);
    }

    function deposit(uint _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        Stake storage stake = stakes[msg.sender];

        stake.amount += _amount;
        stake.stakeTime = block.timestamp;
    }

    function withdraw(uint _amount) public {
        Stake storage stake = stakes[msg.sender];

        stake.amount -= _amount;
        
        _mint(msg.sender, _amount * rewardPerSecond * (block.timestamp - stake.stakeTime));
    }
}
