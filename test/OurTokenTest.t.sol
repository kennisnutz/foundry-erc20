// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        vm.prank(msg.sender);
        ourToken.transfer(bob, INITIAL_BALANCE);

    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }
    function testBobBalance() public {
        assertEq(ourToken.balanceOf(bob), INITIAL_BALANCE);
    }
    

    function testAllowanceWorks() public {
        vm.prank(bob);
        ourToken.approve(alice, INITIAL_BALANCE);
        uint256 transferAmt = INITIAL_BALANCE / 2;
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmt);

        assertEq(ourToken.balanceOf(alice), transferAmt);
        assertEq(ourToken.balanceOf(bob), INITIAL_BALANCE - transferAmt);

    }

    function testTransferFrom() public {
        // User1 approves User2 to spend 500 tokens
        uint256 transferAmt = INITIAL_BALANCE / 2;
        vm.prank(bob);
        ourToken.approve(alice, INITIAL_BALANCE);

        // User2 transfers 300 tokens from User1 to themselves using transferFrom
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmt);

        // Check balances
        assertEq(ourToken.balanceOf(bob), INITIAL_BALANCE - transferAmt);
        assertEq(ourToken.balanceOf(alice), transferAmt);

        // Check remaining allowance
        assertEq(ourToken.allowance(bob, alice), INITIAL_BALANCE - transferAmt);
    }

    
    function testFailTransferFromExceedsAllowance() public {
        // User1 approves User2 to spend 500 tokens
        vm.prank(bob);
        ourToken.approve(alice, 500 * 10 ** ourToken.decimals());

        // User2 tries to transfer more tokens than the allowance
        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 600 * 10 ** ourToken.decimals());
    }

}