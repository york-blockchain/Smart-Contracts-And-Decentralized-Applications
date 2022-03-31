pragma solidity >=0.4.22 <0.7.0;

contract SimpleStorage {
    uint public storedData;

    constructor() public {
        storedData = 100;
    }

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint retVal) {
        return storedData;
    }
}

import "remix_tests.sol";

contract MyTest {
    SimpleStorage foo;

    // beforeEach works before running each test
    function beforeEach() public {
        foo = new SimpleStorage();
    }

    /// Test if initial value is set correctly
    function initialValueShouldBe100() public returns (bool) {
        return Assert.equal(foo.get(), 100, "initial value is not correct");
    }

    /// Test if value is set as expected
    function valueIsSet200() public returns (bool) {
        foo.set(200);
        return Assert.equal(foo.get(), 200, "value is not 200");
    }
}