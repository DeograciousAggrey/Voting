const Voting = artifacts.require("Voting");

module.exports = async function (deployer) {
    array[] proposalNames = {"Joza", "Aggrey", "Roman"} ;
    await deployer.deploy(Voting,proposalNames);
};