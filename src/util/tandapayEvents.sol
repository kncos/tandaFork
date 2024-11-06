// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TandaPayEvents {
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
    event ManualCollapsedCancelled(uint256 timee);

    event MemberStatusUpdated(address member, MemberStatus newStatus);

    event LeavedFromGroup(address member, uint256 gId, uint256 mId);

    event AddedToCommunity(address member, uint256 id);

    event SubGroupCreated(uint256 id);

    event AssignedToSubGroup(address member, uint256 groupId, bool isReOrging);

    event JoinedToCommunity(address member, uint256 paidAmount);

    event FundInjected(uint256 amount);

    event DefaultStateInitiatedAndCoverageSet(uint256 coverage);

    event ManualCollapseCancelled();

    event ApprovedGroupAssignment(address member, uint256 groupId, bool joined);

    event ApproveNewGroupMember(
        address member,
        address approver,
        uint256 groupId,
        bool approved
    );

    event ExitedFromSubGroup(address member, uint256 groupId);

    event ClaimWhiteListed(uint256 cId);

    event MemberDefected(address member, uint256 periodId);

    event PremiumPaid(
        address member,
        uint256 periodId,
        uint256 amount,
        bool usingATW
    );

    event RefundIssued();

    event CoverageUpdated(uint256 coverage, uint256 basePremium);

    event SecretarySuccessorsDefined(address[] successors);

    event SecretaryHandOverEnabled(address prefferedSuccessr);

    event SecretaryAccepted(address nSecretary);

    event EmergencyhandOverSecretary(address secretary);

    event ClaimSubmitted(address member, uint256 claimId);

    event AdditionalDayAdded(uint256 pEndTime);

    event FundClaimed(address claimant, uint256 amount, uint256 cId);

    event CommunityCollapsed(uint256 collapsedAt);

    event RefundWithdrawn(address member, uint256 amount);

    event ForfeitClaim(address claimant, uint256 claimId);

    event ShortFallDivided(
        uint256 totalAmount,
        uint256 pmAmount,
        uint256 fromSecrretary
    );

    event ManualCollapsedHappenend();

    event NextPeriodInitiated(
        uint256 periodId,
        uint256 coverage,
        uint256 baseAmount
    );

    event EmergencyBegan(uint256 emergencyStartedAt);

    event EmergencyPayment(address to, uint256 amount);
}