const { expect } = require("chai");
const { Contract, Signer } = require("ethers");
const { keccak256 } = require("ethers/lib/utils");
const { ethers, waffle } = require("hardhat");
const {
  createChallenge,
  submitLevel,
  ETHERNAUT_ABI,
  ETHERNAUT_ADDRESS,
} = require("./utils");

const abi = [
  {
    inputs: [],
    name: "floor",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x40695363",
  },
  {
    inputs: [{ internalType: "uint256", name: "_floor", type: "uint256" }],
    name: "goTo",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0xed9a7134",
  },
  {
    inputs: [],
    name: "top",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0xfe6dcdba",
  },
];

const contractLevel = "0x1ca9f1c518ec5681C2B7F97c7385C0164c3A22Fe";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(contractLevel, 0, "PrivacyFactory");
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  let data = await ethers.provider.getStorageAt(challenge.address, 2);
  console.log(`data: ${JSON.stringify(data)}`);
  let bN = ethers.BigNumber.from(data);
  console.log(`bN: ${JSON.stringify(bN)}`);
  // const bytes = ethers.utils.arrayify(data);
  // console.log(`bytes: ${JSON.stringify(bytes)}`);
  // let decodedData = await ethers.utils.defaultAbiCoder.decode(["bytes32"]);
  // console.log(`decodedData: ${JSON.stringify(decodedData)}`);
  // 0x19a3d1dd174f4c665ca125fb4734f75be7378ad5bbe5467d7537c6459b578c45
  // let data = ethers.utils.keccak256(
  //   ethers.utils.solidityPack(["uint256"], [5])
  // );
  // console.log(`data: ${JSON.stringify(data)}`);
  //0x036b6384b5eca791c62761152d0c79bb0604c104a5fb6f4eb0703f3154bb3db0
  // const storageSlot = 6; // storage slot of the array
  // const elementIndex = 1; // index of the element you want to access (2nd element)
  // // get the value at the storage slot
  // const storageValue = await ethers.provider.getStorageAt(
  //   challenge.address,
  //   storageSlot
  // );
  // console.log(`storageValue: ${JSON.stringify(storageValue)}`);
  // // convert the value to a BigNumber
  // const storageValueBN = ethers.BigNumber.from(storageValue);
  // console.log(`storageValueBN: ${JSON.stringify(storageValueBN)}`);
  // // multiply the element index by 32 to get the offset of the element in the array
  // const elementOffsetBN = ethers.BigNumber.from(elementIndex).mul(32);
  // console.log(`elementOffsetBN: ${JSON.stringify(elementOffsetBN)}`);
  // // add the element offset to the storage value to get the location of the element
  // const elementLocationBN = storageValueBN.add(elementOffsetBN);
  // console.log(`elementLocationBN: ${JSON.stringify(elementLocationBN)}`);
  // // convert the element location to a hex string
  // const elementLocation = elementLocationBN.toHexString();
  // console.log(`elementLocation: ${JSON.stringify(elementLocation)}`);
  // // get the value at the element location
  // const elementValue = await ethers.provider.getStorageAt(
  //   challenge.address,
  //   elementLocation
  // );
  // console.log(`elementValue: ${JSON.stringify(elementValue)}`);
  // // elementValue is the value of the 2nd element in the array
  // const storageSlot = 5; // storage slot of the array
  // const elementIndex = 0; // index of the element in the array (0-indexed)
  // const elementOffset = elementIndex * 32; // offset of the element in the storage slot
  // const element = await ethers.provider.getStorageAt(
  //   challenge.address,
  //   storageSlot + elementOffset
  // );
  // console.log(element); // prints the element as a hexadecimal string
});

// after(async () => {
//   expect(await submitLevel(challenge.address), "level not solved").to.be.true;
// });
