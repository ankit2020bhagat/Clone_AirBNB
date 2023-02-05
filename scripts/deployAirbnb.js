 
 const {ethers,run} = require("hardhat");

 async function main(){
 
  const AirbnbFactory = await ethers.getContractFactory("AirBNB")
  const deployAirbnb = await AirbnbFactory.deploy();
  console.log("Contract Deploying...")
  await deployAirbnb.deployed();
  console.log("Contract Deployed to ", deployAirbnb.address);
  await deployAirbnb.deployTransaction.wait(5);
  await verify(deployAirbnb.address,[]);

 }

const verify = async(contractAddress,args) =>{
  console.log("Verifying contracts....")
  try{
    await run("verify:verify",{
      address: contractAddress,
      constructorArguments: args,
    })
  }catch(e){
    if(e.message.toLowerCase().includes("already verified"))
    console.log("Already Verified")
    else{
      console.log(e);
    }
  }
}

main()
     .then(() => process.exit(0))
     .catch((error) =>{
      console.error(error);
      process.exit(1);
     });
     
//0x0b7337Fdbd129fEB6F1Ca37B87507EBEE2a9d3BC