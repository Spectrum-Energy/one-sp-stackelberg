// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./StackelbergGame.sol";

/**
 * @title Stackelberg game off-chain.
 * @notice Smart contract to manage the publication of the results of the off-chain
 * resolution of the Stackelberg game.
 */
contract StackelbergGameOffChain is StackelbergGame {

    /**
     * @dev Initialize the smart contract (see StackelbergGame constructor).
     * @param c Operators' addresses.
     */
    constructor(address[] memory c) StackelbergGame(c) { }

    /**
     * @dev The spectrum provider publishes the results of the off-chain resolution
     * of the Stackelberg game.
     * @param id Identifier of the round.
     * @param p Resulted prices.
     * @param b Resulted bandwidths.
     */
    function output(uint256 id, uint256[] memory p, uint256[] memory b) public onlyRole(SP) {
        require(_sg[id].state == State.EVALUATION);
        
        uint256 participants_length = _sg[id].participants.length;
        require(participants_length == p.length && participants_length == b.length, "Output: required equal length");

        for(uint256 i = 0; i < participants_length; ++i) {
            _sg[id].participant[_sg[id].participants[i]].p = p[i];
            _sg[id].participant[_sg[id].participants[i]].b = b[i];
        }

        _sg[id].state = State.FINISHED;
        emit Output(id, p, b);
    }
}