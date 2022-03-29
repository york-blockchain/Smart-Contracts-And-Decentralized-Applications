const YorkToken = artifacts.require("YorkToken");
const truffleAssert = require("truffle-assertions");
const BigNumber = require("bignumber.js");

contract("YorkToken", (accounts) => {
    let contractInstance;
    let BN = web3.utils.BN;
    // creator account
    const creator = accounts[0];
    // recipient1 account
    const recipient1 = accounts[1];
    // recipient2 account
    const recipient2 = accounts[2];

    before( async () => {
        // deploying the contract
        contractInstance = await YorkToken.deployed();
        const symbol = await contractInstance.symbol();
        assert.equal(symbol,"YTN", "token symbol is not as expected");
        const name = await contractInstance.name();
        assert.equal(name,"York Token", "token name is not as expected");
        const decimals = await contractInstance.decimals();
        assert.equal(decimals,18, "token decimals is not as expected");
        const totalSupply = await contractInstance.totalSupply();
        assert(new BigNumber(totalSupply).isEqualTo(new BigNumber(web3.utils.toBN("1000000000000000000000000"))), "total supply is not as expected");
    });

    it("test transfer()", async () => {
        // balance of creator
        const balanceOfCreator = await contractInstance.balanceOf.call(creator);

        // assert balance of creator 
        assert(new BigNumber(balanceOfCreator).isEqualTo(new BigNumber(web3.utils.toBN("1000000000000000000000000"))), "balance of creator is not as expected");
        
        // execute transfer
        const tx = await contractInstance.transfer(recipient1, web3.utils.toBN("1000000000000000000000"), {
            from:creator
        })

        // balance of recipient
        const balanceOfRecipient1 = await contractInstance.balanceOf.call(recipient1);
        // assert balance of recipient
        assert(new BigNumber(balanceOfRecipient1).isEqualTo(new BigNumber(web3.utils.toBN("1000000000000000000000"))), "balance of recipient1 is not as expected")

        // assert balance of creator
        const expectedBalanceOfCreator = new BigNumber(web3.utils.toBN("1000000000000000000000000")).minus(new BigNumber(web3.utils.toBN("1000000000000000000000")));
        const newBalanceOfCreator = await contractInstance.balanceOf.call(creator);
        assert(new BigNumber(newBalanceOfCreator).isEqualTo(expectedBalanceOfCreator), "new balance of creator is not as expected")

        // assert transfer event 
        truffleAssert.eventEmitted(tx, "Transfer" , (obj) => {
            return (
                obj.from == creator && obj.to == recipient1 && new BigNumber(obj.value).isEqualTo(new BigNumber(web3.utils.toBN("1000000000000000000000")))
            )
        })
    })

    it("revert transfer()", async () => {
        // execute transfer
        truffleAssert.reverts(contractInstance.transfer(recipient2, web3.utils.toBN("10000000000000000000000"), {
            from:recipient1
        }),"insufficient funds")
    })
})