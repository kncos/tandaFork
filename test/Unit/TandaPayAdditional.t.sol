// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {TandaPay} from "../../src/TandaPay.sol";
import {Secretary} from "../../src/secretary.sol";
import {TandaPayEvents} from "../../src/util/TandaPayEvents.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

import {TandaPayErrors} from "../../src/util/TandaPayErrors.sol";
import {Token, IERC20} from "../../src/mock/Token.sol";

contract AdditionalContext is Context {
    function msgSender() public view virtual returns (address) {
        return _msgSender();
    }

    function msgData() public view virtual returns (bytes calldata) {
        return _msgData();
    }
}

contract AdditionalSecretary is Secretary {
    constructor(address newSecretary) Secretary(newSecretary) {}

    function transferSecretary(address _new) public onlySecretary {
        _transferSecretary(_new);
    }
}

contract AdditionalReentrancyGuard is ReentrancyGuard {
    function reentrancyGuardEntered() public view returns (bool) {
        return _reentrancyGuardEntered();
    }
}

// contract TheBank is ReentrancyGuard {
//     mapping(address => uint) theBalances;
//     function deposit() public payable {
//         theBalances[msg.sender] += msg.value;
//     }
//     function withdrawal() public nonReentrant {
//         payable(msg.sender).transfer(1 ether);
//         theBalances[msg.sender] -= 0;
//     }
// }

// contract TheAttacker {
//     TheBank private theBank;

//     receive() external payable {
//         if (address(theBank).balance >= 1 ether) {
//             theBank.withdrawal();
//         }
//     }
//     function attack(address _bank) external payable {
//         if (address(theBank) == address(0)) {
//             theBank = TheBank(_bank);
//         }
//         theBank.deposit{value: 10 ether}();
//         theBank.withdrawal();
//     }
// }

contract AdditionalToken is Token {
    constructor() Token(msg.sender) {}
    function burn(address account, uint256 value) public {
        _burn(account, value);
    }
}

contract TandaPayAdditionalTest is Test {
    AdditionalContext public additionalContext;
    AdditionalSecretary public secretary;
    AdditionalReentrancyGuard public reentrancyGuard;
    // TheBank public bank;
    // TheAttacker public attacker;
    TandaPay public tandaPay;
    Token public paymentToken;
    address[] public successors;
    uint256 public basePremium;
    address public initialSecretary = address(this);
    address public member1 = address(1);
    address public member2 = address(2);
    address public member3 = address(3);
    address public member4 = address(4);
    address public member5 = address(5);
    address public member6 = address(6);
    address public member7 = address(7);
    address public member8 = address(8);
    address public member9 = address(9);
    address public member10 = address(10);
    address public member11 = address(11);
    address public member12 = address(12);
    address public member13 = address(13);
    function setUp() public {
        // bank = new TheBank();
        // attacker = new TheAttacker();
        additionalContext = new AdditionalContext();
        secretary = new AdditionalSecretary(initialSecretary);
        reentrancyGuard = new AdditionalReentrancyGuard();
        paymentToken = new Token(address(this));
        tandaPay = new TandaPay(address(paymentToken), address(this));
        paymentToken.approve(address(tandaPay), 100000000000e18);
        paymentToken.transfer(member1, 1000e18);
        paymentToken.transfer(member2, 1000e18);
        paymentToken.transfer(member2, 1000e18);
        paymentToken.transfer(member3, 1000e18);
        paymentToken.transfer(member4, 1000e18);
        paymentToken.transfer(member5, 1000e18);
        paymentToken.transfer(member6, 1000e18);
        paymentToken.transfer(member7, 1000e18);
        paymentToken.transfer(member8, 1000e18);
        paymentToken.transfer(member9, 1000e18);
        paymentToken.transfer(member10, 1000e18);
        paymentToken.transfer(member11, 1000e18);
        paymentToken.transfer(member12, 1000e18);
        paymentToken.transfer(member13, 1000e18);
    }

    // function testAttack() public {
    //     vm.expectRevert(
    //         abi.encodeWithSelector(
    //             ReentrancyGuard.ReentrancyGuardReentrantCall.selector
    //         )
    //     );
    //     attacker.attack{value: 10 ether}(address(bank));
    // }

    function addToCommunity(address _member) public {
        uint256 mIdBefore = tandaPay.getCurrentMemberId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.AddedToCommunity(_member, mIdBefore + 1);
        tandaPay.addToCommunity(_member);
        uint256 mIdAfter = tandaPay.getCurrentMemberId();
        assertEq(mIdBefore + 1, mIdAfter);
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            _member,
            0
        );
        assertEq(mInfo.associatedGroupId, 0);

        assertEq(mInfo.member, _member);
        assertEq(mInfo.memberId, mIdAfter);
        assertEq(
            uint8(mInfo.status),
            uint8(TandaPayEvents.MemberStatus.Assigned)
        );
        assertEq(
            uint8(mInfo.assignment),
            uint8(TandaPay.AssignmentStatus.AddedBySecretery)
        );
    }

    function createASubGroup() public returns (uint256) {
        uint256 gIdBefore = tandaPay.getCurrentSubGroupId();
        vm.expectEmit();
        emit TandaPayEvents.SubGroupCreated(gIdBefore + 1);
        tandaPay.createSubGroup();
        uint256 gIdAfter = tandaPay.getCurrentSubGroupId();
        assertEq(gIdBefore + 1, gIdAfter);
        TandaPay.SubGroupInfo memory sInfo = tandaPay
            .getSubGroupIdToSubGroupInfo(gIdAfter);
        assertEq(sInfo.id, gIdAfter);
        return gIdAfter;
    }

    function assignToSubGroup(
        address _member,
        uint256 _gId,
        uint256 _expectedMember
    ) public {
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.AssignedToSubGroup(_member, _gId, false);
        tandaPay.assignToSubGroup(_member, _gId, false);
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            _member,
            0
        );
        assertEq(mInfo.associatedGroupId, _gId);
        TandaPay.SubGroupInfo memory sInfo = tandaPay
            .getSubGroupIdToSubGroupInfo(_gId);
        assertEq(sInfo.id, _gId);
        bool isIn;
        for (uint256 i = 0; i < sInfo.members.length; i++) {
            if (sInfo.members[i] == _member) {
                isIn = true;
            }
        }
        assertTrue(isIn);
        assertEq(sInfo.members.length, _expectedMember);
        if (sInfo.members.length >= 4 && sInfo.members.length <= 7) {
            assertTrue(sInfo.isValid);
        } else {
            assertFalse(sInfo.isValid);
        }
    }

    function joinToCommunity(address _member, uint256 joinFee) public {
        vm.startPrank(_member);
        paymentToken.approve(address(tandaPay), 1000e18);
        uint256 m1BalanceBefore = paymentToken.balanceOf(_member);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.JoinedToCommunity(_member, joinFee);
        tandaPay.joinToCommunity();
        vm.stopPrank();
        uint256 m1BalanceAfter = paymentToken.balanceOf(_member);
        assertEq(m1BalanceBefore, m1BalanceAfter + joinFee);
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            _member,
            0
        );
        assertEq(joinFee, mInfo.ISEscorwAmount);
        assertEq(uint8(mInfo.status), uint8(TandaPayEvents.MemberStatus.New));
        assertEq(
            uint8(mInfo.assignment),
            uint8(TandaPay.AssignmentStatus.ApprovedByMember)
        );
    }

    function approveSubGroupAssignment(
        address _member,
        bool shouldJoin
    ) public {
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            _member,
            0
        );
        vm.startPrank(_member);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ApprovedGroupAssignment(
            _member,
            mInfo.associatedGroupId,
            shouldJoin
        );
        tandaPay.approveSubGroupAssignment(shouldJoin);
        mInfo = tandaPay.getMemberToMemberInfo(_member, 0);
        assertEq(
            uint8(mInfo.assignment),
            uint8(TandaPay.AssignmentStatus.AssignmentSuccessfull)
        );
        vm.stopPrank();
    }

    function payPremium(
        address _member,
        uint256 pFee,
        uint256 nPId,
        bool _fromATW
    ) public {
        vm.startPrank(_member);
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            _member,
            nPId + 1
        );
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.PremiumPaid(
            _member,
            nPId,
            _fromATW
                ? mInfo.availableToWithdraw >
                    basePremium + (pFee - mInfo.ISEscorwAmount)
                    ? 0
                    : basePremium +
                        (pFee - mInfo.ISEscorwAmount) -
                        mInfo.availableToWithdraw
                : basePremium + (pFee - mInfo.ISEscorwAmount),
            _fromATW
        );
        tandaPay.payPremium(_fromATW);
        mInfo = tandaPay.getMemberToMemberInfo(_member, nPId + 1);
        assertTrue(mInfo.eligibleForCoverageInPeriod);
        assertTrue(mInfo.isPremiumPaid);
        assertEq(mInfo.cEscrowAmount, basePremium);
        assertEq(mInfo.ISEscorwAmount, pFee);
        vm.stopPrank();
    }

    function testIf_msgSenderFunctionWorksProperly() public {
        address messageSender = member1;
        vm.startPrank(messageSender);
        address sender = additionalContext.msgSender();
        vm.stopPrank();
        assertEq(sender, messageSender);
    }

    function testIf_msgDataFunctionWorksProperly() public view {
        bytes memory data = additionalContext.msgData();
        assertTrue(data.length > 0);
    }

    function testConstructorOfSecretary() public {
        address initialSecretary2 = member1;
        vm.startPrank(initialSecretary2);
        AdditionalSecretary secretaryContract = new AdditionalSecretary(
            initialSecretary2
        );
        vm.stopPrank();
        assertEq(secretaryContract.secretary(), initialSecretary2);
    }

    function testIftransferSecretaryFunctionWorksProperly() public {
        address newMember = member2;
        address oldSecretary = secretary.secretary();
        vm.expectEmit(address(secretary));
        emit Secretary.SecretaryTransferred(oldSecretary, newMember);
        secretary.transferSecretary(newMember);
        address newSecretary = secretary.secretary();
        assertEq(newSecretary, newMember);
    }

    function testIf_reentrancyGuardEnteredFunctionWorksProperly() public view {
        bool entered = reentrancyGuard.reentrancyGuardEntered();
        assertEq(entered, false);
    }

    function testConstructorOfReentrancyGuard() public {
        AdditionalReentrancyGuard reentrancyContract = new AdditionalReentrancyGuard();
        bool entered = reentrancyContract.reentrancyGuardEntered();
        assertEq(entered, false);
    }

    function testConstructorOfPaymentToken() public {
        address initialRecipient = member1;
        uint256 expectedTotalSupply = 10000000000000000000 * 10 ** 18;
        string memory expectedname = "LUSD";
        string memory expectedsymbol = "LUSD";
        vm.startPrank(initialRecipient);
        Token tokenContract = new Token(initialRecipient);
        vm.stopPrank();
        string memory name = tokenContract.name();
        assertEq(expectedname, name);
        string memory symbol = tokenContract.symbol();
        assertEq(expectedsymbol, symbol);
        uint256 totalSupply = tokenContract.totalSupply();
        assertEq(expectedTotalSupply, totalSupply);
        uint256 balanceOfInitalRecipient = tokenContract.balanceOf(
            initialRecipient
        );
        assertEq(balanceOfInitalRecipient, expectedTotalSupply);
    }

    function testIfdecimalsFunctionWorksProperly() public view {
        uint8 decimals = paymentToken.decimals();
        assertEq(decimals, 18);
    }

    function testIfallowanceFunctionWorksProperly() public view {
        uint256 allowance = paymentToken.allowance(member1, address(this));
        assertEq(allowance, 0);
    }

    function testIfincreaseAllowanceFunctionWorksProperly() public {
        uint256 amount = 10000 * 10 ** 18;
        uint256 allowance = paymentToken.allowance(member1, address(this));
        assertEq(allowance, 0);
        vm.startPrank(member1);
        paymentToken.increaseAllowance(address(this), amount);
        vm.stopPrank();
        uint256 allowanceAfter = paymentToken.allowance(member1, address(this));
        assertEq(allowanceAfter, amount);
    }
    function testIfdecreaseAllowanceFunctionWorksProperly() public {
        uint256 amount = 10000 * 10 ** 18;
        uint256 allowance = paymentToken.allowance(member1, address(this));
        assertEq(allowance, 0);
        vm.startPrank(member1);
        paymentToken.increaseAllowance(address(this), amount);
        uint256 allowanceAfter = paymentToken.allowance(member1, address(this));
        assertEq(allowanceAfter, amount);

        uint256 decreaseAmount = 10e18;
        paymentToken.decreaseAllowance(address(this), decreaseAmount);
        uint256 allowanceAfter2 = paymentToken.allowance(
            member1,
            address(this)
        );
        assertEq(allowanceAfter2, amount - decreaseAmount);
        vm.stopPrank();
    }

    function testIfTokenCanBeBurn() public {
        uint256 amount = 10000 * 10 ** 18;
        AdditionalToken tokenContract = new AdditionalToken();
        tokenContract.burn(address(this), amount);
    }

    function testIfAssignmentStatusUpdateIfExistingMemberRejectNewReorgedSubGroupMember()
        public
    {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);

        uint256 gIdAfter1 = createASubGroup();
        uint256 gIdAfter2 = createASubGroup();
        uint256 gIdAfter3 = createASubGroup();

        assignToSubGroup(member1, gIdAfter1, 1);
        assignToSubGroup(member2, gIdAfter1, 2);
        assignToSubGroup(member3, gIdAfter1, 3);
        assignToSubGroup(member4, gIdAfter1, 4);
        assignToSubGroup(member5, gIdAfter2, 1);
        assignToSubGroup(member6, gIdAfter2, 2);
        assignToSubGroup(member7, gIdAfter2, 3);
        assignToSubGroup(member8, gIdAfter2, 4);
        assignToSubGroup(member9, gIdAfter3, 1);
        assignToSubGroup(member10, gIdAfter3, 2);
        assignToSubGroup(member11, gIdAfter3, 3);
        assignToSubGroup(member12, gIdAfter3, 4);
        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();
        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;
        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);
        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);
        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);
        skip(27 days);
        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;
        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);
        skip(3 days);
        uint256 currentPeriodIdBefore2 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore2 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore2 + 1, currentPeriodIdAfter2);
        TandaPay.PeriodInfo memory pInfo2 = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter2
        );
        assertEq(pInfo2.startedAt + 30 days, pInfo2.willEndAt);
        vm.startPrank(member1);
        tandaPay.exitSubGroup();
        TandaPay.DemoMemberInfo memory mInfo1 = tandaPay.getMemberToMemberInfo(
            member1,
            0
        );
        assertEq(mInfo1.associatedGroupId, 0);
        assertEq(
            uint8(mInfo1.status),
            uint8(TandaPayEvents.MemberStatus.PAID_INVALID)
        );
        vm.stopPrank();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.AssignedToSubGroup(member1, gIdAfter3, true);
        tandaPay.assignToSubGroup(member1, gIdAfter3, true);
        mInfo1 = tandaPay.getMemberToMemberInfo(member1, 0);
        assertEq(mInfo1.associatedGroupId, gIdAfter3);
        assertEq(
            uint8(mInfo1.status),
            uint8(TandaPayEvents.MemberStatus.REORGED)
        );
        TandaPay.SubGroupInfo memory sInfo3 = tandaPay
            .getSubGroupIdToSubGroupInfo(gIdAfter3);
        assertEq(sInfo3.id, gIdAfter3);
        bool isIn1Again;
        for (uint256 i = 0; i < sInfo3.members.length; i++) {
            if (sInfo3.members[i] == member1) {
                isIn1Again = true;
            }
        }
        assertTrue(isIn1Again);
        assertEq(sInfo3.members.length, 5);
        assertTrue(sInfo3.isValid);
        vm.startPrank(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ApprovedGroupAssignment(
            member1,
            mInfo1.associatedGroupId,
            shouldJoin
        );
        tandaPay.approveSubGroupAssignment(shouldJoin);
        mInfo1 = tandaPay.getMemberToMemberInfo(member1, 0);
        assertEq(
            uint8(mInfo1.assignment),
            uint8(TandaPay.AssignmentStatus.ApprovedByMember)
        );
        vm.stopPrank();
        vm.startPrank(member12);
        uint256 nMemberId = tandaPay.getMemberToMemberId(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ApproveNewGroupMember(
            member1,
            member12,
            mInfo1.associatedGroupId,
            false
        );
        tandaPay.approveNewSubgroupMember(gIdAfter3, nMemberId, false);
        mInfo1 = tandaPay.getMemberToMemberInfo(member1, 0);
        assertEq(
            uint8(mInfo1.assignment),
            uint8(TandaPay.AssignmentStatus.CancelledGMember)
        );
        vm.stopPrank();
    }

    function testIfRevertIfNotIncludedTheSubGroupWhileExitingSubGroup() public {
        uint256 mIdBefore = tandaPay.getCurrentMemberId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.AddedToCommunity(member1, mIdBefore + 1);
        tandaPay.addToCommunity(member1);
        uint256 mIdAfter = tandaPay.getCurrentMemberId();
        assertEq(mIdAfter, mIdBefore + 1);
        tandaPay.createSubGroup();
        uint256 gId = tandaPay.getCurrentSubGroupId();
        assertEq(gId, uint256(1));
        tandaPay.assignToSubGroup(member1, gId, false);
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            member1,
            0
        );
        assertEq(mInfo.associatedGroupId, gId);
        assertEq(mInfo.member, member1);
        TandaPay.AssignmentStatus AStatus1Before = mInfo.assignment;
        TandaPay.AssignmentStatus AStatus2Before = TandaPay
            .AssignmentStatus
            .AssignedToGroup;
        assertEq(uint8(AStatus1Before), uint8(AStatus2Before));
        vm.startPrank(member1);
        tandaPay.approveSubGroupAssignment(false);
        vm.stopPrank();

        TandaPay.DemoMemberInfo memory mInfo2 = tandaPay.getMemberToMemberInfo(
            member1,
            0
        );
        assertEq(mInfo2.associatedGroupId, gId);
        assertEq(mInfo2.member, member1);
        assertEq(
            uint8(mInfo2.status),
            uint8(TandaPayEvents.MemberStatus.USER_QUIT)
        );
        TandaPay.SubGroupInfo memory sInfo = tandaPay
            .getSubGroupIdToSubGroupInfo(gId);
        bool notIn = true;
        for (uint256 i = 0; i < sInfo.members.length; i++) {
            if (sInfo.members[i] == mInfo2.member) {
                notIn = false;
            }
        }
        assertTrue(notIn);
        vm.startPrank(member1);
        vm.expectRevert(abi.encodeWithSelector(TandaPayErrors.NotIncluded.selector));
        tandaPay.exitSubGroup();
        vm.stopPrank();
    }

    function testIfMemberStatusBecomePaidInvalidWhileExitingSubGroup() public {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);
        addToCommunity(member13);

        uint256 gIdAfter1 = createASubGroup();
        uint256 gIdAfter2 = createASubGroup();
        uint256 gIdAfter3 = createASubGroup();

        assignToSubGroup(member1, gIdAfter1, 1);
        assignToSubGroup(member2, gIdAfter1, 2);
        assignToSubGroup(member3, gIdAfter1, 3);
        assignToSubGroup(member4, gIdAfter1, 4);
        assignToSubGroup(member5, gIdAfter2, 1);
        assignToSubGroup(member6, gIdAfter2, 2);
        assignToSubGroup(member7, gIdAfter2, 3);
        assignToSubGroup(member8, gIdAfter2, 4);
        assignToSubGroup(member9, gIdAfter3, 1);
        assignToSubGroup(member10, gIdAfter3, 2);
        assignToSubGroup(member11, gIdAfter3, 3);
        assignToSubGroup(member12, gIdAfter3, 4);
        assignToSubGroup(member13, gIdAfter3, 5);

        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();

        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;

        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);
        joinToCommunity(member13, joinFee);
        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);

        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);

        skip(27 days);

        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;

        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member13, shouldJoin);
        payPremium(member13, pFee, currentPeriodIdAfter, false);
        skip(3 days);
        uint256 currentPeriodIdBefore2 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore2 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore2 + 1, currentPeriodIdAfter2);
        vm.startPrank(member12);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ExitedFromSubGroup(member12, gIdAfter3);
        tandaPay.exitSubGroup();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo2 = tandaPay.getMemberToMemberInfo(
            member12,
            currentPeriodIdAfter2
        );
        assertEq(
            uint8(mInfo2.status),
            uint8(TandaPayEvents.MemberStatus.PAID_INVALID)
        );
        assertEq(mInfo2.associatedGroupId, 0);
        vm.startPrank(member13);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ExitedFromSubGroup(member13, gIdAfter3);
        tandaPay.exitSubGroup();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo13 = tandaPay.getMemberToMemberInfo(
            member13,
            currentPeriodIdAfter2
        );
        assertEq(
            uint8(mInfo13.status),
            uint8(TandaPayEvents.MemberStatus.PAID_INVALID)
        );
        assertEq(mInfo13.associatedGroupId, 0);
    }

    function testIfMemberStatusChangeToValidIfItIsNotWhilePayingPremium2()
        public
    {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);
        addToCommunity(member13);

        uint256 gIdAfter1 = createASubGroup();
        uint256 gIdAfter2 = createASubGroup();
        uint256 gIdAfter3 = createASubGroup();

        assignToSubGroup(member1, gIdAfter1, 1);
        assignToSubGroup(member2, gIdAfter1, 2);
        assignToSubGroup(member3, gIdAfter1, 3);
        assignToSubGroup(member4, gIdAfter1, 4);
        assignToSubGroup(member5, gIdAfter2, 1);
        assignToSubGroup(member6, gIdAfter2, 2);
        assignToSubGroup(member7, gIdAfter2, 3);
        assignToSubGroup(member8, gIdAfter2, 4);
        assignToSubGroup(member9, gIdAfter3, 1);
        assignToSubGroup(member10, gIdAfter3, 2);
        assignToSubGroup(member11, gIdAfter3, 3);
        assignToSubGroup(member12, gIdAfter3, 4);
        assignToSubGroup(member13, gIdAfter3, 5);

        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();

        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;

        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);
        joinToCommunity(member13, joinFee);
        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);

        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);

        skip(27 days);

        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;

        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member13, shouldJoin);

        skip(3 days);
        uint256 currentPeriodIdBefore2 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberStatusUpdated(
            member1,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member2,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member3,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member4,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member5,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member6,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member7,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member8,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member9,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member10,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member11,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member12,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore2 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore2 + 1, currentPeriodIdAfter2);
        vm.startPrank(member12);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ExitedFromSubGroup(member12, gIdAfter3);
        tandaPay.exitSubGroup();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo2 = tandaPay.getMemberToMemberInfo(
            member12,
            currentPeriodIdAfter2
        );
        assertEq(
            uint8(mInfo2.status),
            uint8(TandaPayEvents.MemberStatus.PAID_INVALID)
        );
        assertEq(mInfo2.associatedGroupId, 0);
        vm.startPrank(member13);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ExitedFromSubGroup(member13, gIdAfter3);
        tandaPay.exitSubGroup();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo13 = tandaPay.getMemberToMemberInfo(
            member13,
            currentPeriodIdAfter2
        );
        assertEq(
            uint8(mInfo13.status),
            uint8(TandaPayEvents.MemberStatus.UNPAID_INVALID)
        );
        assertEq(mInfo13.associatedGroupId, 0);
        skip(27 days);
        assignToSubGroup(member13, gIdAfter3, 4);
        approveSubGroupAssignment(member13, shouldJoin);
        vm.startPrank(member13);
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            member13,
            currentPeriodIdAfter2 + 1
        );

        tandaPay.payPremium(true);
        mInfo = tandaPay.getMemberToMemberInfo(
            member13,
            currentPeriodIdAfter2 + 1
        );
        assertEq(uint8(mInfo.status), uint8(TandaPayEvents.MemberStatus.VALID));
        vm.stopPrank();
    }
    function testIfRevertIfTryingToSetUpSuccessorsInSamePeriod() public {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);

        uint256 gIdAfter1 = createASubGroup();
        uint256 gIdAfter2 = createASubGroup();
        uint256 gIdAfter3 = createASubGroup();

        assignToSubGroup(member1, gIdAfter1, 1);
        assignToSubGroup(member2, gIdAfter1, 2);
        assignToSubGroup(member3, gIdAfter1, 3);
        assignToSubGroup(member4, gIdAfter1, 4);
        assignToSubGroup(member5, gIdAfter2, 1);
        assignToSubGroup(member6, gIdAfter2, 2);
        assignToSubGroup(member7, gIdAfter2, 3);
        assignToSubGroup(member8, gIdAfter2, 4);
        assignToSubGroup(member9, gIdAfter3, 1);
        assignToSubGroup(member10, gIdAfter3, 2);
        assignToSubGroup(member11, gIdAfter3, 3);
        assignToSubGroup(member12, gIdAfter3, 4);

        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();
        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;

        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);

        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );

        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);
        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);
        skip(27 days);
        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;
        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);
        skip(3 days);
        successors.push(member1);
        successors.push(member2);
        successors.push(member3);
        successors.push(member4);
        successors.push(member5);

        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretarySuccessorsDefined(successors);
        tandaPay.defineSecretarySuccessor(successors);
        address[] memory secretarySuccessorList = tandaPay
            .getSecretarySuccessors();

        assertEq(secretarySuccessorList[0], successors[0]);
        assertEq(secretarySuccessorList[1], successors[1]);
        assertEq(secretarySuccessorList[2], successors[2]);
        assertEq(secretarySuccessorList[3], successors[3]);
        uint256 handoverStartTimeBefore = tandaPay
            .getEmergencyHandoverStartedAt();
        vm.startPrank(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.EmergencyhandOverSecretary(member3);
        tandaPay.emergencyHandOverSecretary(member3);
        vm.stopPrank();
        uint256 handoverStartTimeAfter = tandaPay
            .getEmergencyHandoverStartedAt();
        assertTrue(handoverStartTimeAfter > handoverStartTimeBefore);
        uint256 handoverStartPeriod = tandaPay
            .getEmergencyHandOverStartedPeriod();
        assertEq(handoverStartPeriod, currentPeriodIdAfter);
        address[2] memory emembergencySecretaries = tandaPay
            .getEmergencySecretaries();
        assertEq(emembergencySecretaries[0], member3);
        assertEq(emembergencySecretaries[1], address(0));
        vm.startPrank(member4);
        skip(2 days);
        vm.expectRevert(abi.encodeWithSelector(TandaPayErrors.SamePeriod.selector));
        tandaPay.emergencyHandOverSecretary(member2);
        vm.stopPrank();
    }

    function testIfTokenTransferFromSecretaryWhileSecretaryDivideShortFall()
        public
    {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);

        uint256 gIdAfter1 = createASubGroup();
        uint256 gIdAfter2 = createASubGroup();
        uint256 gIdAfter3 = createASubGroup();

        assignToSubGroup(member1, gIdAfter1, 1);
        assignToSubGroup(member2, gIdAfter1, 2);
        assignToSubGroup(member3, gIdAfter1, 3);
        assignToSubGroup(member4, gIdAfter1, 4);
        assignToSubGroup(member5, gIdAfter2, 1);
        assignToSubGroup(member6, gIdAfter2, 2);
        assignToSubGroup(member7, gIdAfter2, 3);
        assignToSubGroup(member8, gIdAfter2, 4);
        assignToSubGroup(member9, gIdAfter3, 1);
        assignToSubGroup(member10, gIdAfter3, 2);
        assignToSubGroup(member11, gIdAfter3, 3);
        assignToSubGroup(member12, gIdAfter3, 4);

        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();

        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;

        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);
        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);

        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);

        skip(27 days);

        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;

        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);

        skip(3 days);
        uint256 currentPeriodIdBefore2 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberStatusUpdated(
            member1,
            TandaPayEvents.MemberStatus.VALID
        );

        emit TandaPayEvents.MemberStatusUpdated(
            member2,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member3,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member4,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member5,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member6,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member7,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member8,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member9,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member10,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member11,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member12,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore2 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();

        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore2 + 1, currentPeriodIdAfter2);
        TandaPay.PeriodInfo memory pInfo2 = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter2
        );

        assertEq(pInfo2.startedAt + 30 days, pInfo2.willEndAt);
        skip(4 days);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundIssued();
        tandaPay.issueRefund(false);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        skip(23 days);

        payPremium(member2, pFee, currentPeriodIdAfter2, true);
        payPremium(member3, pFee, currentPeriodIdAfter2, true);
        payPremium(member4, pFee, currentPeriodIdAfter2, true);
        payPremium(member7, pFee, currentPeriodIdAfter2, true);
        payPremium(member8, pFee, currentPeriodIdAfter2, true);
        payPremium(member9, pFee, currentPeriodIdAfter2, true);
        payPremium(member10, pFee, currentPeriodIdAfter2, true);
        skip(3 days);
        uint256 currentPeriodIdBefore3 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberStatusUpdated(
            member1,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member2,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member3,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member4,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member5,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member6,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member7,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member8,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member9,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member10,
            TandaPayEvents.MemberStatus.VALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member11,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member12,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore3 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter3 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore3 + 1, currentPeriodIdAfter3);
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        vm.startPrank(member2);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member2, cIdBefore + 1);
        tandaPay.submitClaim();
        vm.stopPrank();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore + 1, cIdAfter);
        TandaPay.PeriodInfo memory pInfo3 = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter3
        );
        uint256 sAmount = pInfo3.coverage - pInfo3.totalPaid;
        uint256 validMCount;
        uint256 mvAmount;
        for (uint256 i = 1; i < tandaPay.getCurrentSubGroupId() + 1; i++) {
            TandaPay.SubGroupInfo memory sInfo = tandaPay
                .getSubGroupIdToSubGroupInfo(i);
            for (uint256 j = 0; j < sInfo.members.length; j++) {
                TandaPay.DemoMemberInfo memory mInfo = tandaPay
                    .getMemberToMemberInfo(
                        sInfo.members[j],
                        currentPeriodIdAfter3
                    );
                if (uint8(mInfo.status) == uint8(TandaPayEvents.MemberStatus.VALID)) {
                    validMCount++;
                    if (mInfo.ISEscorwAmount > 0) {
                        if (mvAmount != 0 && mInfo.ISEscorwAmount < mvAmount) {
                            mvAmount = mInfo.ISEscorwAmount;
                        } else if (mvAmount == 0) {
                            mvAmount = sAmount;
                        }
                    }
                }
            }
        }

        uint256 spMember = sAmount / validMCount < mvAmount
            ? sAmount / validMCount
            : mvAmount;
        uint256 secretaryAmount;
        if (spMember * validMCount < sAmount) {
            secretaryAmount = sAmount - (spMember * validMCount);
        }
        vm.expectEmit(address(paymentToken));
        emit IERC20.Transfer(address(this), address(tandaPay), secretaryAmount);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ShortFallDivided(
            sAmount,
            spMember,
            secretaryAmount
        );
        tandaPay.divideShortFall();
    }

    function testIfRevertIfClaimantIsNotValidMember() public {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);

        uint256 sgId1 = createASubGroup();
        uint256 sgId2 = createASubGroup();
        uint256 sgId3 = createASubGroup();

        assignToSubGroup(member1, sgId1, 1);
        assignToSubGroup(member2, sgId1, 2);
        assignToSubGroup(member3, sgId1, 3);
        assignToSubGroup(member4, sgId1, 4);
        assignToSubGroup(member5, sgId2, 1);
        assignToSubGroup(member6, sgId2, 2);
        assignToSubGroup(member7, sgId2, 3);
        assignToSubGroup(member8, sgId2, 4);
        assignToSubGroup(member9, sgId3, 1);
        assignToSubGroup(member10, sgId3, 2);
        assignToSubGroup(member11, sgId3, 3);
        assignToSubGroup(member12, sgId3, 4);

        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();
        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;

        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);

        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);
        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);

        skip(27 days);

        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;

        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);

        skip(3 days);
        uint256 currentPeriodIdBefore2 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore2 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore2 + 1, currentPeriodIdAfter2);
        skip(4 days);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundIssued();
        tandaPay.issueRefund(false);
        vm.startPrank(member1);
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member1, cIdBefore + 1);
        tandaPay.submitClaim();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore + 1, cIdAfter);
        vm.stopPrank();

        TandaPay.ClaimInfo memory cInfo = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdAfter);
        assertEq(cInfo.claimant, member1);
        assertFalse(cInfo.isWhitelistd);

        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimWhiteListed(cIdAfter);
        tandaPay.whitelistClaim(cIdAfter);
        cInfo = tandaPay.getPeriodIdToClaimIdToClaimInfo(
            currentPeriodIdAfter2,
            cIdAfter
        );
        assertTrue(cInfo.isWhitelistd);
        skip(23 days);

        payPremium(member1, pFee, currentPeriodIdAfter2, true);
        payPremium(member2, pFee, currentPeriodIdAfter2, true);
        payPremium(member3, pFee, currentPeriodIdAfter2, true);
        payPremium(member4, pFee, currentPeriodIdAfter2, true);
        payPremium(member5, pFee, currentPeriodIdAfter2, true);
        payPremium(member6, pFee, currentPeriodIdAfter2, true);
        payPremium(member7, pFee, currentPeriodIdAfter2, true);
        payPremium(member8, pFee, currentPeriodIdAfter2, true);
        payPremium(member9, pFee, currentPeriodIdAfter2, true);
        payPremium(member10, pFee, currentPeriodIdAfter2, true);
        payPremium(member11, pFee, currentPeriodIdAfter2, true);
        payPremium(member12, pFee, currentPeriodIdAfter2, true);
        skip(3 days);
        uint256 currentPeriodIdBefore3 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore3 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter3 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore3 + 1, currentPeriodIdAfter3);

        TandaPay.CommunityStates states2 = tandaPay.getCommunityState();
        assertEq(uint8(states2), uint8(TandaPay.CommunityStates.DEFAULT));
        skip(4 days);
        uint256[] memory __ids = tandaPay.getPeriodIdToClaimIds(
            currentPeriodIdAfter2
        );
        uint256 wlCount;
        for (uint256 i = 0; i < __ids.length; i++) {
            if (cInfo.isWhitelistd) {
                wlCount++;
            }
        }
        vm.startPrank(cInfo.claimant);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ExitedFromSubGroup(cInfo.claimant, sgId1);
        tandaPay.exitSubGroup();
        skip(13 days); // skip 13 here so we don't skip too far for exitSubGroup to fail
        vm.expectRevert(
            abi.encodeWithSelector(TandaPayErrors.ClaimantNotValidMember.selector)
        );
        tandaPay.withdrawClaimFund(false);
        vm.stopPrank();
    }

    function testIfCanBeTransferTokenWhileIssuingRefund() public {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);

        uint256 sgId1 = createASubGroup();
        uint256 sgId2 = createASubGroup();
        uint256 sgId3 = createASubGroup();

        assignToSubGroup(member1, sgId1, 1);
        assignToSubGroup(member2, sgId1, 2);
        assignToSubGroup(member3, sgId1, 3);
        assignToSubGroup(member4, sgId1, 4);
        assignToSubGroup(member5, sgId2, 1);
        assignToSubGroup(member6, sgId2, 2);
        assignToSubGroup(member7, sgId2, 3);
        assignToSubGroup(member8, sgId2, 4);
        assignToSubGroup(member9, sgId3, 1);
        assignToSubGroup(member10, sgId3, 2);
        assignToSubGroup(member11, sgId3, 3);
        assignToSubGroup(member12, sgId3, 4);

        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();

        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;

        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);

        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();

        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);
        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);

        skip(27 days);

        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;

        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);

        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);

        skip(3 days);
        uint256 currentPeriodIdBefore2 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore2 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore2 + 1, currentPeriodIdAfter2);
        skip(4 days);

        tandaPay.issueRefund(true);
    }

    function testIfRevertIfNotInPaidInvalidWhileAssigningReorgedMember()
        public
    {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);

        uint256 gIdAfter1 = createASubGroup();
        uint256 gIdAfter2 = createASubGroup();
        uint256 gIdAfter3 = createASubGroup();

        assignToSubGroup(member1, gIdAfter1, 1);
        assignToSubGroup(member2, gIdAfter1, 2);
        assignToSubGroup(member3, gIdAfter1, 3);
        assignToSubGroup(member4, gIdAfter1, 4);
        assignToSubGroup(member5, gIdAfter2, 1);
        assignToSubGroup(member6, gIdAfter2, 2);
        assignToSubGroup(member7, gIdAfter2, 3);
        assignToSubGroup(member8, gIdAfter2, 4);
        assignToSubGroup(member9, gIdAfter3, 1);
        assignToSubGroup(member10, gIdAfter3, 2);
        assignToSubGroup(member11, gIdAfter3, 3);
        assignToSubGroup(member12, gIdAfter3, 4);
        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();
        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;
        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);
        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );

        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);
        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);
        skip(27 days);
        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;
        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);
        skip(3 days);
        uint256 currentPeriodIdBefore2 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore2 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore2 + 1, currentPeriodIdAfter2);
        TandaPay.PeriodInfo memory pInfo2 = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter2
        );
        assertEq(pInfo2.startedAt + 30 days, pInfo2.willEndAt);
        vm.expectRevert(
            abi.encodeWithSelector(TandaPayErrors.NotPaidInvalid.selector)
        );
        tandaPay.assignToSubGroup(member1, gIdAfter3, true);
    }

    function testIfTokenTransferFromMemberToTandaPayWhilePayingPremium()
        public
    {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);

        uint256 gIdAfter1 = createASubGroup();
        uint256 gIdAfter2 = createASubGroup();
        uint256 gIdAfter3 = createASubGroup();

        assignToSubGroup(member1, gIdAfter1, 1);
        assignToSubGroup(member2, gIdAfter1, 2);
        assignToSubGroup(member3, gIdAfter1, 3);
        assignToSubGroup(member4, gIdAfter1, 4);
        assignToSubGroup(member5, gIdAfter2, 1);
        assignToSubGroup(member6, gIdAfter2, 2);
        assignToSubGroup(member7, gIdAfter2, 3);
        assignToSubGroup(member8, gIdAfter2, 4);
        assignToSubGroup(member9, gIdAfter3, 1);
        assignToSubGroup(member10, gIdAfter3, 2);
        assignToSubGroup(member11, gIdAfter3, 3);
        assignToSubGroup(member12, gIdAfter3, 4);
        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();
        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;
        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);
        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );

        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);
        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);
        skip(27 days);
        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;
        approveSubGroupAssignment(member1, shouldJoin);
        vm.startPrank(member1);
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            member1,
            currentPeriodIdAfter + 1
        );
        vm.expectEmit(address(paymentToken));
        emit IERC20.Transfer(
            member1,
            address(tandaPay),
            false
                ? mInfo.availableToWithdraw >
                    basePremium + (pFee - mInfo.ISEscorwAmount)
                    ? 0
                    : basePremium +
                        (pFee - mInfo.ISEscorwAmount) -
                        mInfo.availableToWithdraw
                : basePremium + (pFee - mInfo.ISEscorwAmount)
        );
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.PremiumPaid(
            member1,
            currentPeriodIdAfter,
            false
                ? mInfo.availableToWithdraw >
                    basePremium + (pFee - mInfo.ISEscorwAmount)
                    ? 0
                    : basePremium +
                        (pFee - mInfo.ISEscorwAmount) -
                        mInfo.availableToWithdraw
                : basePremium + (pFee - mInfo.ISEscorwAmount),
            false
        );
        tandaPay.payPremium(false);
        mInfo = tandaPay.getMemberToMemberInfo(
            member1,
            currentPeriodIdAfter + 1
        );
        assertTrue(mInfo.eligibleForCoverageInPeriod);
        assertTrue(mInfo.isPremiumPaid);
        assertEq(mInfo.cEscrowAmount, basePremium);
        assertEq(mInfo.ISEscorwAmount, pFee);
        vm.stopPrank();
    }

    function testIfDefectedMembersPremiumDistributedProperlyWhileWithdrawingClaimFundByClaimant()
        public
    {
        addToCommunity(member1);
        addToCommunity(member2);
        addToCommunity(member3);
        addToCommunity(member4);
        addToCommunity(member5);
        addToCommunity(member6);
        addToCommunity(member7);
        addToCommunity(member8);
        addToCommunity(member9);
        addToCommunity(member10);
        addToCommunity(member11);
        addToCommunity(member12);

        uint256 sgId1 = createASubGroup();
        uint256 sgId2 = createASubGroup();
        uint256 sgId3 = createASubGroup();

        assignToSubGroup(member1, sgId1, 1);
        assignToSubGroup(member2, sgId1, 2);
        assignToSubGroup(member3, sgId1, 3);
        assignToSubGroup(member4, sgId1, 4);
        assignToSubGroup(member5, sgId2, 1);
        assignToSubGroup(member6, sgId2, 2);
        assignToSubGroup(member7, sgId2, 3);
        assignToSubGroup(member8, sgId2, 4);
        assignToSubGroup(member9, sgId3, 1);
        assignToSubGroup(member10, sgId3, 2);
        assignToSubGroup(member11, sgId3, 3);
        assignToSubGroup(member12, sgId3, 4);

        uint256 coverage = 12e18;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverage = tandaPay.getTotalCoverage();
        assertEq(currentCoverage, coverage);
        uint256 currentMemberId = tandaPay.getCurrentMemberId();
        basePremium = tandaPay.getBasePremium();
        assertEq(basePremium, currentCoverage / currentMemberId);
        uint256 bPAmount = tandaPay.getBasePremium();
        uint256 joinFee = ((bPAmount + (bPAmount * 20) / 100) * 11) / 12;

        joinToCommunity(member1, joinFee);
        joinToCommunity(member2, joinFee);
        joinToCommunity(member3, joinFee);
        joinToCommunity(member4, joinFee);
        joinToCommunity(member5, joinFee);
        joinToCommunity(member6, joinFee);
        joinToCommunity(member7, joinFee);
        joinToCommunity(member8, joinFee);
        joinToCommunity(member9, joinFee);
        joinToCommunity(member10, joinFee);
        joinToCommunity(member11, joinFee);
        joinToCommunity(member12, joinFee);

        uint256 currentPeriodIdBefore = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore + 1, currentPeriodIdAfter);
        TandaPay.PeriodInfo memory pInfo = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter
        );
        assertEq(pInfo.startedAt + 30 days, pInfo.willEndAt);

        skip(27 days);

        basePremium = tandaPay.getBasePremium();
        uint256 pFee = basePremium + ((basePremium * 20) / 100);
        bool shouldJoin = true;

        approveSubGroupAssignment(member1, shouldJoin);
        payPremium(member1, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member2, shouldJoin);
        payPremium(member2, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member3, shouldJoin);
        payPremium(member3, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member4, shouldJoin);
        payPremium(member4, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member5, shouldJoin);
        payPremium(member5, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member6, shouldJoin);
        payPremium(member6, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member7, shouldJoin);
        payPremium(member7, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member8, shouldJoin);
        payPremium(member8, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member9, shouldJoin);
        payPremium(member9, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member10, shouldJoin);
        payPremium(member10, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member11, shouldJoin);
        payPremium(member11, pFee, currentPeriodIdAfter, false);
        approveSubGroupAssignment(member12, shouldJoin);
        payPremium(member12, pFee, currentPeriodIdAfter, false);

        skip(3 days);
        uint256 currentPeriodIdBefore2 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.NextPeriodInitiated(
            currentPeriodIdBefore2 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore2 + 1, currentPeriodIdAfter2);
        skip(4 days);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundIssued();
        tandaPay.issueRefund(false);
        vm.startPrank(member1);
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member1, cIdBefore + 1);
        tandaPay.submitClaim();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore + 1, cIdAfter);
        vm.stopPrank();

        TandaPay.ClaimInfo memory cInfo = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdAfter);
        assertEq(cInfo.claimant, member1);
        assertFalse(cInfo.isWhitelistd);

        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimWhiteListed(cIdAfter);
        tandaPay.whitelistClaim(cIdAfter);
        cInfo = tandaPay.getPeriodIdToClaimIdToClaimInfo(
            currentPeriodIdAfter2,
            cIdAfter
        );
        assertTrue(cInfo.isWhitelistd);
        vm.startPrank(member2);
        uint256 cIdBefore2 = tandaPay.getCurrentClaimId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member2, cIdBefore2 + 1);
        tandaPay.submitClaim();
        uint256 cIdAfter2 = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore2 + 1, cIdAfter2);
        vm.stopPrank();

        TandaPay.ClaimInfo memory cInfo2 = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdAfter2);
        assertEq(cInfo2.claimant, member2);
        assertFalse(cInfo2.isWhitelistd);

        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimWhiteListed(cIdAfter2);
        tandaPay.whitelistClaim(cIdAfter2);
        cInfo2 = tandaPay.getPeriodIdToClaimIdToClaimInfo(
            currentPeriodIdAfter2,
            cIdAfter2
        );
        assertTrue(cInfo2.isWhitelistd);
        skip(23 days);

        payPremium(member1, pFee, currentPeriodIdAfter2, true);
        payPremium(member2, pFee, currentPeriodIdAfter2, true);
        payPremium(member7, pFee, currentPeriodIdAfter2, true);
        payPremium(member8, pFee, currentPeriodIdAfter2, true);
        payPremium(member11, pFee, currentPeriodIdAfter2, true);
        skip(3 days);
        uint256 currentPeriodIdBefore3 = tandaPay.getPeriodId();
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter3 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore3 + 1, currentPeriodIdAfter3);
        TandaPay.CommunityStates states2 = tandaPay.getCommunityState();
        assertEq(uint8(states2), uint8(TandaPay.CommunityStates.DEFAULT));
        vm.startPrank(member3);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberDefected(member3, currentPeriodIdAfter3);
        tandaPay.defects();
        vm.stopPrank();
        vm.startPrank(member12);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberDefected(member12, currentPeriodIdAfter3);
        tandaPay.defects();
        vm.stopPrank();
        skip(17 days);
        uint256[] memory __ids = tandaPay.getPeriodIdToClaimIds(
            currentPeriodIdAfter2
        );
        uint256 wlCount;
        for (uint256 i = 0; i < __ids.length; i++) {
            TandaPay.ClaimInfo memory cInfos = tandaPay
                .getPeriodIdToClaimIdToClaimInfo(
                    currentPeriodIdAfter2,
                    __ids[i]
                );
            if (cInfos.isWhitelistd) {
                wlCount++;
            }
        }
        TandaPay.ClaimInfo memory cInfoW = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdAfter);

        vm.startPrank(cInfoW.claimant);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.CommunityCollapsed(block.timestamp);
        tandaPay.withdrawClaimFund(false);
        vm.stopPrank();
        TandaPay.CommunityStates states3 = tandaPay.getCommunityState();
        assertEq(uint8(states3), uint8(TandaPay.CommunityStates.COLLAPSED));
    }
}
