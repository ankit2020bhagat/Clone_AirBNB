const {ethers,run} = require("hardhat");

 async function main(){

    console.log("deploying Contracts...");
    const automationfactory = await ethers.getContractFactory("Counter");
    const deployAutomation = await automationfactory.deploy("0x0b7337Fdbd129fEB6F1Ca37B87507EBEE2a9d3BC",30);
    await deployAutomation.deployed();
    console.log("Contract deployed to..",deployAutomation.address);
    await deployAutomation.deployTransaction.wait(5);
    await verify(deployAutomation.address,["0x0b7337Fdbd129fEB6F1Ca37B87507EBEE2a9d3BC",30])
    
 }

 const verify = async(contractAddress,args) =>{
    console.log("Verifying Contracts....")
    try{
        await run("verify:verify",{
            address: contractAddress,
            constructorArguments: args,
        });
    } catch(e){
      console.log(e);
    }
 }

 main().then(() => process.exit(0))
       .catch((error) => {
        process.exit(1);
       });
//0x59375eeCF6E7118564F159beC80e0E5b4df88eD3       