// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./StackelbergGame.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title Stackelberg game off-chain.
 * @notice Smart contract to manage the publication of the results of the off-chain
 * resolution of the Stackelberg game.
 */
contract StackelbergGameOnChain is StackelbergGame {

    /// @notice Event emmited when the {solveStackelbergGame} function is executed.
    event StackelbergGameOutput(uint256 indexed id);

    /**
     * @dev Initialize the smart contract (see StackelbergGame constructor).
     * @param c Operators' addresses.
     */
    constructor(address[] memory c) StackelbergGame(c) { }

    /**
     * @dev The spectrum provider launches the on-chain resolution of the Stackelberg game.
     * @param id Identifier of the round.
     */
    function solveStackelbergGame(uint256 id) public onlyRole(SP) {
        require(_sg[id].state == State.EVALUATION);
        uint256 C_set_length = _sg[id].participants.length;
        uint256[] memory C_set = new uint256[](C_set_length);

        Participant[] memory participants = new Participant[](C_set_length);
        bool Solved = false;

        for(uint256 i = 0; i < C_set_length; ++i) {
            C_set[i] = i;
            participants[i] = _sg[id].participant[_sg[id].participants[i]];
        }

        while (!Solved) {
            
            // calculate alpha
            uint256 alpha_num = 0;
            uint256 alpha_den = 0;

            for(uint256 i = 0; i < C_set_length; ++i) {
                alpha_num += (Math.sqrt(participants[C_set[i]].w * participants[C_set[i]].varrho * DECIMAL_PRECISION / participants[C_set[i]].eta));
                alpha_den += (participants[C_set[i]].varrho / participants[C_set[i]].eta);
            }
            alpha_den += _sg[id].B;

            uint256 alpha = alpha_num / alpha_den;

            for(uint256 i = 0; i < C_set_length; ++i) {
                participants[C_set[i]].p = alpha * Math.sqrt(Math.mulDiv(participants[C_set[i]].eta, participants[C_set[i]].w, participants[C_set[i]].varrho) * DECIMAL_PRECISION) / DECIMAL_PRECISION;
                participants[C_set[i]].b = participants[C_set[i]].w * DECIMAL_PRECISION / participants[C_set[i]].p - participants[C_set[i]].varrho * DECIMAL_PRECISION / participants[C_set[i]].eta;
            }

            Solved = true;

            // find (B_c(C_set) < 0, 1)
            for (uint256 i = 0; i < C_set_length; ++i) {
                if(participants[C_set[i]].b < 0) {
                    Solved = false;
                    break;
                }
            }

            if(!Solved) {

                // argmin
                uint256 cp = 0;
                for (uint256 i = 1; i < C_set_length; ++i) {
                    if (participants[C_set[i]].b < participants[cp].b) {
                        cp = C_set[i];
                    }
                }

                // remove cp from C_set
                C_set[cp] = C_set[C_set_length - 1];
                C_set_length --;

                participants[cp].b = 0;
                participants[cp].p = 0;
            }
        }

        // assign results
        for (uint i = 0; i < C_set_length; i++) {
            address c = _sg[id].participants[C_set[i]];
            _sg[id].participant[c].p = participants[C_set[i]].p;
            _sg[id].participant[c].b = participants[C_set[i]].b;
        }

        emit StackelbergGameOutput(id);
    }
}