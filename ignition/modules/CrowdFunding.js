const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");


module.exports = buildModule("LockModule", (m) => {
  

  const SmartBankContract = m.contract("SmartBankContract");

  return { SmartBankContract };
});
