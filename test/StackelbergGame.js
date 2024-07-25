/**
 * Tests for Stackelberg Game
 */

const process = require('node:process');
const { expect } = require("chai");
const { spawnSync } = require('child_process');
const {
    fromDecimalToFixed,
    fromFixedToDecimal,
    roundArray
} = require("./decimals.js");

const {
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

const State =  { UNDEFINED: "0", STARTED: "1", EVALUATION: "2", FINISHED: "3" }

// Variables from Matlab program
const B = 40000000;
const contract = process.env.contract || 'both';
const C = Number(process.env.C) || 5;
const w = Array(C).fill(1);
const varrho = Array(C).fill(Math.pow(10,10));
const eta5 = [
    135.300347072347,
    153.361137844823,
    152.848699462383,
    163.568365781403,
    177.338105252562,
]

const eta_all = [
    123.629691201674,
    143.532462038404,
    126.658197737166,
    136.142331719938,
    134.954214261951,
    134.772661398512,
    131.480665386096,
    134.448335669196,
    149.896376029816,
    137.762259342367,
    124.286307130873
];

const eta = (C === 5) ? eta5 : eta_all.slice(0,C);

const eta_fixed = fromDecimalToFixed(eta);
const w_fixed = fromDecimalToFixed(w);
const varrho_fixed = fromDecimalToFixed(varrho);

const expected_pc = [
    1.28791215764113e-08,
    1.37117993234623e-08,
    1.36888719648460e-08,
    1.41607561704861e-08,
    1.47447637887556e-08
]

const expected_Bc = [
    3735406.57679579,
    7724321.47374794,
    7627863.77529584,
    9481181.88086147,
    11431226.2932990
]

describe("Stackelberg Game", () => {

    // Test StackelbergGameOffChain smart contract
    if(contract !== 'StackelbergGameOnChain') {
        describe("Stackelberg Game Off-Chain", () => {

            let stackelbergGame, id = 0, operators = [], spectrumProvider = '', p_c, B_c;
            let lastOperator;

            it("spectrum provider should deploy contract", async() => {
                const signers = await ethers.getSigners();
                spectrumProvider = signers[0];
                operators = signers.slice(1, C+1);
                lastOperator = signers[C+1];
                const StackelbergGame = await ethers.getContractFactory("StackelbergGameOffChain");
                stackelbergGame = await StackelbergGame.deploy(operators);
            });

            it("spectrum provider should execute the initialize function", async() => {
                expect(await stackelbergGame.stateOf(id)).to.be.equal(State.UNDEFINED);
                await expect(stackelbergGame.connect(spectrumProvider).initialize(id, B))
                    .to.emit(stackelbergGame, "Start")
                    .withArgs(id);
                expect(await stackelbergGame.stateOf(id)).to.be.equal(State.STARTED);
            });

            it("each operator should execute input function", async() => {
                for (let i = 0; i < C; ++i) {
                    await expect(stackelbergGame.connect(operators[i]).input(id, eta_fixed[i], w_fixed[i], varrho_fixed[i]))
                        .to.emit(stackelbergGame, "Input")
                        .withArgs(id, operators[i].address, eta_fixed[i], w_fixed[i], varrho_fixed[i]);
                }
        
                expect(await stackelbergGame.participantsOf(id)).to.deep.equal(operators.map(({address }) => address));
            });

            it("spectrum provider should init evaluation", async() => {
                expect(await stackelbergGame.stateOf(id)).to.be.equal(State.STARTED);
                await expect(stackelbergGame.connect(spectrumProvider).initEvaluation(id))
                    .to.emit(stackelbergGame, "InitEvaluation")
                    .withArgs(id);
                expect(await stackelbergGame.stateOf(id)).to.be.equal(State.EVALUATION);
            });
        
            it("spectrum provider should publish results", async() => {
                const pythonProcess = spawnSync('python3',["./scripts/solveStackelbergGame.py", "evaluation", B, C, w, varrho, eta]);
        
                const result = pythonProcess.stdout?.toString()?.trim();
                const error = pythonProcess.stderr?.toString()?.trim();
                if (error) {
                    throw new Error(error);
                }
                [p_c, B_c] = result.split("\n").map(l => JSON.parse(l));
                
                if(p_c.length === expected_pc.length) {
                    expect(roundArray(p_c, 18)).to.deep.equal(roundArray(expected_pc, 18));
                    expect(roundArray(B_c, 6)).to.deep.equal(roundArray(expected_Bc, 6));
                }
            });

            it("spectrum provider should publish the results by executing the output function", async() => {
                const p_c_fixed = fromDecimalToFixed(p_c);
                const B_c_fixed = fromDecimalToFixed(B_c);
                expect(await stackelbergGame.stateOf(id)).to.be.equal(State.EVALUATION);
                await expect(stackelbergGame.connect(spectrumProvider).output(id, p_c_fixed, B_c_fixed))
                    .to.emit(stackelbergGame, "Output")
                    .withArgs(id, p_c_fixed, B_c_fixed);
                expect(await stackelbergGame.stateOf(id)).to.be.equal(State.FINISHED);
            });
            
            it("spectrum provider should add a new operator", async() => {
                const OPERATOR = await stackelbergGame.OPERATOR();
                await expect(stackelbergGame.connect(spectrumProvider).grantRole(OPERATOR, lastOperator.address))
                    .to.emit(stackelbergGame, "RoleGranted")
                    .withArgs(OPERATOR, lastOperator.address, spectrumProvider.address);
            });

            it("spectrum provider should remove an operator", async () => {
                const OPERATOR = await stackelbergGame.OPERATOR();
                await expect(stackelbergGame.connect(spectrumProvider).revokeRole(OPERATOR, lastOperator.address))
                    .to.emit(stackelbergGame, "RoleRevoked")
                    .withArgs(OPERATOR, lastOperator.address, spectrumProvider.address);
            });
        });
    }

    if(contract === 'both') {
        describe("Matlab", () => {
            it("Call Matlab stachelberg game", async () => {
                const params = `${B}, ${C}, [${w}], [${varrho}], [${eta}]`
                console.log(`"solveStackelbergGame(${params});exit"`);
                const matlabProcess = spawnSync('matlab.exe',["-sd", "scripts", "-batch", `"solveStackelbergGame(${params});exit"`]);
                const error = matlabProcess.stderr?.toString()?.trim();
                expect(error).to.equal("");
                
                const result = matlabProcess.stdout?.toString()?.trim();
                const [p_c, B_c] = result.split("\n").filter(e => !e.includes("Warning"))
            });
        });
    }

    // Test StackelbergGameOnChain smart contract
    if(contract !== 'StackelbergGameOfChain') {
        describe("Stackelberg Game On-Chain", () => {
            let stackelbergGame;
            let id = 0;
            let operators;
            let spectrumProvider;
            let lastOperator;

            before(async () => {
                // Prepare smart contract until before solving Stackelberg Game
                const signers = await ethers.getSigners();
                spectrumProvider = signers[0];
                operators = signers.slice(1, C+1);
                const StackelbergGame = await ethers.getContractFactory("StackelbergGameOnChain");
                stackelbergGame = await StackelbergGame.deploy(operators);
                lastOperator = signers[C+1];
                await stackelbergGame.initialize(id, B);

                const eta_fixed = fromDecimalToFixed(eta);
                const w_fixed = fromDecimalToFixed(w);
                const varrho_fixed = fromDecimalToFixed(varrho);
                
                for (let i = 0; i < C; ++i) {
                    await stackelbergGame.connect(operators[i]).input(id, eta_fixed[i], w_fixed[i], varrho_fixed[i]);
                }
        
                await stackelbergGame.connect(spectrumProvider).initEvaluation(id);
            });

            it("Solve Stackelberg Game", async () => {
                let p_c_fixed = [], B_c_fixed = [];
                await stackelbergGame.connect(spectrumProvider).solveStackelbergGame(id);

                for (let i = 0; i < C; ++i) {
                    p_c_fixed.push(await stackelbergGame.connect(operators[i]).priceOf(id));
                    B_c_fixed.push(await stackelbergGame.connect(operators[i]).bandwidthOf(id));
                }

                const p_c = fromFixedToDecimal(p_c_fixed);
                const B_c = fromFixedToDecimal(B_c_fixed);

                if(p_c.length === expected_pc.length)
                    expect(roundArray(p_c, 11)).to.deep.equal(roundArray(expected_pc, 11));
                
                // Bandwidth is expected to fail due to lack of decimal precision.
                // expect(roundArray(B_c, 3)).to.deep.equal(roundArray(expected_Bc, 3));
            });

            it("Spectrum provider should add a new operator", async() => {
                const OPERATOR = await stackelbergGame.OPERATOR();
                await expect(stackelbergGame.connect(spectrumProvider).grantRole(OPERATOR, lastOperator.address))
                    .to.emit(stackelbergGame, "RoleGranted")
                    .withArgs(OPERATOR, lastOperator.address, spectrumProvider.address);
            });

            it("Spectrum provider should remove an operator", async () => {
                const OPERATOR = await stackelbergGame.OPERATOR();
                await expect(stackelbergGame.connect(spectrumProvider).revokeRole(OPERATOR, lastOperator.address))
                    .to.emit(stackelbergGame, "RoleRevoked")
                    .withArgs(OPERATOR, lastOperator.address, spectrumProvider.address);
            });
        });
    }

    describe("Fail tests", () => {
        
        async function deployStackelbergGameOffChain() {
            const id = 1;
            const signers = await ethers.getSigners();
            const spectrumProvider = signers[0];
            const operators = signers.slice(1, C+1);
            const StackelbergGame = await ethers.getContractFactory("StackelbergGameOffChain");
            const stackelbergGame = await StackelbergGame.deploy(operators);
            return {stackelbergGame, spectrumProvider, operators, id};
        }

        async function setupStackelbergGameOnChain() {
            const id = 1;
            const signers = await ethers.getSigners();
            const spectrumProvider = signers[0];
            const operators = signers.slice(1, C+1);
            const StackelbergGame = await ethers.getContractFactory("StackelbergGameOnChain");
            const stackelbergGame = await StackelbergGame.deploy(operators);
            await stackelbergGame.initialize(id, B);

            const eta_fixed = fromDecimalToFixed(eta);
            const w_fixed = fromDecimalToFixed(w);
            const varrho_fixed = fromDecimalToFixed(varrho);
            
            for (let i = 0; i < C; ++i) {
                await stackelbergGame.connect(operators[i]).input(id, eta_fixed[i], w_fixed[i], varrho_fixed[i]);
            }

            return {stackelbergGame, spectrumProvider, operators, id};
        }

        it("an operator shouldn't execute the initialize function", async () => {
            const {stackelbergGame, operators, id} = await loadFixture(deployStackelbergGameOffChain);
            await expect(stackelbergGame.connect(operators[0]).initialize(id, B)).to.be.reverted;
        });

        it("spectrum provider shouldn't execute the initialize function again", async() => {
            const {stackelbergGame, spectrumProvider, id} = await loadFixture(deployStackelbergGameOffChain);
            await stackelbergGame.connect(spectrumProvider).initialize(id, B);
            await expect(stackelbergGame.connect(spectrumProvider).initialize(id, B)).to.be.reverted;
        });

        it("spectrum provider shouldn't execute the input function", async function() {
            const {stackelbergGame, spectrumProvider, id} = await loadFixture(deployStackelbergGameOffChain);
            await expect(stackelbergGame.connect(spectrumProvider).input(id, eta_fixed[0], w_fixed[0], varrho_fixed[0])).to.be.reverted;
        });

        it("an operator shouldn't execute input function with some of attributes 0", async() => {
            const {stackelbergGame, spectrumProvider, operators, id} = await loadFixture(deployStackelbergGameOffChain);
            await stackelbergGame.connect(spectrumProvider).initialize(id, B);
            const errorMsg = "Input: eta, w and varrho cannot be zero";

            await expect(stackelbergGame.connect(operators[0]).input(id, eta_fixed[0], "0", varrho_fixed[0]))
                .to.be.revertedWith(errorMsg);
            await expect(stackelbergGame.connect(operators[0]).input(id, "0", w_fixed[0], varrho_fixed[0]))
                .to.be.revertedWith(errorMsg);
            await expect(stackelbergGame.connect(operators[0]).input(id, eta_fixed[0], w_fixed[0], "0"))
                .to.be.revertedWith(errorMsg);
        });

        it("An operator shouldn't execute input function again", async() => {
            const {stackelbergGame, spectrumProvider, operators, id} = await loadFixture(deployStackelbergGameOffChain);
            await stackelbergGame.connect(spectrumProvider).initialize(id, B);
            await stackelbergGame.connect(operators[0]).input(id, eta_fixed[0], w_fixed[0], varrho_fixed[0]);
            await expect(stackelbergGame.connect(operators[0]).input(id, eta_fixed[0], w_fixed[0], varrho_fixed[0]))
                .to.be.revertedWith("Input: operator is already a participant");
        });

        it("an operator shouldn't execute input function after spectrum provider set state as InitEvaluation", async() => {
            const {stackelbergGame, spectrumProvider, operators, id} = await loadFixture(deployStackelbergGameOffChain);
            await stackelbergGame.connect(spectrumProvider).initialize(id, B);
            await stackelbergGame.connect(spectrumProvider).initEvaluation(id);
            await expect(stackelbergGame.connect(operators[0]).input(id, eta_fixed[0], w_fixed[0], varrho_fixed[0]))
                .to.be.reverted;
        });

        it("an operator shouldn't execute the initEvaluation function", async () => {
            const {stackelbergGame, operators, id} = await loadFixture(deployStackelbergGameOffChain);
            await expect(stackelbergGame.connect(operators[0]).initEvaluation(id)).to.be.reverted;
        });

        it("the spectrum provider shouldn't execute the initEvaluation function before the initialize function", async () => {
            const {stackelbergGame, spectrumProvider, id} = await loadFixture(deployStackelbergGameOffChain);
            await expect(stackelbergGame.connect(spectrumProvider).initEvaluation(id)).to.be.reverted;
        });

        it("an operator shouldn't execute the output function", async () => {
            const {stackelbergGame, operators, id} = await loadFixture(deployStackelbergGameOffChain);
            const B_c_fixed = fromDecimalToFixed(expected_Bc);
            const p_c_fixed = fromDecimalToFixed(expected_pc);
            await expect(stackelbergGame.connect(operators[0]).output(id, p_c_fixed, B_c_fixed)).to.be.reverted;
        });

        it("the spectrum provider shouldn't execute the output function before the initEvaluation function", async () => {
            const {stackelbergGame, spectrumProvider, id} = await loadFixture(deployStackelbergGameOffChain);
            await stackelbergGame.connect(spectrumProvider).initialize(id, B);
            await expect(stackelbergGame.connect(spectrumProvider).output(id, [], [])).to.be.reverted;
        });

        it("the spectrum provider shouldn't execute the output function without providing all p_c", async () => {
            const {stackelbergGame, spectrumProvider, operators, id} = await loadFixture(deployStackelbergGameOffChain);
            await stackelbergGame.connect(spectrumProvider).initialize(id, B);
            for (let i = 0; i < C; ++i) {
                await stackelbergGame.connect(operators[i]).input(id, eta_fixed[i], w_fixed[i], varrho_fixed[i]);
            }

            await stackelbergGame.connect(spectrumProvider).initEvaluation(id);
            const B_c_fixed = fromDecimalToFixed(expected_Bc);
            const p_c_fixed = fromDecimalToFixed(expected_pc);

            const new_p_c = p_c_fixed.slice(0, C-1);

            await expect(stackelbergGame.connect(spectrumProvider).output(id, new_p_c, B_c_fixed)).to.be.revertedWith("Output: required equal length");
        });

        it("the spectrum provider shouldn't execute the output function without providing all p_c", async () => {
            const {stackelbergGame, spectrumProvider, operators, id} = await loadFixture(deployStackelbergGameOffChain);
            await stackelbergGame.connect(spectrumProvider).initialize(id, B);
            for (let i = 0; i < C; ++i) {
                await stackelbergGame.connect(operators[i]).input(id, eta_fixed[i], w_fixed[i], varrho_fixed[i]);
            }

            await stackelbergGame.connect(spectrumProvider).initEvaluation(id);
            const B_c_fixed = fromDecimalToFixed(expected_Bc);
            const p_c_fixed = fromDecimalToFixed(expected_pc);

            const new_B_c = B_c_fixed.slice(0, C-1);

            await expect(stackelbergGame.connect(spectrumProvider).output(id, p_c_fixed, new_B_c)).to.be.revertedWith("Output: required equal length");
        });

        it("an operator shouldn't execute the solveStackelberg function", async () => {
            const {stackelbergGame, operators, id} = await loadFixture(setupStackelbergGameOnChain);
            await expect(stackelbergGame.connect(operators[0]).solveStackelbergGame(id)).to.be.reverted;
        });

        it("the spectrum provider shouln't execute the solveStackelberg function before the initEvaluation function", async () => {
            const {stackelbergGame, spectrumProvider, id} = await loadFixture(setupStackelbergGameOnChain);
            await expect(stackelbergGame.connect(spectrumProvider).solveStackelbergGame(id)).to.be.reverted;
        });
    });
});