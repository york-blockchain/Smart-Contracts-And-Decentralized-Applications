// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract D {
  uint public n;
  address public sender;

  function callSetN(address _e, uint _n) public {
    _e.call(abi.encodeWithSignature("setN(uint256)",_n)); // E's storage is set, D is not modified 
  }

  function staticcallSetN(address _e, uint _n) public {
    _e.staticcall(abi.encodeWithSignature("setN(uint256)", _n)); // D's storage is set, E is not modified 
  }

  function delegatecallSetN(address _e, uint _n) public {
    _e.delegatecall(abi.encodeWithSignature("setN(uint256)", _n)); // D's storage is set, E is not modified 
  }
}

contract E {
  uint public n;
  address public sender;

  function setN(uint _n) public {
    n = _n;
    sender = msg.sender;
    // msg.sender is D if invoked by D's staticcallSetN. None of E's storage is updated
    // msg.sender is C if invoked by C.foo(). None of E's storage is updated

    // the value of "this" is D, when invoked by either D's staticcallSetN or C.foo()
  }
}

contract C {
    function foo(D _d, E _e, uint _n) public {
        _d.delegatecallSetN(address(_e), _n);
    }
}