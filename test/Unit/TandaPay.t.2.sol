// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TandaPay} from "../../src/TandaPay.sol";
import {Secretary} from "../../src/secretary.sol";
import {TandaPayEvents} from "../../src/util/TandaPayEvents.sol";

import {TandaPayErrors} from "../../src/util/TandaPayErrors.sol";
import {Token, IERC20} from "../../src/mock/Token.sol";

contract TandaPayTest is Test {
    TandaPay public tandaPay;
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

    function testIfgetPaymentTokenFunctionProvidesCorrectPaymentTokenAddress()
        public
        view
    {
        address currentPaymentToken = tandaPay.getPaymentToken();
        assertEq(currentPaymentToken, address(paymentToken));
    }

    function testIfgetCurrentMemberIdFunctionProvidesCorrectMemberId() public {
        uint256 currentMemberId1Before = tandaPay.getCurrentMemberId();
        assertEq(currentMemberId1Before, 0);
        addToCommunity(member1);
        uint256 currentMemberId1After = tandaPay.getCurrentMemberId();
        assertEq(currentMemberId1After, 1);
        assertEq(currentMemberId1After, currentMemberId1Before + 1);
    }

    function testIfgetCurrentSubGroupIdFunctionProvidesCorrectSubGroupId()
        public
    {
        uint256 currentSubGroupId1Before = tandaPay.getCurrentSubGroupId();
        assertEq(currentSubGroupId1Before, 0);
        tandaPay.createSubGroup();
        uint256 currentSubGroupId1After = tandaPay.getCurrentSubGroupId();
        assertEq(currentSubGroupId1After, 1);
        assertEq(currentSubGroupId1After, currentSubGroupId1Before + 1);
    }

    function testIfgetCurrentClaimIdFunctionWorksProperly() public {
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
        vm.startPrank(member1);
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member1, cIdBefore + 1);
        tandaPay.submitClaim();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore, 0);
        assertEq(cIdAfter, 1);
        assertEq(cIdBefore + 1, cIdAfter);
        vm.stopPrank();
    }

    function testIfgetPeriodIdFunctionWorksProperly() public {
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
        assertEq(currentPeriodIdBefore, 0);
        assertEq(currentPeriodIdAfter, 1);
    }

    function testIfgetTotalCoverageFunctionWorksProperly() public {
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
        uint256 currentCoverageBefore = tandaPay.getTotalCoverage();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.DefaultStateInitiatedAndCoverageSet(coverage);
        tandaPay.initiatDefaultStateAndSetCoverage(coverage);
        TandaPay.CommunityStates states = tandaPay.getCommunityState();
        assertEq(uint8(states), uint8(TandaPay.CommunityStates.DEFAULT));
        uint256 currentCoverageAfter = tandaPay.getTotalCoverage();
        assertEq(currentCoverageAfter, coverage);
        assertEq(currentCoverageBefore, 0);
        assertEq(currentCoverageBefore + coverage, currentCoverageAfter);
    }

    function testIfgetBasePremiumFunctionWorksProperly() public {
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

        uint256 basePremiumBefore = tandaPay.getBasePremium();
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
        assertEq(basePremiumBefore, 0);
        assertEq(
            basePremium,
            basePremiumBefore + (currentCoverage / currentMemberId)
        );
    }

    function testIfgetManuallyCollapsedPeriodFunctionWorksProperly() public {
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

        uint256 collapsedPeriodIdBefore = tandaPay.getManuallyCollapsedPeriod();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ManualCollapsedHappenend();
        tandaPay.manualCollapsBySecretary();
        bool isCollapsed = tandaPay.getIsManuallyCollapsed();
        assertTrue(isCollapsed);
        TandaPay.CommunityStates states2 = tandaPay.getCommunityState();
        assertEq(uint8(states2), uint8(TandaPay.CommunityStates.COLLAPSED));
        uint256 collapsedPeriodId = tandaPay.getManuallyCollapsedPeriod();
        assertEq(collapsedPeriodId, currentPeriodIdAfter);
        assertEq(collapsedPeriodIdBefore, 0);
    }

    function testIfgetIsManuallyCollapsedFunctionsWorksProperly() public {
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

        bool isCollapsedBefore = tandaPay.getIsManuallyCollapsed();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ManualCollapsedHappenend();
        tandaPay.manualCollapsBySecretary();
        bool isCollapsed = tandaPay.getIsManuallyCollapsed();
        assertTrue(isCollapsed);
        assertEq(isCollapsedBefore, false);
        assertEq(isCollapsed, true);
    }

    function testgetCommunityStateFunctionWorksProperly() public {
        TandaPay.CommunityStates states0 = tandaPay.getCommunityState();
        assertEq(
            uint8(states0),
            uint8(TandaPay.CommunityStates.INITIALIZATION)
        );
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
    }

    function testIfgetSubGroupIdToSubGroupInfoFunctionWorksProperly() public {
        TandaPay.SubGroupInfo memory sInfo0 = tandaPay
            .getSubGroupIdToSubGroupInfo(1);
        assertEq(sInfo0.id, 0);
        assertEq(sInfo0.members.length, 0);
        assertFalse(sInfo0.isValid);
        uint256 sIdBefore = tandaPay.getCurrentSubGroupId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SubGroupCreated(sIdBefore + 1);
        tandaPay.createSubGroup();
        uint256 sIdAfter = tandaPay.getCurrentSubGroupId();
        assertEq(sIdAfter, sIdBefore + 1);
        TandaPay.SubGroupInfo memory sInfo = tandaPay
            .getSubGroupIdToSubGroupInfo(sIdAfter);
        assertEq(sInfo.id, sIdAfter);
        assertEq(sInfo.members.length, 0);
        assertFalse(sInfo.isValid);
        addToCommunity(member1);
        assignToSubGroup(member1, sIdAfter, 1);
        sInfo = tandaPay.getSubGroupIdToSubGroupInfo(sIdAfter);
        assertEq(sInfo.id, sIdAfter);
        assertEq(sInfo.members.length, 1);
        assertFalse(sInfo.isValid);
        addToCommunity(member2);
        assignToSubGroup(member2, sIdAfter, 2);
        addToCommunity(member3);
        assignToSubGroup(member3, sIdAfter, 3);
        addToCommunity(member4);
        assignToSubGroup(member4, sIdAfter, 4);
        sInfo = tandaPay.getSubGroupIdToSubGroupInfo(sIdAfter);
        assertEq(sInfo.id, sIdAfter);
        assertEq(sInfo.members.length, 4);
        assertTrue(sInfo.isValid);
    }

    function testIfgetPeriodIdToClaimIdToClaimInfoFunctionWorksProperly()
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
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        TandaPay.ClaimInfo memory cInfo0 = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdBefore);
        assertEq(cInfo0.id, cIdBefore);
        assertEq(cInfo0.claimant, address(0));
        assertEq(cInfo0.SGId, 0);

        vm.startPrank(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member1, cIdBefore + 1);
        tandaPay.submitClaim();
        vm.stopPrank();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore + 1, cIdAfter);
        TandaPay.ClaimInfo memory cInfo = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdAfter);
        assertEq(cInfo.id, cIdAfter);
        assertEq(cInfo.claimant, member1);
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            member1,
            currentPeriodIdAfter2
        );
        assertEq(cInfo.SGId, mInfo.associatedGroupId);
    }

    function testIfgetPeriodIdToClaimIdsFunctionWorksProperly() public {
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
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        uint256[] memory ids0 = tandaPay.getPeriodIdToClaimIds(cIdBefore);
        assertEq(ids0.length, 0);
        vm.startPrank(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member1, cIdBefore + 1);
        tandaPay.submitClaim();
        vm.stopPrank();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore + 1, cIdAfter);
        uint256[] memory ids = tandaPay.getPeriodIdToClaimIds(
            currentPeriodIdAfter2
        );
        assertEq(ids.length, 1);
        assertEq(ids[0], cIdAfter);
    }

    function testIfgetPeriodIdToDefectorsIdFunctionWorksProperly() public {
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
        uint256[] memory dIds0 = tandaPay.getPeriodIdToDefectorsId(
            currentPeriodIdAfter3
        );
        assertEq(dIds0.length, 0);
        TandaPay.DemoMemberInfo memory mInfo1Before = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter3);
        vm.startPrank(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberDefected(member1, currentPeriodIdAfter3);
        tandaPay.defects();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo1After = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter3);
        assertEq(
            uint8(mInfo1After.status),
            uint8(TandaPayEvents.MemberStatus.DEFECTED)
        );
        assertEq(mInfo1After.associatedGroupId, 0);
        assertEq(
            mInfo1After.pendingRefundAmount,
            mInfo1Before.cEscrowAmount + mInfo1Before.ISEscorwAmount
        );
        assertEq(mInfo1After.cEscrowAmount, 0);
        assertEq(mInfo1After.ISEscorwAmount, 0);
        assertFalse(mInfo1After.eligibleForCoverageInPeriod);
        uint256[] memory dIds = tandaPay.getPeriodIdToDefectorsId(
            currentPeriodIdAfter3
        );
        assertEq(dIds.length, 1);
        assertEq(dIds[0], mInfo1After.memberId);
    }

    function testIfgetPeriodIdToManualCollapseFunctionWorksProperly() public {
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

        TandaPay.ManualCollapse memory mcBefore = tandaPay
            .getPeriodIdToManualCollapse(currentPeriodIdAfter);
        assertEq(mcBefore.startedAT, 0);
        assertEq(mcBefore.availableToTurnTill, 0);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ManualCollapsedHappenend();
        tandaPay.manualCollapsBySecretary();
        TandaPay.ManualCollapse memory manualCollapse = tandaPay
            .getPeriodIdToManualCollapse(currentPeriodIdAfter);
        assertTrue(manualCollapse.startedAT > 0);
        assertEq(manualCollapse.availableToTurnTill, pInfo.willEndAt + 4 days);
    }

    function testIfgetMemberToMemberIdFunctionWorksProperly() public {
        uint256 id = tandaPay.getMemberToMemberId(member1);
        addToCommunity(member1);
        uint256 idAfter = tandaPay.getMemberToMemberId(member1);
        assertEq(id, 0);
        assertEq(idAfter, 1);
        assertEq(idAfter, id + 1);
    }

    function testgetPeriodIdWhiteListedClaimsFunctionWorksProperly() public {
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
        uint256[] memory whitelistedIdsBefore = tandaPay
            .getPeriodIdWhiteListedClaims(currentPeriodIdAfter2);
        assertEq(whitelistedIdsBefore.length, 0);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimWhiteListed(cIdAfter);
        tandaPay.whitelistClaim(cIdAfter);
        cInfo = tandaPay.getPeriodIdToClaimIdToClaimInfo(
            currentPeriodIdAfter2,
            cIdAfter
        );
        assertTrue(cInfo.isWhitelistd);
        skip(23 days);
        uint256[] memory whitelistedIdsAfter = tandaPay
            .getPeriodIdWhiteListedClaims(currentPeriodIdAfter2);
        assertEq(whitelistedIdsAfter.length, 1);
        assertEq(whitelistedIdsAfter[0], cIdAfter);
    }

    function testIfgetMemberToMemberInfoFunctionWorksProperly() public {
        TandaPay.DemoMemberInfo memory mInfo0 = tandaPay.getMemberToMemberInfo(
            member1,
            0
        );
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
        TandaPay.DemoMemberInfo memory mInfo = tandaPay.getMemberToMemberInfo(
            member1,
            currentPeriodIdAfter2
        );
        assertEq(mInfo0.member, address(0));
        assertEq(mInfo0.memberId, 0);
        assertEq(mInfo0.associatedGroupId, 0);
        assertEq(mInfo0.cEscrowAmount, 0);
        assertEq(mInfo0.ISEscorwAmount, 0);
        assertEq(mInfo0.pendingRefundAmount, 0);
        assertEq(mInfo0.availableToWithdraw, 0);
        assertEq(
            uint8(mInfo0.status),
            uint8(TandaPayEvents.MemberStatus.UnAssigned)
        );
        assertEq(
            uint8(mInfo0.assignment),
            uint8(TandaPay.AssignmentStatus.UnAssigned)
        );

        assertEq(mInfo.member, member1);
        assertEq(mInfo.memberId, 1);
        assertEq(mInfo.associatedGroupId, sgId1);
        assertEq(mInfo.cEscrowAmount, basePremium);
        assertEq(
            mInfo.ISEscorwAmount,
            basePremium + ((basePremium * 20) / 100)
        );
        assertEq(mInfo.pendingRefundAmount, 0);
        assertEq(mInfo.availableToWithdraw, 0);
        assertEq(uint8(mInfo.status), uint8(TandaPayEvents.MemberStatus.VALID));
        assertEq(
            uint8(mInfo.assignment),
            uint8(TandaPay.AssignmentStatus.AssignmentSuccessfull)
        );
    }

    function testIfgetIsAMemberDefectedInPeriodFunctionWorksProperly() public {
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
            currentPeriodIdAfter,
            cIdAfter
        );
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
        bool isDefectedBefore = tandaPay.getIsAMemberDefectedInPeriod(
            currentPeriodIdAfter3
        );
        assertFalse(isDefectedBefore);
        vm.startPrank(member1);
        tandaPay.defects();
        vm.stopPrank();
        bool isDefectedAfter = tandaPay.getIsAMemberDefectedInPeriod(
            currentPeriodIdAfter3
        );
        assertTrue(isDefectedAfter);
    }

    function testIfgetIsAllMemberNotPaidInPeriodFunctionWorksProperly() public {
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
        skip(4 days);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundIssued();
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
        skip(3 days);
        uint256 currentPeriodIdBefore3 = tandaPay.getPeriodId();
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

        bool isAllMemberPaid = tandaPay.getIsAllMemberNotPaidInPeriod(
            currentPeriodIdAfter3 - 1
        );
        assertEq(isAllMemberPaid, true);
    }

    function testIfsecretaryFunctionWorksProperly() public view {
        address currentSecretary = tandaPay.secretary();
        assertEq(currentSecretary, address(this));
    }

    function testIfgetSecretarySuccessorsFunctionWorksProperly() public {
        address[] memory _successors = tandaPay.getSecretarySuccessors();
        assertEq(_successors.length, 0);

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

        successors.push(member1);
        successors.push(member2);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretarySuccessorsDefined(successors);
        tandaPay.defineSecretarySuccessor(successors);
        address[] memory _successorsAfter = tandaPay.getSecretarySuccessors();
        assertEq(_successorsAfter.length, 2);
        assertEq(_successorsAfter[0], member1);
        assertEq(_successorsAfter[1], member2);
    }

    function testIfgetUpcomingSecretaryFunctionWorksProperly() public {
        address upcoming = tandaPay.getUpcomingSecretary();
        assertEq(upcoming, address(0));

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
        successors.push(member1);
        successors.push(member2);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretarySuccessorsDefined(successors);
        tandaPay.defineSecretarySuccessor(successors);
        address[] memory _successorsAfter = tandaPay.getSecretarySuccessors();
        assertEq(_successorsAfter.length, 2);
        assertEq(_successorsAfter[0], member1);
        assertEq(_successorsAfter[1], member2);
        address preferredSecretary = member1;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretaryHandOverEnabled(preferredSecretary);
        tandaPay.handoverSecretary(preferredSecretary);
        address upcomingAfter = tandaPay.getUpcomingSecretary();
        assertEq(upcomingAfter, preferredSecretary);
    }

    function testIfgetEmergencySecretariesFunctionWorksProperly() public {
        address[2] memory emergencySecretaries = tandaPay
            .getEmergencySecretaries();
        assertEq(emergencySecretaries[0], address(0));
        assertEq(emergencySecretaries[1], address(0));

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

        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretarySuccessorsDefined(successors);
        tandaPay.defineSecretarySuccessor(successors);
        address[] memory secretarySuccessorList = tandaPay
            .getSecretarySuccessors();

        assertEq(secretarySuccessorList[0], successors[0]);
        assertEq(secretarySuccessorList[1], successors[1]);
        assertEq(secretarySuccessorList[2], successors[2]);
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
        vm.startPrank(member2);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.EmergencyhandOverSecretary(member3);
        tandaPay.emergencyHandOverSecretary(member3);

        vm.stopPrank();
        address[2] memory emembergencySecretaries2 = tandaPay
            .getEmergencySecretaries();
        assertEq(emembergencySecretaries2[0], address(0));
        assertEq(emembergencySecretaries2[1], address(0));
        address upcomingSecretary = tandaPay.getUpcomingSecretary();
        assertEq(upcomingSecretary, address(0));
        address currentSecretary = tandaPay.secretary();
        assertEq(currentSecretary, member3);
        vm.startPrank(member3);
        addToCommunity(member13);
        vm.stopPrank();
    }

    function testIfgetIsHandingOverFunctionWorksProperly() public {
        bool isHandingOver = tandaPay.getIsHandingOver();
        assertFalse(isHandingOver);
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
        successors.push(member1);
        successors.push(member2);

        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretarySuccessorsDefined(successors);
        tandaPay.defineSecretarySuccessor(successors);
        address[] memory _successorsAfter = tandaPay.getSecretarySuccessors();
        assertEq(_successorsAfter.length, 2);
        assertEq(_successorsAfter[0], member1);
        assertEq(_successorsAfter[1], member2);
        address preferredSecretary = member1;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretaryHandOverEnabled(preferredSecretary);
        tandaPay.handoverSecretary(preferredSecretary);
        address upcomingAfter = tandaPay.getUpcomingSecretary();
        assertEq(upcomingAfter, preferredSecretary);
        bool isHandingOverAfter = tandaPay.getIsHandingOver();
        assertTrue(isHandingOverAfter);
    }

    function testIfgetEmergencyHandOverStartedPeriodWorksProperly() public {
        uint256 handoverStartPeriod = tandaPay
            .getEmergencyHandOverStartedPeriod();
        assertEq(handoverStartPeriod, 0);
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
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretarySuccessorsDefined(successors);
        tandaPay.defineSecretarySuccessor(successors);
        address[] memory _successorsAfter = tandaPay.getSecretarySuccessors();
        assertEq(_successorsAfter.length, 2);
        assertEq(_successorsAfter[0], member1);
        assertEq(_successorsAfter[1], member2);
        address preferredSecretary = member1;
        vm.startPrank(member2);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.EmergencyhandOverSecretary(preferredSecretary);
        tandaPay.emergencyHandOverSecretary(preferredSecretary);
        uint256 handoverStartPeriodAfter = tandaPay
            .getEmergencyHandOverStartedPeriod();
        assertEq(handoverStartPeriodAfter, currentPeriodIdAfter);
    }

    function testIfgetHandoverStartedAtFunctionWorksProperly() public {
        uint256 handoverStartedAt = tandaPay.getHandoverStartedAt();
        assertEq(handoverStartedAt, 0);

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
        successors.push(member1);
        successors.push(member2);

        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretarySuccessorsDefined(successors);
        tandaPay.defineSecretarySuccessor(successors);
        address[] memory _successorsAfter = tandaPay.getSecretarySuccessors();
        assertEq(_successorsAfter.length, 2);
        assertEq(_successorsAfter[0], member1);
        assertEq(_successorsAfter[1], member2);
        address preferredSecretary = member1;
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretaryHandOverEnabled(preferredSecretary);
        tandaPay.handoverSecretary(preferredSecretary);
        address upcomingAfter = tandaPay.getUpcomingSecretary();
        assertEq(upcomingAfter, preferredSecretary);
        uint256 handoverStartedAtAfter = tandaPay.getHandoverStartedAt();
        assertEq(handoverStartedAtAfter, block.timestamp);
    }

    function testIfgetEmergencyHandoverStartedAtFunctionWorksProperly() public {
        uint256 handoverStartedAt = tandaPay.getEmergencyHandoverStartedAt();
        assertEq(handoverStartedAt, 0);
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
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.SecretarySuccessorsDefined(successors);
        tandaPay.defineSecretarySuccessor(successors);
        address[] memory _successorsAfter = tandaPay.getSecretarySuccessors();
        assertEq(_successorsAfter.length, 2);
        assertEq(_successorsAfter[0], member1);
        assertEq(_successorsAfter[1], member2);
        address preferredSecretary = member1;
        vm.startPrank(member2);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.EmergencyhandOverSecretary(preferredSecretary);
        tandaPay.emergencyHandOverSecretary(preferredSecretary);
        uint256 handoverStartedAtAfter = tandaPay
            .getEmergencyHandoverStartedAt();
        assertEq(handoverStartedAtAfter, block.timestamp);
    }

    function testIfSecretayCanSuccesfullyUpdatememberStatus() public {
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
        skip(30 days);
        tandaPay.updateMemberStatus();
    }

    function testIfCommunityStatesReinstateToDefaultIfAllMemberPaidAndNoOneDefetecedInLast3PeriodWhileCommunateStateIsFractured()
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
        vm.startPrank(member5);
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member5, cIdBefore + 1);
        tandaPay.submitClaim();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore + 1, cIdAfter);
        vm.stopPrank();

        TandaPay.ClaimInfo memory cInfo = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdAfter);
        assertEq(cInfo.claimant, member5);
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
        TandaPay.DemoMemberInfo memory mInfo1Before = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter3);
        vm.startPrank(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberDefected(member1, currentPeriodIdAfter3);
        tandaPay.defects();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo1After = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter3);
        assertEq(
            uint8(mInfo1After.status),
            uint8(TandaPayEvents.MemberStatus.DEFECTED)
        );
        assertEq(mInfo1After.associatedGroupId, 0);
        assertEq(
            mInfo1After.pendingRefundAmount,
            mInfo1Before.cEscrowAmount + mInfo1Before.ISEscorwAmount
        );
        assertEq(mInfo1After.cEscrowAmount, 0);
        assertEq(mInfo1After.ISEscorwAmount, 0);
        assertFalse(mInfo1After.eligibleForCoverageInPeriod);

        TandaPay.DemoMemberInfo memory mInfo2Before = tandaPay
            .getMemberToMemberInfo(member2, currentPeriodIdAfter3);
        vm.startPrank(member2);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberDefected(member2, currentPeriodIdAfter3);
        tandaPay.defects();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo2After = tandaPay
            .getMemberToMemberInfo(member2, currentPeriodIdAfter3);
        assertEq(
            uint8(mInfo2After.status),
            uint8(TandaPayEvents.MemberStatus.DEFECTED)
        );
        assertEq(mInfo2After.associatedGroupId, 0);
        assertEq(
            mInfo2After.pendingRefundAmount,
            mInfo2Before.cEscrowAmount + mInfo2Before.ISEscorwAmount
        );
        assertEq(mInfo2After.cEscrowAmount, 0);
        assertEq(mInfo2After.ISEscorwAmount, 0);
        assertFalse(mInfo2After.eligibleForCoverageInPeriod);

        TandaPay.CommunityStates states2 = tandaPay.getCommunityState();
        assertEq(uint8(states2), uint8(TandaPay.CommunityStates.FRACTURED));
        skip(17 days);
        TandaPay.PeriodInfo memory pInfo2 = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter2
        );
        uint256[] memory __ids = tandaPay.getPeriodIdToClaimIds(
            currentPeriodIdAfter2
        );
        uint256 wlCount;
        for (uint256 i = 0; i < __ids.length; i++) {
            if (cInfo.isWhitelistd) {
                wlCount++;
            }
        }
        uint256 cAmount = pInfo2.coverage / wlCount;
        vm.startPrank(cInfo.claimant);
        vm.expectEmit(address(paymentToken));
        emit IERC20.Transfer(address(tandaPay), cInfo.claimant, cAmount);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.FundClaimed(cInfo.claimant, cAmount, cInfo.id);
        tandaPay.withdrawClaimFund(false);
        vm.stopPrank();
        cInfo = tandaPay.getPeriodIdToClaimIdToClaimInfo(
            currentPeriodIdAfter2,
            cIdAfter
        );
        assertTrue(cInfo.isClaimed);
        skip(10 days);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        payPremium(member3, pFee, currentPeriodIdAfter3, true);
        payPremium(member4, pFee, currentPeriodIdAfter3, true);
        payPremium(member5, pFee, currentPeriodIdAfter3, true);
        payPremium(member6, pFee, currentPeriodIdAfter3, true);
        payPremium(member7, pFee, currentPeriodIdAfter3, true);
        payPremium(member8, pFee, currentPeriodIdAfter3, true);
        payPremium(member9, pFee, currentPeriodIdAfter3, true);
        payPremium(member10, pFee, currentPeriodIdAfter3, true);
        payPremium(member11, pFee, currentPeriodIdAfter3, true);
        payPremium(member12, pFee, currentPeriodIdAfter3, true);
        skip(3 days);
        uint256 currentPeriodIdBefore4 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberStatusUpdated(
            member1,
            TandaPayEvents.MemberStatus.DEFECTED
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member2,
            TandaPayEvents.MemberStatus.DEFECTED
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
            currentPeriodIdBefore4 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter4 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore4 + 1, currentPeriodIdAfter4);
        TandaPay.CommunityStates states4 = tandaPay.getCommunityState();
        assertEq(uint8(states4), uint8(TandaPay.CommunityStates.FRACTURED));

        skip(4 days);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundIssued();
        tandaPay.issueRefund(false);
        skip(23 days);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        payPremium(member5, pFee, currentPeriodIdAfter4, false);
        payPremium(member6, pFee, currentPeriodIdAfter4, false);
        payPremium(member7, pFee, currentPeriodIdAfter4, false);
        payPremium(member8, pFee, currentPeriodIdAfter4, false);
        payPremium(member9, pFee, currentPeriodIdAfter4, false);
        payPremium(member10, pFee, currentPeriodIdAfter4, false);
        payPremium(member11, pFee, currentPeriodIdAfter4, false);
        payPremium(member12, pFee, currentPeriodIdAfter4, false);
        skip(3 days);
        uint256 currentPeriodIdBefore5 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
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
            currentPeriodIdBefore5 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter5 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore5 + 1, currentPeriodIdAfter5);
        TandaPay.CommunityStates states5 = tandaPay.getCommunityState();
        assertEq(uint8(states5), uint8(TandaPay.CommunityStates.FRACTURED));
        skip(4 days);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundIssued();
        tandaPay.issueRefund(false);
        skip(23 days);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        payPremium(member5, pFee, currentPeriodIdAfter5, true);
        payPremium(member6, pFee, currentPeriodIdAfter5, true);
        payPremium(member7, pFee, currentPeriodIdAfter5, true);
        payPremium(member8, pFee, currentPeriodIdAfter5, true);
        payPremium(member9, pFee, currentPeriodIdAfter5, true);
        payPremium(member10, pFee, currentPeriodIdAfter5, true);
        payPremium(member11, pFee, currentPeriodIdAfter5, true);
        payPremium(member12, pFee, currentPeriodIdAfter5, true);
        skip(3 days);
        uint256 currentPeriodIdBefore6 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
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
            currentPeriodIdBefore6 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter6 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore6 + 1, currentPeriodIdAfter6);
        TandaPay.CommunityStates states6 = tandaPay.getCommunityState();
        assertEq(uint8(states6), uint8(TandaPay.CommunityStates.FRACTURED));
        skip(4 days);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundIssued();
        tandaPay.issueRefund(false);
        skip(23 days);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        payPremium(member5, pFee, currentPeriodIdAfter6, true);
        payPremium(member6, pFee, currentPeriodIdAfter6, true);
        payPremium(member7, pFee, currentPeriodIdAfter6, true);
        payPremium(member8, pFee, currentPeriodIdAfter6, true);
        payPremium(member9, pFee, currentPeriodIdAfter6, true);
        payPremium(member10, pFee, currentPeriodIdAfter6, true);
        payPremium(member11, pFee, currentPeriodIdAfter6, true);
        payPremium(member12, pFee, currentPeriodIdAfter6, true);
        skip(3 days);
        uint256 currentPeriodIdBefore7 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
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
            currentPeriodIdBefore7 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter7 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore7 + 1, currentPeriodIdAfter7);
        TandaPay.CommunityStates states7 = tandaPay.getCommunityState();
        assertEq(uint8(states7), uint8(TandaPay.CommunityStates.DEFAULT));
        skip(4 days);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundIssued();
        tandaPay.issueRefund(false);
        skip(23 days);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        payPremium(member5, pFee, currentPeriodIdAfter7, true);
        payPremium(member6, pFee, currentPeriodIdAfter7, true);
        payPremium(member7, pFee, currentPeriodIdAfter7, true);
        payPremium(member8, pFee, currentPeriodIdAfter7, true);
        payPremium(member9, pFee, currentPeriodIdAfter7, true);
        payPremium(member10, pFee, currentPeriodIdAfter7, true);
        payPremium(member11, pFee, currentPeriodIdAfter7, true);
        payPremium(member12, pFee, currentPeriodIdAfter7, true);
        skip(3 days);
        uint256 currentPeriodIdBefore8 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
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
            currentPeriodIdBefore8 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter8 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore8 + 1, currentPeriodIdAfter8);
        TandaPay.CommunityStates states8 = tandaPay.getCommunityState();
        assertEq(uint8(states8), uint8(TandaPay.CommunityStates.DEFAULT));
    }

    function testIfMemberStatusIsBeingUpdatedProperlyWhileAdvancingToTheNextPeriod()
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

        skip(23 days);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        payPremium(member1, pFee, currentPeriodIdAfter2, true);
        payPremium(member2, pFee, currentPeriodIdAfter2, true);
        payPremium(member3, pFee, currentPeriodIdAfter2, true);
        payPremium(member4, pFee, currentPeriodIdAfter2, true);
        payPremium(member5, pFee, currentPeriodIdAfter2, true);
        payPremium(member6, pFee, currentPeriodIdAfter2, true);

        TandaPay.DemoMemberInfo memory mInfo1Before = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo2Before = tandaPay
            .getMemberToMemberInfo(member2, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo3Before = tandaPay
            .getMemberToMemberInfo(member3, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo4Before = tandaPay
            .getMemberToMemberInfo(member4, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo5Before = tandaPay
            .getMemberToMemberInfo(member5, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo6Before = tandaPay
            .getMemberToMemberInfo(member6, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo7Before = tandaPay
            .getMemberToMemberInfo(member7, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo8Before = tandaPay
            .getMemberToMemberInfo(member8, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo9Before = tandaPay
            .getMemberToMemberInfo(member9, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo10Before = tandaPay
            .getMemberToMemberInfo(member10, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo11Before = tandaPay
            .getMemberToMemberInfo(member11, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo12Before = tandaPay
            .getMemberToMemberInfo(member12, currentPeriodIdAfter2);

        skip(3 days);

        uint256 currentPeriodIdBefore3 = tandaPay.getPeriodId();
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
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member8,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member9,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member10,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
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
            (currentCoverage / 6)
        );

        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter3 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore3 + 1, currentPeriodIdAfter3);

        TandaPay.DemoMemberInfo memory mInfo1After = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo2After = tandaPay
            .getMemberToMemberInfo(member2, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo3After = tandaPay
            .getMemberToMemberInfo(member3, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo4After = tandaPay
            .getMemberToMemberInfo(member4, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo5After = tandaPay
            .getMemberToMemberInfo(member5, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo6After = tandaPay
            .getMemberToMemberInfo(member6, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo7After = tandaPay
            .getMemberToMemberInfo(member7, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo8After = tandaPay
            .getMemberToMemberInfo(member8, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo9After = tandaPay
            .getMemberToMemberInfo(member9, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo10After = tandaPay
            .getMemberToMemberInfo(member10, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo11After = tandaPay
            .getMemberToMemberInfo(member11, currentPeriodIdAfter2);
        TandaPay.DemoMemberInfo memory mInfo12After = tandaPay
            .getMemberToMemberInfo(member12, currentPeriodIdAfter2);

        assertEq(
            uint8(mInfo1Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo2Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo3Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo4Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo5Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo6Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo7Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo8Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo9Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo10Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo11Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo12Before.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );

        assertEq(
            uint8(mInfo1After.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo2After.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo3After.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo4After.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo5After.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo6After.status),
            uint8(TandaPayEvents.MemberStatus.VALID)
        );
        assertEq(
            uint8(mInfo7After.status),
            uint8(TandaPayEvents.MemberStatus.UNPAID_INVALID)
        );
        assertEq(
            uint8(mInfo8After.status),
            uint8(TandaPayEvents.MemberStatus.UNPAID_INVALID)
        );
        assertEq(
            uint8(mInfo9After.status),
            uint8(TandaPayEvents.MemberStatus.UNPAID_INVALID)
        );
        assertEq(
            uint8(mInfo10After.status),
            uint8(TandaPayEvents.MemberStatus.UNPAID_INVALID)
        );
        assertEq(
            uint8(mInfo11After.status),
            uint8(TandaPayEvents.MemberStatus.UNPAID_INVALID)
        );
        assertEq(
            uint8(mInfo12After.status),
            uint8(TandaPayEvents.MemberStatus.UNPAID_INVALID)
        );
    }

    function testIfMemberStatusChangeIfTheirSubGroupHasLessThan4MembersWhileAdvancingToTheNextPeriod()
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
        vm.startPrank(member5);
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member5, cIdBefore + 1);
        tandaPay.submitClaim();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore + 1, cIdAfter);
        vm.stopPrank();

        TandaPay.ClaimInfo memory cInfo = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdAfter);
        assertEq(cInfo.claimant, member5);
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
        TandaPay.DemoMemberInfo memory mInfo1Before = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter3);
        vm.startPrank(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberDefected(member1, currentPeriodIdAfter3);
        tandaPay.defects();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo1After = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter3);
        assertEq(
            uint8(mInfo1After.status),
            uint8(TandaPayEvents.MemberStatus.DEFECTED)
        );
        assertEq(mInfo1After.associatedGroupId, 0);
        assertEq(
            mInfo1After.pendingRefundAmount,
            mInfo1Before.cEscrowAmount + mInfo1Before.ISEscorwAmount
        );
        assertEq(mInfo1After.cEscrowAmount, 0);
        assertEq(mInfo1After.ISEscorwAmount, 0);
        assertFalse(mInfo1After.eligibleForCoverageInPeriod);

        TandaPay.DemoMemberInfo memory mInfo2Before = tandaPay
            .getMemberToMemberInfo(member2, currentPeriodIdAfter3);
        vm.startPrank(member2);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberDefected(member2, currentPeriodIdAfter3);
        tandaPay.defects();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo2After = tandaPay
            .getMemberToMemberInfo(member2, currentPeriodIdAfter3);
        assertEq(
            uint8(mInfo2After.status),
            uint8(TandaPayEvents.MemberStatus.DEFECTED)
        );
        assertEq(mInfo2After.associatedGroupId, 0);
        assertEq(
            mInfo2After.pendingRefundAmount,
            mInfo2Before.cEscrowAmount + mInfo2Before.ISEscorwAmount
        );
        assertEq(mInfo2After.cEscrowAmount, 0);
        assertEq(mInfo2After.ISEscorwAmount, 0);
        assertFalse(mInfo2After.eligibleForCoverageInPeriod);

        TandaPay.CommunityStates states2 = tandaPay.getCommunityState();
        assertEq(uint8(states2), uint8(TandaPay.CommunityStates.FRACTURED));
        skip(17 days);
        TandaPay.PeriodInfo memory pInfo2 = tandaPay.getPeriodIdToPeriodInfo(
            currentPeriodIdAfter2
        );
        uint256[] memory __ids = tandaPay.getPeriodIdToClaimIds(
            currentPeriodIdAfter2
        );
        uint256 wlCount;
        for (uint256 i = 0; i < __ids.length; i++) {
            if (cInfo.isWhitelistd) {
                wlCount++;
            }
        }
        uint256 cAmount = pInfo2.coverage / wlCount;

        vm.startPrank(cInfo.claimant);
        vm.expectEmit(address(paymentToken));
        emit IERC20.Transfer(address(tandaPay), cInfo.claimant, cAmount);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.FundClaimed(cInfo.claimant, cAmount, cInfo.id);
        tandaPay.withdrawClaimFund(false);
        vm.stopPrank();
        cInfo = tandaPay.getPeriodIdToClaimIdToClaimInfo(
            currentPeriodIdAfter2,
            cIdAfter
        );
        assertTrue(cInfo.isClaimed);
        skip(10 days);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        payPremium(member3, pFee, currentPeriodIdAfter3, true);
        payPremium(member4, pFee, currentPeriodIdAfter3, true);
        payPremium(member5, pFee, currentPeriodIdAfter3, true);
        payPremium(member6, pFee, currentPeriodIdAfter3, true);
        payPremium(member7, pFee, currentPeriodIdAfter3, true);
        payPremium(member8, pFee, currentPeriodIdAfter3, true);
        payPremium(member9, pFee, currentPeriodIdAfter3, true);
        payPremium(member10, pFee, currentPeriodIdAfter3, true);
        payPremium(member11, pFee, currentPeriodIdAfter3, true);
        payPremium(member12, pFee, currentPeriodIdAfter3, true);
        skip(3 days);
        uint256 currentPeriodIdBefore4 = tandaPay.getPeriodId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberStatusUpdated(
            member1,
            TandaPayEvents.MemberStatus.DEFECTED
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member2,
            TandaPayEvents.MemberStatus.DEFECTED
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
            currentPeriodIdBefore4 + 1,
            currentCoverage,
            basePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter4 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore4 + 1, currentPeriodIdAfter4);
        TandaPay.CommunityStates states4 = tandaPay.getCommunityState();
        assertEq(uint8(states4), uint8(TandaPay.CommunityStates.FRACTURED));
        TandaPay.SubGroupInfo memory sInfo = tandaPay
            .getSubGroupIdToSubGroupInfo(1);
        for (uint256 i = 0; i < sInfo.members.length; i++) {
            TandaPay.DemoMemberInfo memory mInfos = tandaPay
                .getMemberToMemberInfo(sInfo.members[i], currentPeriodIdAfter4);
            assertEq(
                uint8(mInfos.status),
                uint8(TandaPayEvents.MemberStatus.USER_LEFT)
            );
        }
    }

    function testIfBasePremiumIsBeingSetUpProperlyWhileAdvancingToTheNextPeriod()
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

        skip(23 days);
        basePremium = tandaPay.getBasePremium();
        pFee = basePremium + ((basePremium * 20) / 100);
        payPremium(member1, pFee, currentPeriodIdAfter2, true);
        payPremium(member2, pFee, currentPeriodIdAfter2, true);
        payPremium(member3, pFee, currentPeriodIdAfter2, true);
        payPremium(member4, pFee, currentPeriodIdAfter2, true);
        payPremium(member5, pFee, currentPeriodIdAfter2, true);
        payPremium(member6, pFee, currentPeriodIdAfter2, true);

        skip(3 days);

        uint256 currentPeriodIdBefore3 = tandaPay.getPeriodId();
        uint256 expectedBasePremium = currentCoverage / 6;
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
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member8,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member9,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
        );
        emit TandaPayEvents.MemberStatusUpdated(
            member10,
            TandaPayEvents.MemberStatus.UNPAID_INVALID
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
            expectedBasePremium
        );
        tandaPay.AdvanceToTheNextPeriod();
        uint256 currentPeriodIdAfter3 = tandaPay.getPeriodId();
        assertEq(currentPeriodIdBefore3 + 1, currentPeriodIdAfter3);
        basePremium = tandaPay.getBasePremium();
        assertEq(basePremium, expectedBasePremium);
    }

    function testIfCommunityCollapseIfClaimAmountCannotBeFulfilledWhileClaimantWithdrawingClaimFund()
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
        vm.startPrank(member10);
        uint256 cIdBefore = tandaPay.getCurrentClaimId();
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.ClaimSubmitted(member10, cIdBefore + 1);
        tandaPay.submitClaim();
        uint256 cIdAfter = tandaPay.getCurrentClaimId();
        assertEq(cIdBefore + 1, cIdAfter);
        vm.stopPrank();

        TandaPay.ClaimInfo memory cInfo = tandaPay
            .getPeriodIdToClaimIdToClaimInfo(currentPeriodIdAfter2, cIdAfter);
        assertEq(cInfo.claimant, member10);
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
        TandaPay.DemoMemberInfo memory mInfo1Before = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter3);
        vm.startPrank(member1);
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.MemberDefected(member1, currentPeriodIdAfter3);
        tandaPay.defects();
        vm.stopPrank();
        TandaPay.DemoMemberInfo memory mInfo1After = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter3);
        assertEq(
            uint8(mInfo1After.status),
            uint8(TandaPayEvents.MemberStatus.DEFECTED)
        );
        assertEq(mInfo1After.associatedGroupId, 0);
        assertEq(
            mInfo1After.pendingRefundAmount,
            mInfo1Before.cEscrowAmount + mInfo1Before.ISEscorwAmount
        );
        assertEq(mInfo1After.cEscrowAmount, 0);
        assertEq(mInfo1After.ISEscorwAmount, 0);
        assertFalse(mInfo1After.eligibleForCoverageInPeriod);

        TandaPay.CommunityStates states2 = tandaPay.getCommunityState();
        assertEq(uint8(states2), uint8(TandaPay.CommunityStates.DEFAULT));
        skip(17 days);
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
        emit TandaPayEvents.CommunityCollapsed(block.timestamp);
        tandaPay.withdrawClaimFund(false);
        vm.stopPrank();
    }
    function testIfSubGroupValidityChangeIfThereIsMoreThan7MembersInTheSubGroup()
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

        assignToSubGroup(member1, gIdAfter1, 1);
        assignToSubGroup(member2, gIdAfter1, 2);
        assignToSubGroup(member3, gIdAfter1, 3);
        assignToSubGroup(member4, gIdAfter1, 4);
        assignToSubGroup(member5, gIdAfter1, 5);
        assignToSubGroup(member6, gIdAfter1, 6);
        assignToSubGroup(member7, gIdAfter1, 7);
        TandaPay.SubGroupInfo memory sInfo = tandaPay
            .getSubGroupIdToSubGroupInfo(gIdAfter1);
        assertTrue(sInfo.isValid);
        assignToSubGroup(member8, gIdAfter1, 8);
        TandaPay.SubGroupInfo memory sInfo2 = tandaPay
            .getSubGroupIdToSubGroupInfo(gIdAfter1);
        assertFalse(sInfo2.isValid);
    }

    function testIfRevertIfTheWithdrawAmountIsZeroWhileWithdrawingRefund()
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
        vm.startPrank(member1);
        vm.expectRevert(abi.encodeWithSelector(TandaPayErrors.AmountZero.selector));
        tandaPay.withdrawRefund();
        vm.stopPrank();
    }

    function testIfMemberCanSuccessfullyWithdrawRefundToken() public {
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
        TandaPay.DemoMemberInfo memory mInfo1Before = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter2);
        uint256 m1BalanceBefore = paymentToken.balanceOf(member1);
        vm.expectEmit(address(paymentToken));
        emit IERC20.Transfer(
            address(tandaPay),
            member1,
            mInfo1Before.availableToWithdraw
        );
        vm.expectEmit(address(tandaPay));
        emit TandaPayEvents.RefundWithdrawn(
            member1,
            mInfo1Before.availableToWithdraw
        );
        tandaPay.withdrawRefund();
        TandaPay.DemoMemberInfo memory mInfo1After = tandaPay
            .getMemberToMemberInfo(member1, currentPeriodIdAfter2);
        vm.stopPrank();
        uint256 m1BalanceAfter = paymentToken.balanceOf(member1);
        assertEq(
            m1BalanceBefore + mInfo1Before.availableToWithdraw,
            m1BalanceAfter
        );
        assertEq(mInfo1After.availableToWithdraw, 0);
    }
    function testIfRevertIfClaimWhiteListedWhileIssuingRefund() public {
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
        {
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
        }
        

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
        skip(4 days);
        vm.expectRevert(abi.encodeWithSelector(TandaPayErrors.WLCAvailable.selector));
        tandaPay.issueRefund(false);
    }

    function testIfIssuedRefundCanBeSuccessfullyDone() public {
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
    }
}
