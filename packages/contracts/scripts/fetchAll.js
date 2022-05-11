const hre = require("hardhat");
const fs = require("fs");
const { crumbleTokenAddress } = require('../artifacts')
const CrumbleToken = require("../artifacts/contracts/CrumbleToken.sol/CrumbleToken.json");

async function main() {
  // const CrumbleToken = await hre.ethers.getContractFactory("CrumbleToken");
  //const crumbleToken = await CrumbleToken.deploy();

    const provider = new ethers.providers.JsonRpcProvider();

    const contract = new ethers.Contract(
      crumbleTokenAddress,
      CrumbleToken.abi,
      provider
    );

    const data = await contract.fetchAllCrumbles();
//     const items = await Promise.all(
//       data.map(async (i) => {
//         const price = ethers.utils.formatUnits(i.price.toString(), "ether");
// 
//         let item = {
//           tokenId: i.tokenId.toNumber(),
//           seller: i.seller,
//           owner: i.owner,
//           price,
//         };
//         return item;
//       })
//     );
    console.log(data);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
