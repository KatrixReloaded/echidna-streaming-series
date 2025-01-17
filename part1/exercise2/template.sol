pragma solidity ^0.8.0;
import "./token.sol";

contract TestToken is Token {
    constructor() public {
        paused(); // pause the contract
        owner = address(0x0); // lose ownership
    }

    function echidna_cannot_be_unpaused() public view returns (bool) {
        return is_paused;
    }

    function testPausable(uint256 amount) public {
        assert(is_paused);
    }
}