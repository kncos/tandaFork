// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TandaPay} from "../../src/TandaPay.sol";
import {Secretary} from "../../src/secretary.sol";
import {TandaPayEvents} from "../../src/util/TandaPayEvents.sol";
import {TandaPayFactory} from "../../src/tandaPayFactory.sol";
import {TandaPayErrors} from "../../src/util/TandaPayErrors.sol";
import {Token, IERC20} from "../../src/mock/Token.sol";

contract TandaPayTest is Test {
    TandaPay public tandaPay;
    TandaPayFactory public factory;
    Token public paymentToken;
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
    address public member14 = address(14);
    address public member15 = address(15);
    address public member16 = address(16);
    address public member17 = address(17);
    address public member18 = address(18);
    address public member19 = address(19);
    address public member20 = address(20);
    address public member21 = address(21);
    address public member22 = address(22);
    address public member23 = address(23);
    address public member24 = address(24);
    address public member25 = address(25);
    address public member26 = address(26);
    address public member27 = address(27);
    address public member28 = address(28);
    address public member29 = address(29);
    address public member30 = address(30);
    address public member31 = address(31);
    address public member32 = address(32);
    address public member33 = address(33);
    address public member34 = address(34);
    address public member35 = address(35);
    address public member36 = address(36);
    address public NotMember = address(99);
    address[] public addss;
    address[] public successors;
    uint256 public basePremium;
    function setUp() public {
        paymentToken = new Token(address(this));
        factory = new TandaPayFactory();
        address community = factory.createCommunity(address(paymentToken)); 
        tandaPay = TandaPay(community);
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
        paymentToken.transfer(member14, 1000e18);
        paymentToken.transfer(member15, 1000e18);
        paymentToken.transfer(member16, 1000e18);
        paymentToken.transfer(member17, 1000e18);
        paymentToken.transfer(member18, 1000e18);
        paymentToken.transfer(member19, 1000e18);
        paymentToken.transfer(member20, 1000e18);
        paymentToken.transfer(member21, 1000e18);
        paymentToken.transfer(member22, 1000e18);
        paymentToken.transfer(member23, 1000e18);
        paymentToken.transfer(member24, 1000e18);
        paymentToken.transfer(member25, 1000e18);
        paymentToken.transfer(member26, 1000e18);
        paymentToken.transfer(member27, 1000e18);
        paymentToken.transfer(member28, 1000e18);
        paymentToken.transfer(member29, 1000e18);
        paymentToken.transfer(member30, 1000e18);
        paymentToken.transfer(member31, 1000e18);
        paymentToken.transfer(member32, 1000e18);
        paymentToken.transfer(member33, 1000e18);
        paymentToken.transfer(member34, 1000e18);
        paymentToken.transfer(member35, 1000e18);
        paymentToken.transfer(member36, 1000e18);
    }

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

    function payPremiumSimple(
        address _member,
        bool _fromATW
    ) public {
        vm.startPrank(_member);
        
        tandaPay.payPremium(_fromATW);
        
        vm.stopPrank();
    }

    function advanceThrice() public {
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
        
        
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter2 = tandaPay.getPeriodId();
        
        skip(4 days);
        
        tandaPay.issueRefund(false);
    
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
        
        
        tandaPay.AdvanceToTheNextPeriod();
        currentPeriodIdAfter2 = tandaPay.getPeriodId();

        skip(4 days);
        
        tandaPay.issueRefund(false);
    
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
        
        
        tandaPay.AdvanceToTheNextPeriod();
        currentPeriodIdAfter2 = tandaPay.getPeriodId();

        skip(4 days);
        
        tandaPay.issueRefund(false);
    
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
        
        
        tandaPay.AdvanceToTheNextPeriod();
        currentPeriodIdAfter2 = tandaPay.getPeriodId();

        skip(4 days);
        
        tandaPay.issueRefund(false);
    
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
        
        
        tandaPay.AdvanceToTheNextPeriod();
    }

    function createSetup() public {
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
    }

    function testFactory() external {
        address community2 = factory.createCommunity(address(paymentToken));
        address community3 = factory.createCommunity(address(paymentToken));
        address community4 = factory.createCommunity(address(paymentToken));
        address community5 = factory.createCommunity(address(paymentToken));

        address com = factory.TandaPayCommunities(0);
        address com2 = factory.TandaPayCommunities(1);
        address com3 = factory.TandaPayCommunities(2);
        address com4 = factory.TandaPayCommunities(3);
        address com5 = factory.TandaPayCommunities(4);
        assertEq(com, address(tandaPay));
        assertEq(com2, community2);
        assertEq(com3, community3);
        assertEq(com4, community4);
        assertEq(com5, community5);
    }

    function testEmergencyStart()
        public
    {
        createSetup();
        
        vm.prank(member11);
        vm.expectRevert(
            abi.encodeWithSelector(
                Secretary.SecretaryUnauthorizedSecretary.selector,
                member11
            )
        );
        tandaPay.beginEmergency();

        tandaPay.beginEmergency();
        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.beginEmergency();
        TandaPay.CommunityStates state = tandaPay.getCommunityState();
        assertEq(uint256(state), uint256(TandaPay.CommunityStates.EMERGENCY));
    }

    function testCannotEmergencyWithdrawUntil24Hours() external {
        createSetup();
        tandaPay.beginEmergency();
        vm.expectRevert(abi.encodePacked(TandaPayErrors.EmergencyGracePeriod.selector));
        tandaPay.EmergencyWithdrawal(member2, 100);

    }

    function testCannotEndEmergencyEarly() external {
        createSetup();
        tandaPay.beginEmergency();
        vm.expectRevert(abi.encodePacked(TandaPayErrors.EmergencyGracePeriod.selector));
        tandaPay.endEmergency();

        vm.prank(member11);
        vm.expectRevert(
            abi.encodeWithSelector(
                Secretary.SecretaryUnauthorizedSecretary.selector,
                member11
            )
        );
        tandaPay.endEmergency();
    }

    function testEmergencyWithdrawal() external {
        advanceThrice();
        tandaPay.beginEmergency();
        skip(24 hours);
        uint256 bal = paymentToken.balanceOf(address(tandaPay));
        tandaPay.EmergencyWithdrawal(address(50), bal);
        vm.prank(member1);
        vm.expectRevert();
        tandaPay.withdrawRefund();
    }

    function testEmergencyWithdrawalPartial() external {
        advanceThrice();
        tandaPay.beginEmergency();
        skip(24 hours);
        uint256 bal = paymentToken.balanceOf(address(tandaPay));
        tandaPay.EmergencyWithdrawal(address(50), bal/2);
        vm.prank(member1);
        tandaPay.withdrawRefund();
        vm.prank(member2);
        tandaPay.withdrawRefund();
        vm.prank(member3);
        tandaPay.withdrawRefund();
        vm.prank(member4);
        tandaPay.withdrawRefund();
        vm.prank(member5);
        tandaPay.withdrawRefund();
        vm.prank(member6);
        tandaPay.withdrawRefund();
        vm.prank(member7);
        vm.expectRevert();
        tandaPay.withdrawRefund();
    }

    function testEndEmergency() external {
        advanceThrice();
        tandaPay.beginEmergency();
        skip(24 hours);
        uint256 bal = paymentToken.balanceOf(address(tandaPay));
        tandaPay.EmergencyWithdrawal(address(50), bal);
        
        vm.prank(member7);
        vm.expectRevert();
        tandaPay.withdrawRefund();
        
        tandaPay.endEmergency();

        TandaPay.CommunityStates state = tandaPay.getCommunityState();
        assertEq(uint256(state), uint256(TandaPay.CommunityStates.COLLAPSED));
        
    }

    function testUserWithdrawAfterEndEmergency() external {
        advanceThrice();
        tandaPay.beginEmergency();
        skip(24 hours);
        uint256 bal = paymentToken.balanceOf(address(tandaPay));
        tandaPay.EmergencyWithdrawal(address(50), bal/2);
        tandaPay.endEmergency();

        vm.prank(member1);
        tandaPay.withdrawRefund();
        vm.prank(member2);
        tandaPay.withdrawRefund();
        vm.prank(member3);
        tandaPay.withdrawRefund();
        vm.prank(member4);
        tandaPay.withdrawRefund();
        vm.prank(member5);
        tandaPay.withdrawRefund();
        vm.prank(member6);
        tandaPay.withdrawRefund();
        
        vm.prank(member7);
        vm.expectRevert();
        tandaPay.withdrawRefund();
        
        TandaPay.CommunityStates state = tandaPay.getCommunityState();
        assertEq(uint256(state), uint256(TandaPay.CommunityStates.COLLAPSED));
        
    }

    function testEmergencyEndWithDust() external {
        advanceThrice();
        tandaPay.beginEmergency();
        skip(24 hours);
        uint256 bal = paymentToken.balanceOf(address(tandaPay));
        tandaPay.EmergencyWithdrawal(address(50), bal - bal / 100);
        
        vm.prank(member7);
        vm.expectRevert();
        tandaPay.withdrawRefund();

        uint256 balPrev = paymentToken.balanceOf(address(this));
        tandaPay.endEmergency();
        uint256 balOwner = paymentToken.balanceOf(address(this));
        assertEq(balOwner, balPrev + (bal / 100));
    }

    function testCannotDoAnythingButWithdrawAfterCollapse() external {
        createSetup();
        tandaPay.beginEmergency();
        skip(24 hours);
        uint256 bal = paymentToken.balanceOf(address(tandaPay));
        tandaPay.EmergencyWithdrawal(address(50), bal / 2);
        tandaPay.endEmergency();
        
        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.addToCommunity(address(50));

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.createSubGroup();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.assignToSubGroup(address(50), 2, true);

        vm.prank(address(50));
        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.joinToCommunity();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.initiatDefaultStateAndSetCoverage(2999);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.approveSubGroupAssignment(true);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.approveNewSubgroupMember(1, 2, true);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.exitSubGroup();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.whitelistClaim(2999);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.defects();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.payPremium(true);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.updateCoverageAmount(29992);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        address[] memory addy= new address[](1);
        addy[0] = address(55);
        tandaPay.defineSecretarySuccessor(addy);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.handoverSecretary(address(55));

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.secretaryAcceptance();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.emergencyHandOverSecretary(address(55));

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.injectFunds();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.divideShortFall();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.addAdditionalDay();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.manualCollapsBySecretary();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.leaveFromASubGroup();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.beginEmergency();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.AdvanceToTheNextPeriod();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.updateMemberStatus();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.withdrawClaimFund(true);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.CommunityIsCollapsed.selector));
        tandaPay.submitClaim();

        vm.prank(member1);
        tandaPay.withdrawRefund();
        vm.prank(member2);
        tandaPay.withdrawRefund();
        vm.prank(member3);
        tandaPay.withdrawRefund();
        vm.prank(member4);
        tandaPay.withdrawRefund();
        vm.prank(member5);
        tandaPay.withdrawRefund();
        vm.prank(member6);
        tandaPay.withdrawRefund();
        vm.expectRevert();
        vm.prank(member7);
        tandaPay.withdrawRefund();
        
        bal = paymentToken.balanceOf(address(tandaPay));
        assertEq(bal, 0);
    }

    function testCannotDoAnythingButWithdrawDuringEmergency() external {
        createSetup();
        tandaPay.beginEmergency();
        
        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.addToCommunity(address(50));

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.createSubGroup();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.assignToSubGroup(address(50), 2, true);

        vm.prank(address(50));
        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.joinToCommunity();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.initiatDefaultStateAndSetCoverage(2999);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.approveSubGroupAssignment(true);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.approveNewSubgroupMember(1, 2, true);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.exitSubGroup();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.whitelistClaim(2999);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.defects();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.payPremium(true);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.updateCoverageAmount(29992);

        address[] memory addy= new address[](1);
        addy[0] = address(55);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.injectFunds();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.divideShortFall();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.addAdditionalDay();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.manualCollapsBySecretary();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.cancelManualCollapsBySecretary();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.leaveFromASubGroup();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.beginEmergency();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.AdvanceToTheNextPeriod();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.updateMemberStatus();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.withdrawClaimFund(true);

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.submitClaim();

        vm.expectRevert(abi.encodePacked(TandaPayErrors.InEmergency.selector));
        tandaPay.issueRefund(true);

        vm.prank(member1);
        tandaPay.withdrawRefund();
        vm.prank(member2);
        tandaPay.withdrawRefund();
        vm.prank(member3);
        tandaPay.withdrawRefund();
        vm.prank(member4);
        tandaPay.withdrawRefund();
        vm.prank(member5);
        tandaPay.withdrawRefund();
        vm.prank(member6);
        tandaPay.withdrawRefund();
        vm.prank(member7);
        tandaPay.withdrawRefund();
        vm.prank(member8);
        tandaPay.withdrawRefund();
        vm.prank(member9);
        tandaPay.withdrawRefund();
        vm.prank(member10);
        tandaPay.withdrawRefund();
        vm.prank(member11);
        tandaPay.withdrawRefund();
        vm.prank(member12);
        tandaPay.withdrawRefund();
        uint256 bal = paymentToken.balanceOf(address(tandaPay));
        assertEq(bal, 0);
    }

    function testEmergencyRefundPeriodAbove3() external {
        advanceThrice();
        tandaPay.beginEmergency();
        vm.prank(member1);
        tandaPay.withdrawRefund();
        vm.prank(member2);
        tandaPay.withdrawRefund();
        vm.prank(member3);
        tandaPay.withdrawRefund();
        vm.prank(member4);
        tandaPay.withdrawRefund();
        vm.prank(member5);
        tandaPay.withdrawRefund();
        vm.prank(member6);
        tandaPay.withdrawRefund();
        vm.prank(member7);
        tandaPay.withdrawRefund();
        vm.prank(member8);
        tandaPay.withdrawRefund();
        vm.prank(member9);
        tandaPay.withdrawRefund();
        vm.prank(member10);
        tandaPay.withdrawRefund();
        vm.prank(member11);
        tandaPay.withdrawRefund();
        vm.prank(member12);
        tandaPay.withdrawRefund();
        uint256 bal = paymentToken.balanceOf(address(tandaPay));
        assertEq(bal, 0);
    }

    function testClaimRelinquishmentNoPayments() public {
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

        skip(15 days);
        uint256 balBefore = paymentToken.balanceOf(address(tandaPay));
        vm.startPrank(cInfo.claimant);
        
        tandaPay.withdrawClaimFund(true);
        vm.stopPrank();
        uint256 balAfter = paymentToken.balanceOf(address(tandaPay));
        assertEq(balBefore, balAfter);
        skip(15 days);
        tandaPay.AdvanceToTheNextPeriod();
        skip(3 days);
        tandaPay.emergencyRefund();
        
        vm.prank(member1);
        tandaPay.withdrawRefund();
        vm.prank(member2);
        tandaPay.withdrawRefund();
        vm.prank(member3);
        tandaPay.withdrawRefund();
        vm.prank(member4);
        tandaPay.withdrawRefund();
        vm.prank(member5);
        tandaPay.withdrawRefund();
        vm.prank(member6);
        tandaPay.withdrawRefund();
        vm.prank(member7);
        tandaPay.withdrawRefund();
        vm.prank(member8);
        tandaPay.withdrawRefund();
        vm.prank(member9);
        tandaPay.withdrawRefund();
        vm.prank(member10);
        tandaPay.withdrawRefund();
        vm.prank(member11);
        tandaPay.withdrawRefund();
        vm.prank(member12);
        tandaPay.withdrawRefund();
    }

    function testClaimRelinquishment() public {
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

        skip(15 days);
        uint256 balBefore = paymentToken.balanceOf(address(tandaPay));
        vm.startPrank(cInfo.claimant);
        
        tandaPay.withdrawClaimFund(true);
        vm.expectRevert(abi.encodePacked(TandaPayErrors.AlreadyClaimed.selector));
        tandaPay.withdrawClaimFund(false);
        vm.stopPrank();
        uint256 balAfter = paymentToken.balanceOf(address(tandaPay));
        assertEq(balBefore, balAfter);
        skip(8 days);
        payPremiumSimple(member1, true);
        payPremiumSimple(member2, true);
        payPremiumSimple(member3, true);
        payPremiumSimple(member4, true);
        payPremiumSimple(member5, true);
        payPremiumSimple(member6, true);
        payPremiumSimple(member7, true);
        payPremiumSimple(member8, true);
        payPremiumSimple(member9, true);
        payPremiumSimple(member10, true);
        payPremiumSimple(member11, true);
        payPremiumSimple(member12, true);
        skip(8 days);
        tandaPay.AdvanceToTheNextPeriod();
        skip(3 days);
        tandaPay.issueRefund(false);
        
    }
}