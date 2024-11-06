// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITandaPay {

    // Enum to represent the different states the community can be in
    enum CommunityStates {
        INITIALIZATION,
        DEFAULT,
        FRACTURED,
        COLLAPSED,
        EMERGENCY
    }

    // Enum to represent the status of assignments within the contract
    enum AssignmentStatus {
        UnAssigned,
        AddedBySecretery,
        AssignedToGroup,
        ApprovedByMember,
        ApprovedByGroupMember,
        AssignmentSuccessfull,
        CancelledByMember,
        CancelledGMember
    }

    enum MemberStatus {
        UnAssigned,
        Assigned,
        New,
        SAEPaid,
        VALID,
        PAID_INVALID,
        UNPAID_INVALID,
        REORGED,
        USER_LEFT,
        DEFECTED,
        USER_QUIT,
        REJECTEDBYGM
    }

    // Struct for member information
    struct DemoMemberInfo {
        uint256 memberId;
        uint256 associatedGroupId;
        address member;
        uint256 cEscrowAmount;
        uint256 ISEscorwAmount;
        uint256 pendingRefundAmount;
        uint256 availableToWithdraw;
        bool eligibleForCoverageInPeriod;
        bool isPremiumPaid;
        uint256 idToQuedRefundAmount;
        MemberStatus status;
        AssignmentStatus assignment;
    }

    // Struct to represent more detailed member information
    struct MemberInfo {
        uint256 memberId;
        uint256 associatedGroupId;
        address member;
        uint256 cEscrowAmount;
        uint256 ISEscorwAmount;
        uint256 pendingRefundAmount;
        uint256 availableToWithdraw;
        mapping(uint256 => bool) eligibleForCoverageInPeriod;
        mapping(uint256 => bool) isPremiumPaid;
        mapping(uint256 => uint256) idToQuedRefundAmount;
        MemberStatus status;
        AssignmentStatus assignment;
    }

    // Struct to represent information about subgroups
    struct SubGroupInfo {
        uint256 id;
        address[] members;
        bool isValid;
    }

    // Struct to represent claim information
    struct ClaimInfo {
        uint256 id;
        address claimant;
        uint256 claimAmount;
        uint256 SGId;
        bool isWhitelistd;
        bool isClaimed;
    }

    // Struct to represent information about each period
    struct PeriodInfo {
        uint256 startedAt;
        uint256 willEndAt;
        uint256[] claimIds;
        uint256 coverage;
        uint256 totalPaid;
    }
    
    // Struct to represent manual collapse details
    struct ManualCollapse {
        uint256 startedAT;
        uint256 availableToTurnTill;
    }

    function addToCommunity(address _member) external;
    function createSubGroup() external;
    function assignToSubGroup(
        address _member,
        uint256 _sId,
        bool _isReorging
    ) external;
    function joinToCommunity() external;
    function initiatDefaultStateAndSetCoverage(
        uint256 _coverage
    ) external;
    function approveSubGroupAssignment(bool _shouldJoin) external;
    function approveNewSubgroupMember(
        uint256 _sId,
        uint256 _nMemberId,
        bool _accepted
    ) external;
    function exitSubGroup() external;
    function whitelistClaim(uint256 _cId) external;
    function defects() external;
    function payPremium(bool _useFromATW) external;
    function updateCoverageAmount(uint256 _coverage) external;
    function defineSecretarySuccessor(
        address[] memory _successors
    ) external;
    function handoverSecretary(
        address _prefferedSuccessor
    ) external;
    function secretaryAcceptance() external;
    function emergencyHandOverSecretary(address _eSecretary) external;
    function injectFunds() external;
    function divideShortFall() external;
    function addAdditionalDay() external;
    function manualCollapsBySecretary() external;
    function cancelManualCollapsBySecretary() external;
    function leaveFromASubGroup() external;
    function beginEmergency() external;
    function EmergencyWithdrawal(address to, uint256 amount) external;
    function endEmergency() external;
    function AdvanceToTheNextPeriod() external;
    function updateMemberStatus() external;
    function withdrawClaimFund(bool isForfeit) external;
    function submitClaim() external;
    function issueRefund(bool _shouldTransfer) external;

    function emergencyRefund() external;
    function withdrawRefund() external;
    function getPaymentToken() external view returns (address);

    function getCurrentMemberId() external view returns (uint256);

    function getCurrentSubGroupId() external view returns (uint256);

    function getCurrentClaimId() external view returns (uint256);

    function getPeriodId() external view returns (uint256);

    function getTotalCoverage() external view returns (uint256);

    function getBasePremium() external view returns (uint256);

    function getManuallyCollapsedPeriod() external view returns (uint256);

    function getIsManuallyCollapsed() external view returns (bool);

    function getCommunityState() external view returns (CommunityStates);

    function getSubGroupIdToSubGroupInfo(
        uint256 _sId
    ) external view returns (SubGroupInfo memory);

    function getPeriodIdToClaimIdToClaimInfo(
        uint256 _pId,
        uint256 _cId
    ) external view returns (ClaimInfo memory);

    function getPeriodIdToClaimIds(
        uint256 _pId
    ) external view returns (uint256[] memory);

    function getPeriodIdToDefectorsId(
        uint256 _pId
    ) external view returns (uint256[] memory);

    function getPeriodIdToManualCollapse(
        uint256 _pId
    ) external view returns (ManualCollapse memory);

    function getMemberToMemberId(
        address _member
    ) external view returns (uint256);

    function getPeriodIdWhiteListedClaims(
        uint256 _pId
    ) external view returns (uint256[] memory);

    function getMemberToMemberInfo(
        address _member,
        uint256 _pId
    ) external view returns (DemoMemberInfo memory);

    function getIsAMemberDefectedInPeriod(
        uint256 _pId
    ) external view returns (bool);

    function getPeriodIdToPeriodInfo(
        uint256 _pId
    ) external view returns (PeriodInfo memory);

    function getIsAllMemberNotPaidInPeriod(
        uint256 _pId
    ) external view returns (bool);
}