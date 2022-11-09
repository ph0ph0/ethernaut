const { expect } = require("chai");
const { Contract, Signer } = require("ethers");
const { ethers, waffle } = require("hardhat");
const {
  createChallenge,
  submitLevel,
  ETHERNAUT_ABI,
  ETHERNAUT_ADDRESS,
} = require("./utils");

const abi = [
  { inputs: [], stateMutability: "nonpayable", type: "constructor" },
  {
    inputs: [],
    name: "consecutiveWins",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0xe6f334d7",
  },
  {
    inputs: [{ internalType: "bool", name: "_guess", type: "bool" }],
    name: "flip",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0x1d263f67",
  },
];

const contractLevel = "0xbeC52F1be33b65d5a5B7B32Aa64f9abF6a6Abb58";

before(async () => {
  const provider = await ethers.provider;
  const { chainId } = await provider.getNetwork();

  console.log(`code: ${JSON.stringify(await provider.getCode(contractLevel))}`);
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(contractLevel, 0, "CoinFlipFactory");
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  console.log(`----------------`);
  let hackContractFactory = await ethers.getContractFactory("CoinFlipHack");
  let hackContract = await hackContractFactory.deploy(challenge.address);
  await hackContract.deployed();
  console.log(`hackContract Address: ${JSON.stringify(hackContract.address)}`);

  let consecutiveWins = await challenge.consecutiveWins();
  while (consecutiveWins < 10) {
    console.log(`in loop...`);
    let tx = await hackContract.hackFlip(false);
    let txRt = await tx.wait(1);
    consecutiveWins = await challenge.consecutiveWins();
  }
  console.log(`consecutiveWins: ${JSON.stringify(consecutiveWins)}`);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
