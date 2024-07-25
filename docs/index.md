# Solidity API

## StackelbergGame


Smart contract to manage the common functions of the protocol.





### DECIMALS

```solidity
uint256 DECIMALS
```

Number of decimals considered for fixed-point operations.





### DECIMAL_PRECISION

```solidity
uint256 DECIMAL_PRECISION
```

Scale to apply fixed-point operations.





### SP

```solidity
bytes32 SP
```

Constant to provide access control for the spectrum provider.





### OPERATOR

```solidity
bytes32 OPERATOR
```

Constant to provide access control for the operators.





### State








```solidity
enum State {
  UNDEFINED,
  STARTED,
  EVALUATION,
  FINISHED
}
```

### Participant








```solidity
struct Participant {
  uint256 eta;
  uint256 w;
  uint256 varrho;
  uint256 p;
  uint256 b;
}
```

### SG








```solidity
struct SG {
  uint256 B;
  address[] participants;
  mapping(address => struct StackelbergGame.Participant) participant;
  enum StackelbergGame.State state;
}
```

### _sg

```solidity
mapping(uint256 => struct StackelbergGame.SG) _sg
```

Data of each round.





### Start

```solidity
event Start(uint256 id)
```

Event emmited when the {start} function is executed.





### Input

```solidity
event Input(uint256 id, address operator, uint256 eta, uint256 w, uint256 varrho)
```

Event emmited when the {input} function is executed.





### InitEvaluation

```solidity
event InitEvaluation(uint256 id)
```

Event emmited when the {initEvaluation} function is executed.





### Output

```solidity
event Output(uint256 id, uint256[] p, uint256[] b)
```

Event emmited when the {output} function is executed.





### constructor

```solidity
constructor(address[] c) public
```



_Sets the role of the spectrum provider and the operators._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| c | address[] | Operators' addresses. |



### initialize

```solidity
function initialize(uint256 id, uint256 B) public
```



_The spectrum provider allows the operators to publish their network parameters for the round identified by {id}._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |
| B | uint256 | Available bandwidth of the spectrum provider. |



### input

```solidity
function input(uint256 id, uint256 eta, uint256 w, uint256 varrho) public
```



_An operator publishes its network parameters._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |
| eta | uint256 | Aggregate spectral efficiency. |
| w | uint256 | Weighting coefficient. |
| varrho | uint256 | Normalizing coefficient. |



### initEvaluation

```solidity
function initEvaluation(uint256 id) public
```



_The spectrum provider ends the interval in which the operators could publish their network parameters._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |



### participantsOf

```solidity
function participantsOf(uint256 id) public view returns (address[])
```



_Get participants of a round._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address[] | Participants in round {id}. |


### priceOf

```solidity
function priceOf(uint256 id) public view returns (uint256)
```



_Get the price of a participant in a round._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Price of the operator in round {id}. |


### bandwidthOf

```solidity
function bandwidthOf(uint256 id) public view returns (uint256)
```



_Get the bandwidth of a participant in a round._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Bandwidth of the participant in round {id}. |


### stateOf

```solidity
function stateOf(uint256 id) public view returns (uint8)
```



_Get the state of a round._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint8 | State of the round {id}. |



## StackelbergGameOffChain


Smart contract to manage the publication of the results of the off-chain
resolution of the Stackelberg game.





### constructor

```solidity
constructor(address[] c) public
```



_Initialize the smart contract (see StackelbergGame constructor)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| c | address[] | Operators' addresses. |



### output

```solidity
function output(uint256 id, uint256[] p, uint256[] b) public
```



_The spectrum provider publishes the results of the off-chain resolution
of the Stackelberg game._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |
| p | uint256[] | Resulted prices. |
| b | uint256[] | Resulted bandwidths. |




## StackelbergGameOnChain


Smart contract to manage the publication of the results of the off-chain
resolution of the Stackelberg game.





### StackelbergGameOutput

```solidity
event StackelbergGameOutput(uint256 id)
```

Event emmited when the {solveStackelbergGame} function is executed.





### constructor

```solidity
constructor(address[] c) public
```



_Initialize the smart contract (see StackelbergGame constructor)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| c | address[] | Operators' addresses. |



### solveStackelbergGame

```solidity
function solveStackelbergGame(uint256 id) public
```



_The spectrum provider launches the on-chain resolution of the Stackelberg game._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | Identifier of the round. |




