// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title Stackelberg game.
 * @notice Smart contract to manage the common functions of the protocol. 
 */
contract StackelbergGame is AccessControl {

    /// @notice Number of decimals considered for fixed-point operations.
    uint256 public constant DECIMALS = 12;
    /// @notice Scale to apply fixed-point operations.
    uint256 public constant DECIMAL_PRECISION = 10**DECIMALS;

    /// @notice Constant to provide access control for the spectrum provider.
    bytes32 public constant SP = keccak256("SP");
    /// @notice Constant to provide access control for the operators.
    bytes32 public constant OPERATOR = keccak256("OPERATOR");

    /// @notice State of the round.
    enum State { UNDEFINED, STARTED, EVALUATION, FINISHED }

    /// @notice Operator data for each round.
    struct Participant {
        uint256 eta;    // Aggregate spectral efficiency.
        uint256 w;      // Weighting coefficient.
        uint256 varrho; // Normalizing coefficient.
        uint256 p;      // Outcome prices.
        uint256 b;      // Outcome bandwidths.
    }

    /// @notice Round data.
    struct SG {
        uint256 B;                                  // Available bandwidth of the spectrum provider in the round.              
        address [] participants;                    // Operators' addresses that participate in the round.
        mapping(address => Participant) participant;// Operators' data in the round.
        State state;                                // State of the round.
    }

    /// @notice Data of each round.
    mapping(uint256 => SG) internal _sg;

    /// @notice Event emmited when the {start} function is executed.
    event Start(uint256 indexed id);
    /// @notice Event emmited when the {input} function is executed. 
    event Input(uint256 indexed id, address indexed operator, uint256 eta, uint256 w, uint256 varrho);
    /// @notice Event emmited when the {initEvaluation} function is executed. 
    event InitEvaluation(uint256 indexed id);
    /// @notice Event emmited when the {output} function is executed. 
    event Output(uint256 indexed id, uint256[] p, uint256[] b);

    /**
     * @dev Sets the role of the spectrum provider and the operators.
     * @param c Operators' addresses.
     */
    constructor(address[] memory c) {
        _setRoleAdmin(OPERATOR, SP);
        _grantRole(SP, _msgSender());

        uint256 c_length = c.length;
        for (uint256 i = 0; i < c_length; ++i) {
            _grantRole(OPERATOR, c[i]);
        }
    }

    /**
     * @dev The spectrum provider allows the operators to publish their network parameters for the round identified by {id}.
     * @param id Identifier of the round.
     * @param B Available bandwidth of the spectrum provider.
     */
    function initialize(uint256 id, uint256 B) public onlyRole(SP) {
        require(_sg[id].state == State.UNDEFINED);
        _sg[id].state = State.STARTED;
        _sg[id].B = B;
        emit Start(id);
    }

    /**
     * @dev An operator publishes its network parameters.
     * @param id Identifier of the round.
     * @param eta Aggregate spectral efficiency.
     * @param w Weighting coefficient.
     * @param varrho Normalizing coefficient.
     */
    function input(uint256 id, uint256 eta, uint256 w, uint256 varrho) public onlyRole(OPERATOR) {
        require(_sg[id].state == State.STARTED);
        require(eta > 0 && w > 0 && varrho > 0, "Input: eta, w and varrho cannot be zero");
        require(_sg[id].participant[_msgSender()].w == 0, "Input: operator is already a participant");

        _sg[id].participants.push(_msgSender());
        _sg[id].participant[_msgSender()].eta = eta;
        _sg[id].participant[_msgSender()].w = w;
        _sg[id].participant[_msgSender()].varrho = varrho;

        emit Input(id, _msgSender(), eta, w, varrho);
    }

    /**
     * @dev The spectrum provider ends the interval in which the operators could publish their network parameters.
     * @param id Identifier of the round. 
     */
    function initEvaluation(uint256 id) public onlyRole(SP) {
        require(_sg[id].state == State.STARTED);
        _sg[id].state = State.EVALUATION;
        emit InitEvaluation(id);
    }

    // ===============================================================
    // PUBLIC VIEW FUNCTIONS
    // ===============================================================

    /**
      * @dev Get participants of a round.
      * @param id Identifier of the round.
      * @return Participants in round {id}.
      */
    function participantsOf(uint256 id) public view returns(address[] memory) {
        return _sg[id].participants;
    }

    /**
      * @dev Get the price of a participant in a round.
      * @param id Identifier of the round.
      * @return Price of the operator in round {id}.
      */
    function priceOf(uint256 id) public view returns(uint256) {
        return _sg[id].participant[_msgSender()].p;
    }

    /**
      * @dev Get the bandwidth of a participant in a round.
      * @param id Identifier of the round.
      * @return Bandwidth of the participant in round {id}.
      */
    function bandwidthOf(uint256 id) public view returns(uint256) {
        return _sg[id].participant[_msgSender()].b;
    }

    /**
      * @dev Get the state of a round.
      * @param id Identifier of the round.
      * @return State of the round {id}.
      */
    function stateOf(uint256 id) public view returns(uint8) {
        return uint8(_sg[id].state);
    }
}