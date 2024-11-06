// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./secretary.sol";
import "./util/tandapayEvents.sol";
import "./util/tandapayErrors.sol";

contract TandaPay is Secretary, ReentrancyGuard, TandaPayEvents, TandaPayErrors {

    // Private state variables for managing contract state and mappings for data
    IERC20 private paymentToken;  // ERC20 token used for payments
    uint256 private memberId;  // ID for members
    uint256 private subGroupId;  // ID for subgroups
    uint256 private claimId;  // ID for claims
    uint256 private periodId;  // ID for periods
    uint256 private totalCoverage;  // Total coverage amount
    uint256 private basePremium;  // Base premium amount
    uint256 public EmergencyStartTime; // Time an emergency starts
    bool private isManuallyCollapsed;  // Indicates if the community is manually collapsed
    uint256 private manuallyCollapsedPeriod;  // Period in which manual collapse occurred
    CommunityStates private communityStates;  // Enum tracking the state of the community
    
    // Mappings to store various relationships and state information
    mapping(uint256 => uint256[]) private periodIdWhiteListedClaims;
    mapping(uint256 => MemberInfo) private memberIdToMemberInfo;
    mapping(uint256 => SubGroupInfo) private subGroupIdToSubGroupInfo;
    mapping(uint256 => mapping(uint256 => ClaimInfo)) private periodIdToClaimIdToClaimInfo;
    mapping(uint256 => uint256[]) private periodIdToClaimIds;
    mapping(address => uint256) private memberToMemberId;
    mapping(uint256 => PeriodInfo) private periodIdToPeriodInfo;
    mapping(uint256 => bool) private isAMemberDefectedInPeriod;
    mapping(address => uint256) private defectedMembersLastSubGroupId;
    mapping(uint256 => bool) private isAllMemberNotPaidInPeriod;
    mapping(uint256 => uint256[]) private periodIdToDefectorsId;
    mapping(uint256 => ManualCollapse) private periodIdToManualCollapse;
    mapping(address => mapping(uint256 => uint256)) private memberAndPeriodIdToClaimId;

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

    modifier isZeroAddress(address user) {
        if (user == address(0)) {
            revert CannotBeZeroAddress();
        }
        _;
    }

    modifier isNotEmergency() { 
        if (communityStates == CommunityStates.EMERGENCY) {
            revert InEmergency();
        }
        _;
    }

    modifier isEmergency() { 
        if (communityStates != CommunityStates.EMERGENCY) {
            revert NotInEmergency();
        }
        if (block.timestamp < EmergencyStartTime + 24 hours) {
            revert EmergencyGracePeriod();
        }
        _;
    }

    modifier isNotCollapsed() { 
        if (communityStates == CommunityStates.COLLAPSED) {
            revert CommunityIsCollapsed();
        }
        _;
    }

    // Constructor to initialize the contract with a payment token and set initial state
    constructor(address _paymentToken, address owner) Secretary(owner) {
        paymentToken = IERC20(_paymentToken);
        communityStates = CommunityStates.INITIALIZATION;
    }

    /**
     * @dev Adds a new member to the community
     * @notice only secretary can call
     * @param _member address of new member to add
     */
    function addToCommunity(address _member) external isNotCollapsed onlySecretary isNotEmergency {
        // Check that the community is in a valid state to add members
        if (
            communityStates != CommunityStates.INITIALIZATION &&
            communityStates != CommunityStates.DEFAULT
        ) {
            revert NotInIniOrDef();
        }
        // Ensure the member is not already added
        if (memberToMemberId[_member] != 0) {
            revert AlreadyAdded();
        }

        memberId++;
        MemberInfo storage mInfo = memberIdToMemberInfo[memberId];
        mInfo.memberId = memberId;
        memberToMemberId[_member] = mInfo.memberId;
        mInfo.member = _member;
        mInfo.status = MemberStatus.Assigned;
        mInfo.assignment = AssignmentStatus.AddedBySecretery;
        emit AddedToCommunity(_member, memberId);
    }

    /**
     * @dev creates new subgroup
     * @notice only secretary can call
     */
    function createSubGroup() external isNotCollapsed onlySecretary isNotEmergency {
        subGroupId++;
        SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[subGroupId];
        sInfo.id = subGroupId;
        emit SubGroupCreated(subGroupId);
    }

    /**
     * @dev assign a member to a subgroup, with reorg option
     * @notice only secretary can call
     * @param _member address of new member to add
     * @param _sId subgroup Id
     * @param _isReorging flag that decides if this operation is part of a reorganization process
     */
    function assignToSubGroup(
        address _member,
        uint256 _sId,
        bool _isReorging
    ) external isNotCollapsed onlySecretary isNotEmergency {
        SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[_sId];
        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[_member]
        ];

        // Validate subgroup and member
        if (sInfo.id == 0) {
            revert InvalidSubGroup();
        }

        if (mInfo.member == address(0)) {
            revert InvalidMember();
        }

        // Add member to subgroup
        sInfo.members.push(mInfo.member);

        // for "reOrging" to work, member status must be PAID_INVALID
        if (_isReorging) {
            // Handle reorging status
            if (mInfo.status != MemberStatus.PAID_INVALID) {
                revert NotPaidInvalid();
            }
            // "ReOrged" means they are successfully reorganized into the group
            mInfo.status = MemberStatus.REORGED;
        } else {

            // if not re-orging... just assigned to group
            mInfo.assignment = AssignmentStatus.AssignedToGroup;
        }

        // Adjust subgroup validation status based on the number of members
        // a valid subgroup must have between 4 and 7 members according to this.
        mInfo.associatedGroupId = _sId;
        if (sInfo.members.length >= 4 && sInfo.members.length <= 7) {
            if (!sInfo.isValid) {
                sInfo.isValid = true;
            }
        } else {
            if (sInfo.isValid) {
                sInfo.isValid = false;
            }
        }

        emit AssignedToSubGroup(_member, _sId, _isReorging);
    }

    /**
     * @dev allows members (msg.sender) to join the community
     * @notice Can only join if community status is "DEFAULT"
     */
    function joinToCommunity() external nonReentrant isNotCollapsed isNotEmergency {
        // community state must be "default"
        if (communityStates != CommunityStates.DEFAULT) {
            revert NotInInDefault();
        }

        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[msg.sender]
        ];

        // Ensure member is in a valid status to join
        if (mInfo.status != MemberStatus.Assigned) {
            revert NotInAssigned();
        }

        // Calculate joining fee and transfer tokens
        uint256 saAmount = basePremium + ((basePremium * 20) / 100);
        uint256 joinFee = (saAmount * 11) / 12;

        mInfo.ISEscorwAmount += joinFee;
        mInfo.status = MemberStatus.New;
        mInfo.assignment = AssignmentStatus.ApprovedByMember;
        paymentToken.transferFrom(msg.sender, address(this), joinFee);
        emit JoinedToCommunity(mInfo.member, (saAmount * 11) / 12);
    }

    /**
     * @dev Transitions the community from INITIALIZATION to DEFAULT state and sets the total coverage amount.
     * @notice Can only be called by secretary
     * @param _coverage amount of coverage
     */
    function initiatDefaultStateAndSetCoverage(
        uint256 _coverage
    ) external onlySecretary isNotEmergency isNotCollapsed {
        if (communityStates != CommunityStates.INITIALIZATION) {
            revert NotInInitilization();
        }

        // Ensure minimum members and subgroups exist to initiate default state
        if (memberId < 12 || subGroupId < 3) {
            revert DFNotMet();
        }

        for (uint256 i = 1; i < 4; i++) {

            // revert if subMemberCount is more than 3.
            if (subGroupIdToSubGroupInfo[i].members.length < 4) {
                revert SGMNotFullfilled();
            }
        }

        // Transition community to default state and set total coverage
        communityStates = CommunityStates.DEFAULT;

        totalCoverage = _coverage;
        
        basePremium = _coverage / memberId; 
        emit DefaultStateInitiatedAndCoverageSet(_coverage);
    }

    /**
     * @dev Allows a member to approve or reject their assignment to a subgroup.
     * @param _shouldJoin true to approve assignment, false to reject
     */
    function approveSubGroupAssignment(bool _shouldJoin) external isNotEmergency isNotCollapsed {
        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[msg.sender]
        ];
        if (mInfo.associatedGroupId == 0) {
            revert NotAssignedYet();
        }

        SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[
            mInfo.associatedGroupId
        ];

        // Handle approval or rejection of subgroup assignment
        if (_shouldJoin) {
            if (mInfo.status == MemberStatus.REORGED) {
                mInfo.assignment = AssignmentStatus.ApprovedByMember;
            } else {
                mInfo.assignment = AssignmentStatus.AssignmentSuccessfull;
            }
        } else {
            uint256 index;
            for (uint256 i = 0; i < sInfo.members.length; i++) {
                if (sInfo.members[i] == msg.sender) {
                    index = i;
                }
            }
            sInfo.members[index] = sInfo.members[sInfo.members.length - 1];
            sInfo.members.pop();
            memberIdToMemberInfo[memberToMemberId[msg.sender]]
                .status = MemberStatus.USER_QUIT;
        }

        emit ApprovedGroupAssignment(
            msg.sender,
            mInfo.associatedGroupId,
            _shouldJoin
        );
    }

    /**
     * @dev Allows existing subgroup members to approve or reject a new member's assignment to their subgroup.
     * @notice new member must have "REORGED" status
     * @param _sId subgroup id
     * @param _nMemberId new member id
     * @param _accepted true if accepted, false if rejecet
     */
    function approveNewSubgroupMember(
        uint256 _sId,
        uint256 _nMemberId,
        bool _accepted
    ) external isNotEmergency isNotCollapsed {

        SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[_sId];
        MemberInfo storage mInfo = memberIdToMemberInfo[_nMemberId];

        // Validate reorg status
        if (mInfo.status != MemberStatus.REORGED) {
            revert NotReorged();
        }

        // Ensure the sender is part of the subgroup
        bool isIn;
        for (uint256 j = 0; j < sInfo.members.length; j++) {
            if (msg.sender == sInfo.members[j]) {
                isIn = true;
                break;
            }
        }
        if (!isIn) {
            revert NotIncluded();
        }

        // Handle acceptance or rejection of new subgroup member
        if (_accepted) {
            mInfo.status = MemberStatus.VALID;
            mInfo.assignment = AssignmentStatus.AssignmentSuccessfull;
        } else {
            mInfo.assignment = AssignmentStatus.CancelledGMember;
        }

        emit ApproveNewGroupMember(mInfo.member, msg.sender, _sId, _accepted);
    }

    /**
     * @dev Allows a member to exit their assigned subgroup.
     */
    function exitSubGroup() external isNotEmergency isNotCollapsed {
        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[msg.sender]
        ];

        // Validate that the member is assigned to a subgroup
        if (mInfo.associatedGroupId == 0) {
            revert NotAssignedYet();
        }

        SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[
            mInfo.associatedGroupId
        ];

        // Ensure the member is part of the subgroup
        bool isIn;
        for (uint256 j = 0; j < sInfo.members.length; j++) {
            if (msg.sender == sInfo.members[j]) {
                isIn = true;
                break;
            }
        }
        if (!isIn) {
            revert NotIncluded();
        }

        // Remove member from subgroup and update their status
        removeMemberFromArray(sInfo.members);

        if (mInfo.isPremiumPaid[periodId]) {
            mInfo.status = MemberStatus.PAID_INVALID;
        } else {
            mInfo.status = MemberStatus.UNPAID_INVALID;
        }

        mInfo.associatedGroupId = 0;

        // Invalidate the subgroup if it has too few members
        if (sInfo.members.length < 4) {
            sInfo.isValid = false;
            // Set all group members to PAID_INVALID... if the group is invalid due to too few members
            for (uint256 i = 0; i < sInfo.members.length; i++) {
                memberIdToMemberInfo[memberToMemberId[sInfo.members[i]]]
                    .status = MemberStatus.PAID_INVALID;
            }
        }

        emit ExitedFromSubGroup(mInfo.member, sInfo.id);
    }

    /**
     * @dev Whitelists a claim during the designated whitelist window, making it eligible for further processing.
     * @param _cId the claim id
     * @notice only callable by secretary
     */
    function whitelistClaim(uint256 _cId) external onlySecretary isNotEmergency isNotCollapsed {
        // Validate community state and time window
        // reverts if community is any state other than DEFAULT or FRACTURED
        if (
            communityStates != CommunityStates.DEFAULT &&
            communityStates != CommunityStates.FRACTURED
        ) {
            revert NotInDefOrFra();
        }
        
        uint256 startAt = periodIdToPeriodInfo[periodId].startedAt;
        // can only whitelist the claim if current time is within the current period (15 days)
        if (
            block.timestamp >
            startAt + (15 days) ||
            block.timestamp < startAt
        ) {
            revert NotWhitelistWindow();
        }

        // Validate claim existence and member eligibility
        // _cId must be unique. Cannot have the same cId linked to different periods.
        ClaimInfo storage cInfo = periodIdToClaimIdToClaimInfo[periodId][_cId];
        if (cInfo.id != _cId) {
            revert InValidClaim();
        }

        // Checks if claimant is valid.
        if (
            memberIdToMemberInfo[memberToMemberId[cInfo.claimant]].status !=
            MemberStatus.VALID ||
            !memberIdToMemberInfo[memberToMemberId[cInfo.claimant]]
                .eligibleForCoverageInPeriod[periodId]
        ) {
            revert ClaimantNotValidMember();
        }

        // Whitelist the claim
        cInfo.isWhitelistd = true;
        periodIdWhiteListedClaims[periodId].push(cInfo.id);

        emit ClaimWhiteListed(_cId);
    }

    /**
     * @dev Allows a member to defect from the community during the defect window, 
     * @dev altering their status and potentially affecting the community's state.
     * @notice defecting can only happen if a claim occured in the previous period
     */
    function defects() external isNotEmergency isNotCollapsed {
        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[msg.sender]
        ];
        SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[
            mInfo.associatedGroupId
        ];

        // Validate member existence
        if (mInfo.member == address(0)) {
            revert NotValidMember();
        }

        // Validate defect time window
        // user can defect in first 3 days only
        if (
            block.timestamp >
            periodIdToPeriodInfo[periodId].startedAt + (3 days) ||
            block.timestamp < periodIdToPeriodInfo[periodId].startedAt
        ) {
            revert NotDefectWindow();
        }

        // Ensure that a claim occurred in the previous period
        if (periodIdToClaimIds[periodId - 1].length == 0) {
            revert ClaimNoOccured();
        }

        // Update member status based on eligibility for coverage
        if (!mInfo.eligibleForCoverageInPeriod[periodId]) {
            // this happens if user is NOT eligible for coverage during current period
            mInfo.status = MemberStatus.USER_QUIT;
        } else {
            // this happens if user IS eligible for coverage during current period
            mInfo.status = MemberStatus.DEFECTED;
            removeMemberFromArray(sInfo.members);

            defectedMembersLastSubGroupId[mInfo.member] = mInfo
                .associatedGroupId;
            mInfo.associatedGroupId = 0;
            periodIdToDefectorsId[periodId].push(mInfo.memberId);
        }

        // Update member refund amount and reset escrow amounts
        mInfo.pendingRefundAmount = mInfo.cEscrowAmount + mInfo.ISEscorwAmount;
        mInfo.cEscrowAmount = 0;
        mInfo.ISEscorwAmount = 0;

        // Check if community state should change based on defectors
        if (communityStates == CommunityStates.DEFAULT) {
            uint256 DMCount;
            for (uint256 i = 1; i < memberId + 1; i++) {
                MemberInfo storage mInfo2 = memberIdToMemberInfo[i];
                if (mInfo2.status == MemberStatus.DEFECTED) {
                    DMCount++;
                }
            }
            // if 12% of users defected, fracture the community
            if (DMCount > ((memberId * 12) / 100)) {
                communityStates = CommunityStates.FRACTURED;
            }
        }

        // Mark the member as not eligible for coverage in the current period
        mInfo.eligibleForCoverageInPeriod[periodId] = false;

        // Mark the period as having a defector
        if (!isAMemberDefectedInPeriod[periodId]) {
            isAMemberDefectedInPeriod[periodId] = true;
        }

        emit MemberDefected(msg.sender, periodId);
    }

    /**
     * @dev Allows a member to pay their premium for the upcoming period, 
     * @dev either from their available withdrawal balance or directly via transfer.
     * @notice Validates the payment window, calculates the required payment, 
     * @notice and updates the member's escrow amounts and eligibility for coverage in the next period.
     * @param _useFromATW if true, pay from available balance, if false, must pay with token.
     */
    function payPremium(bool _useFromATW) external nonReentrant isNotEmergency isNotCollapsed {
        // Validate community state and payment window
        if (
            communityStates != CommunityStates.DEFAULT &&
            communityStates != CommunityStates.FRACTURED
        ) {
            revert NotInDefOrFra();
        }

        if (periodId > 0) {
            if (block.timestamp <
                periodIdToPeriodInfo[periodId].startedAt +
                    (27 days) ||
                block.timestamp > periodIdToPeriodInfo[periodId].willEndAt
            ) {
                revert NotPayWindow();
            }
        }
        
        PeriodInfo storage pInfo = periodIdToPeriodInfo[periodId + 1];
        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[msg.sender]
        ];

        // Validate member existence
        if (mInfo.member == address(0)) {
            revert NotValidMember();
        }

        // Validate assignment status
        if (
            mInfo.assignment != TandaPay.AssignmentStatus.AssignmentSuccessfull
        ) {
            revert NotInAssignmentSuccessfull();
        }

        // Validate member status
        if (
            mInfo.status == MemberStatus.DEFECTED ||
            mInfo.status == MemberStatus.USER_QUIT ||
            mInfo.status == MemberStatus.USER_LEFT
        ) {
            revert OutOfTheCommunity();
        }

        uint256 amountToPay = basePremium;
        uint256 saAmount = basePremium + ((basePremium * 20) / 100);

        // Adjust amount to pay if escrow amount is insufficient
        if (mInfo.ISEscorwAmount < saAmount) {
            amountToPay += saAmount - mInfo.ISEscorwAmount;
        }

        // This is going into periodId + 1, the next periodId
        pInfo.totalPaid += amountToPay;

        // Optionally use the available to withdraw amount for payment
        if (_useFromATW) {
            uint256 atwAmount = mInfo.availableToWithdraw;
            mInfo.availableToWithdraw = atwAmount > amountToPay
                ? atwAmount - amountToPay
                : 0;
            amountToPay = atwAmount > amountToPay ? 0 : amountToPay - atwAmount;
        }

        mInfo.cEscrowAmount += basePremium;

        // Adjust the escrow amount to the correct amount
        if (mInfo.ISEscorwAmount < saAmount) {
            mInfo.ISEscorwAmount += saAmount - mInfo.ISEscorwAmount;
        }

        // Update member status and eligibility for the next period
        if (
            (mInfo.status == MemberStatus.New ||
                mInfo.status == MemberStatus.VALID ||
                mInfo.status == MemberStatus.UNPAID_INVALID) &&
            mInfo.cEscrowAmount >= basePremium &&
            mInfo.ISEscorwAmount >= saAmount
        ) {
            if (mInfo.status != MemberStatus.VALID) {
                mInfo.status = MemberStatus.VALID;
            }
            mInfo.eligibleForCoverageInPeriod[periodId + 1] = true;
            mInfo.isPremiumPaid[periodId + 1] = true;
        }

        // Transfer the remaining amount if any
        if (amountToPay > 0) {
            paymentToken.transferFrom(msg.sender, address(this), amountToPay); //ADDTODOC: DID THIS LAST
        }

        emit PremiumPaid(msg.sender, periodId, amountToPay, _useFromATW);
    }

    /**
     * @dev Updates the total coverage amount for the community and recalculates the base premium accordingly.
     * @dev only callable by secretary
     * @notice can only update if community is not default or initializing
     * @param _coverage amount of coverage to assign
     */
    function updateCoverageAmount(uint256 _coverage) external onlySecretary isNotEmergency isNotCollapsed {
        // Validate community state
        if (
            communityStates != CommunityStates.INITIALIZATION &&
            communityStates != CommunityStates.DEFAULT
        ) {
            revert NotInIniOrDef();
        }

        // Update member status if coverage already exists
        if (totalCoverage != 0) {
            updateMemberStatus();
        }

        totalCoverage = _coverage;

        // Count the number of valid members
        uint256 totalValidCount;
        for (uint256 i = 1; i < memberId + 1; i++) {
            if (memberIdToMemberInfo[i].status == MemberStatus.VALID) {
                totalValidCount++;
            }
        }

        // Calculate the base premium based on the total valid members
        basePremium = _coverage / totalValidCount; 

        periodIdToPeriodInfo[periodId].coverage = totalCoverage;

        emit CoverageUpdated(_coverage, basePremium);
    }

    /**
     * @dev Defines a list of successor candidates for the Secretary role based on the community's size.
     * @dev only callable by secretary
     * @param _successors list of successors to the secretary
     */
    function defineSecretarySuccessor(
        address[] memory _successors
    ) external onlySecretary isNotCollapsed {
        // Ensure a minimum number of successors are provided based on the community size
        // if community size is between 12 and 35, then 2 successors is sufficient. If more than 35, need 6.
        uint256 memId = memberId; 
        if (memId >= 12 && memId <= 35) {
            if (_successors.length < 2) {
                revert NeedMoreSuccessor();
            }
        } else if (memId > 35) {
            if (_successors.length < 6) {
                revert NeedMoreSuccessor();
            }
        }

        // Ensure the successors are valid members
        for (uint256 i = 0; i < _successors.length; i++) {
            bool isIn;
            for (uint256 j = 1; j < memId + 1; j++) {
                if (_successors[i] == memberIdToMemberInfo[j].member) {
                    isIn = true;
                    break;
                }
            }
            if (!isIn) {
                revert NotIncluded();
            }

            secretarySuccessors.push(_successors[i]);
        }

        emit SecretarySuccessorsDefined(_successors);
    }

    /**
     * @dev Initiates the handover process for the Secretary role to a preferred successor.
     * @dev only callable by secretary
     * @param _prefferedSuccessor address to be the new secretary
     */
    function handoverSecretary(
        address _prefferedSuccessor
    ) external onlySecretary /*isZeroAddress(_prefferedSuccessor)*/ isNotCollapsed {
        // Ensure the preferred successor is in the list of successors
        if (_prefferedSuccessor != address(0)) {
            bool isIn;
            for (uint256 j = 0; j < secretarySuccessors.length; j++) {
                if (_prefferedSuccessor == secretarySuccessors[j]) {
                    isIn = true;
                    break;
                }
            }
            if (!isIn) {
                revert NotIncluded();
            }
        }

        upcomingSecretary = _prefferedSuccessor;
        handoverStartedAt = block.timestamp;
        isHandingOver = true;

        emit SecretaryHandOverEnabled(_prefferedSuccessor);
    }

    /**
     * @dev Allows a designated successor to accept the Secretary role, completing the handover process.
     */
    function secretaryAcceptance() external isNotCollapsed {
        // Validate that the handover process is active
        if (!isHandingOver) {
            revert NotHandingOver();
        }

        // Ensure the caller is one of the successors
        bool isIn;
        for (uint256 i = 0; i < secretarySuccessors.length; i++) {
            if (msg.sender == secretarySuccessors[i]) {
                isIn = true;
            }
        }
        if (!isIn) {
            revert NotIncluded();
        }

        isHandingOver = false;

        // If the caller is the upcoming secretary, transfer the role, pop user from successor list
        if (msg.sender == upcomingSecretary) {
            _transferSecretary(msg.sender);
            uint256 index;
            for (uint256 i = 0; i < secretarySuccessors.length; i++) {
                if (msg.sender == secretarySuccessors[i]) {
                    index = i;
                }
            }
            secretarySuccessors[index] = secretarySuccessors[
                secretarySuccessors.length - 1
            ];
            secretarySuccessors.pop();
        } else {
            if (
                upcomingSecretary != address(0) &&
                block.timestamp < handoverStartedAt + 24 hours
            ) {
                revert TimeNotPassed();
            }

            if (msg.sender == secretarySuccessors[0]) {
                _transferSecretary(secretarySuccessors[0]);
                secretarySuccessors[0] = secretarySuccessors[
                    secretarySuccessors.length - 1
                ];
                secretarySuccessors.pop();
            } else {
                revert NotFirstSuccessor();
            }
        }

        emit SecretaryAccepted(msg.sender);
    }

    /**
     * @dev Facilitates an emergency handover of the Secretary role when two designated successors agree.
     * @param _eSecretary emergency successor address
     */
    function emergencyHandOverSecretary(address _eSecretary) external isZeroAddress(_eSecretary) isNotCollapsed {
        // Validate that the caller is a valid member
        bool isIn;
        uint256 memId = memberToMemberId[msg.sender];
        if (
            memId != 0 &&
            memberIdToMemberInfo[memId].status ==
            MemberStatus.VALID
        ) {
            isIn = true;
        }
        if (!isIn) {
            revert NotIncluded();
        }

        // Ensure the emergency secretary is in the successor list
        bool isInES;
        for (uint256 i = 0; i < secretarySuccessors.length; i++) {
            if (_eSecretary == secretarySuccessors[i]) {
                isInES = true;
            }
        }
        if (!isInES) {
            revert NotInSuccessorList();
        }

        // Handle the emergency handover logic
        if (
            _emergencySecretaries[0] == address(0) &&
            _emergencySecretaries[1] == address(0) &&
            emergencyHandOverStartedPeriod == periodId
        ) {
            revert SamePeriod();
        }
        if (_emergencySecretaries[0] == address(0)) {
            _emergencySecretaries[0] = _eSecretary;
            emergencyHandoverStartedAt = block.timestamp;
            emergencyHandOverStartedPeriod = periodId;
        } else {
            if (
                block.timestamp <
                emergencyHandoverStartedAt + (1 days) &&
                emergencyHandOverStartedPeriod == periodId
            ) {
                _emergencySecretaries[1] = _eSecretary;
            } else {
                if (
                    block.timestamp >
                    emergencyHandoverStartedAt + (1 days) &&
                    emergencyHandOverStartedPeriod != periodId
                ) {
                    _emergencySecretaries[0] = _eSecretary;
                    emergencyHandoverStartedAt = block.timestamp;
                    emergencyHandOverStartedPeriod = periodId;
                } else {
                    revert SamePeriod();
                }
            }
        }

        // Finalize the emergency handover if both emergency secretaries agree
        if (
            _emergencySecretaries[0] != address(0) &&
            _emergencySecretaries[1] != address(0)
        ) {
            uint256 index;
            if (_emergencySecretaries[0] == _emergencySecretaries[1]) {
                _transferSecretary(_emergencySecretaries[0]);

                for (uint256 i = 0; i < secretarySuccessors.length; i++) {
                    if (secretarySuccessors[i] == _emergencySecretaries[0]) {
                        index = i;
                    }
                }
            } else {
                _transferSecretary(secretarySuccessors[0]);
                index = 0;
            }
            _emergencySecretaries[0] = address(0);
            _emergencySecretaries[1] = address(0);
            secretarySuccessors[index] = secretarySuccessors[
                secretarySuccessors.length - 1
            ];
            secretarySuccessors.pop();
        }

        emit EmergencyhandOverSecretary(_eSecretary);
    }

    /**
     * @dev Allows the Secretary to inject additional funds into the contract during the injection window to cover a shortfall.
     * @notice only secretary can call
     */
    function injectFunds() external nonReentrant onlySecretary isNotEmergency isNotCollapsed {
        // Validate the injection window and ensure a claim occurred
        // injection window is first 3 days from start
        uint256 pId = periodId;
        _checkInjectionWindow(pId);
        _ensureClaimOccured(pId); 

        PeriodInfo storage pInfo = periodIdToPeriodInfo[periodId];
        if (pInfo.totalPaid >= pInfo.coverage) {
            revert CoverageFullfilled();
        }

        // Calculate the shortfall and transfer the amount to the contract
        uint256 sAmount = pInfo.coverage - pInfo.totalPaid;
        
        pInfo.totalPaid += sAmount;
        paymentToken.transferFrom(msg.sender, address(this), sAmount);
        emit FundInjected(sAmount);
    }

    /**
     * @dev Reverts if time is beyond first 3 days of a period
     * @param period the period Id
     */
    function _checkInjectionWindow(uint256 period) internal view {
        if (
            block.timestamp < periodIdToPeriodInfo[period].startedAt ||
            block.timestamp >
            periodIdToPeriodInfo[period].startedAt + (3 days)
        ) {
            revert NotInInjectionWindow();
        }
    }

    /**
     * @dev Reverts if no claim ids exist in a given period
     * @param period the period Id
     */
    function _ensureClaimOccured(uint256 period) internal view {
        if (periodIdToPeriodInfo[period].claimIds.length == 0) {
            revert NoClaimOccured();
        }
    }

    /**
     * @dev Divides any shortfall in coverage among the valid members during the injection window.
     * @notice only secretary can call
     */
    function divideShortFall() external nonReentrant onlySecretary isNotEmergency isNotCollapsed {
        // Validate the injection window and ensure a claim occurred
        uint256 pId = periodId;
        _checkInjectionWindow(pId);

        _ensureClaimOccured(pId);

        PeriodInfo storage pInfo = periodIdToPeriodInfo[periodId];
        if (pInfo.totalPaid >= pInfo.coverage) {
            revert CoverageFullfilled();
        }

        // Calculate the shortfall amount per valid member
        uint256 sAmount = pInfo.coverage - pInfo.totalPaid;
        uint256 validMCount;
        uint256 mvAmount;
        uint256 member = memberId;
        for (uint256 i = 1; i < member + 1; i++) {
            MemberInfo storage mInfo = memberIdToMemberInfo[i];
            if (mInfo.status == MemberStatus.VALID) {
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

        // Distribute the shortfall among valid members
        uint256 spMember = sAmount / validMCount < mvAmount
            ? sAmount / validMCount
            : mvAmount;
        uint256 secretaryAmount;

        for (uint256 j = 1; j < member + 1; j++) {
            MemberInfo storage mInfo = memberIdToMemberInfo[j];
            if (mInfo.status == MemberStatus.VALID) {
                if (mInfo.ISEscorwAmount >= spMember) {
                    mInfo.ISEscorwAmount -= spMember;
                }
            }
        }

        periodIdToPeriodInfo[periodId].totalPaid += sAmount;
        if (spMember * validMCount < sAmount) {
            
            secretaryAmount = sAmount - (spMember * validMCount);
            paymentToken.transferFrom(
                msg.sender,
                address(this),
                secretaryAmount
            );
        }

        emit ShortFallDivided(sAmount, spMember, secretaryAmount);
    }

    /**
     * @dev Extends the current period by adding an extra day.
     * @notice only secretary can call
     */
    function addAdditionalDay() external onlySecretary isNotEmergency isNotCollapsed {
        periodIdToPeriodInfo[periodId].willEndAt =
            periodIdToPeriodInfo[periodId].willEndAt +
            (1 days);
        emit AdditionalDayAdded(periodIdToPeriodInfo[periodId].willEndAt);
    }

    /**
     * @dev Allows the Secretary to manually collapse the community, transitioning it to the COLLAPSED state.
     * @notice only secretary can call
     */
    function manualCollapsBySecretary() external onlySecretary isNotCollapsed isNotEmergency {

        isManuallyCollapsed = true;
        communityStates = CommunityStates.COLLAPSED;
        manuallyCollapsedPeriod = periodId;
        periodIdToManualCollapse[periodId].startedAT = block.timestamp;
        periodIdToManualCollapse[periodId].availableToTurnTill =
            periodIdToPeriodInfo[periodId].willEndAt +
            (4 days);

        emit ManualCollapsedHappenend();
    }

    /**
     * @dev Cancels an ongoing manual collapse if the conditions allow, returning the community to the DEFAULT state.
     * @notice only secretary can call
     */
    function cancelManualCollapsBySecretary() external onlySecretary isNotEmergency {
        // Validate that a manual collapse is active and within the allowed time to cancel
        if (!isManuallyCollapsed) {
            revert NotInManualCollaps();
        }
        if (
            block.timestamp >
            periodIdToManualCollapse[manuallyCollapsedPeriod]
                .availableToTurnTill
        ) {
            revert TurningTimePassed();
        }

        isManuallyCollapsed = false;
        communityStates = CommunityStates.DEFAULT;

        emit ManualCollapsedCancelled(block.timestamp);
    }

    /**
     * @dev removes msg.sender from a storage array
     * @param members storage array from subgroup struct
     */
    function removeMemberFromArray(address[] storage members) internal {
        uint256 index;
        for (uint256 i = 0; i < members.length; i++) {
            if (msg.sender == members[i]) {
                index = i;
            }
        }
        members[index] = members[members.length - 1];
        members.pop();
    }

    /**
     * @dev Allows a member to leave their subgroup, resetting their status and adjusting the subgroup's validity.
     * @notice Removes the member from the subgroup, updates their eligibility and escrow amounts, 
     * @notice and potentially invalidates the subgroup.
     */
    function leaveFromASubGroup() external isNotEmergency isNotCollapsed {
        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[msg.sender]
        ];
        SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[
            mInfo.associatedGroupId
        ];

        // Validate member existence
        if (mInfo.member == address(0)) {
            revert NotValidMember();
        }

        // Remove member from subgroup and update status
        mInfo.associatedGroupId = 0;
        mInfo.status = MemberStatus.PAID_INVALID;
        removeMemberFromArray(sInfo.members);
        
        

        // Update member eligibility and refund amount
        mInfo.eligibleForCoverageInPeriod[periodId] = false;
        uint256 rAmount = mInfo.cEscrowAmount + mInfo.ISEscorwAmount;
        mInfo.cEscrowAmount = 0;
        mInfo.ISEscorwAmount = 0;
        mInfo.availableToWithdraw += rAmount;

        // Invalidate the subgroup if it has too few members
        if (sInfo.members.length < 4) {
            sInfo.isValid = false;
            for (uint256 i = 0; i < sInfo.members.length; i++) {
                MemberInfo storage mInfo2 = memberIdToMemberInfo[
                    memberToMemberId[sInfo.members[i]]
                ];
                mInfo2.status = MemberStatus.PAID_INVALID;
                uint256 rAmount2 = mInfo2.cEscrowAmount + mInfo2.ISEscorwAmount;
                mInfo2.cEscrowAmount = 0;
                mInfo2.ISEscorwAmount = 0;
                mInfo2.availableToWithdraw += rAmount2;
            }
        }

        emit LeavedFromGroup(mInfo.member, sInfo.id, mInfo.memberId);
    }

    /**
     * @dev Secretary enters emergency state
     * @notice only secretary can call
     */
    function beginEmergency() external onlySecretary isNotEmergency isNotCollapsed { // ADDTODOC: Add emergency state
        communityStates = CommunityStates.EMERGENCY;
        EmergencyStartTime = block.timestamp;
        emergencyRefund();
        emit EmergencyBegan(block.timestamp);
    }

    /**
     * @dev Secretary sends out emergency funding
     * @notice only secretary can call
     * @notice can only be called if 24 hours elapses post-emergency declaration
     * @param to the address to send emergency fund
     * @param amount amount of tokens to send
     */
    function EmergencyWithdrawal(address to, uint256 amount) external nonReentrant onlySecretary isEmergency isNotCollapsed isZeroAddress(to) {
        if (paymentToken.balanceOf(address(this)) < amount) {
            revert InsufficientFunds();
        }
        paymentToken.transfer(to, amount);
        emit EmergencyPayment(to, amount);
    }

    /**
     * @dev Secretary Ends Emergency, collapses community
     * @notice only secretary can call
     * @notice can only be called if 24 hours elapses post-emergency declaration
     */
    function endEmergency() external nonReentrant onlySecretary isEmergency {
        communityStates = CommunityStates.COLLAPSED;
        uint256 bal = paymentToken.balanceOf(address(this));
        if (bal < basePremium) {
            paymentToken.transfer(msg.sender, bal);
        }
        emit CommunityCollapsed(block.timestamp);
    }

    /**
     * @dev Advances the community to the next period, resetting the state and recalculating premiums if necessary.
     * @notice only secretary can call
     */
    function AdvanceToTheNextPeriod() external onlySecretary isNotEmergency isNotCollapsed {
        // Validate community state and ensure the previous period has ended
        if (
            communityStates != CommunityStates.DEFAULT &&
            communityStates != CommunityStates.FRACTURED
        ) {
            revert NotInDefOrFra();
        }
        if (
            periodId > 0 &&
            block.timestamp < periodIdToPeriodInfo[periodId].willEndAt
        ) {
            revert PrevPeriodNotEnded();
        }

        periodId++;

        // Adjust community state based on recent periods
        if (communityStates == CommunityStates.FRACTURED) {
            if (
                !isAMemberDefectedInPeriod[periodId - 1] &&
                !isAMemberDefectedInPeriod[periodId - 2] &&
                !isAMemberDefectedInPeriod[periodId - 3] &&
                !isAllMemberNotPaidInPeriod[periodId - 1] &&
                !isAllMemberNotPaidInPeriod[periodId - 2] &&
                !isAllMemberNotPaidInPeriod[periodId - 3]
            ) {
                communityStates = CommunityStates.DEFAULT;
            }
        }

        // Initialize the next period and update member status
        PeriodInfo storage pInfo = periodIdToPeriodInfo[periodId];
        pInfo.startedAt = block.timestamp;

        if (totalCoverage != 0) {
            updateMemberStatus();
            for (uint256 i = 1; i < subGroupId + 1; i++) {
                SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[i];
                // invalidate if subgroup requirements collapsed (i.e. too few members)
    
                if (sInfo.members.length < 4 && sInfo.members.length > 0) {
                    for (uint256 m = 0; m < sInfo.members.length; m++) {
                        MemberInfo storage mInfo = memberIdToMemberInfo[
                            memberToMemberId[sInfo.members[m]]
                        ];
                        // If they were valid before, they are now set to USER_LEFT, and get ATW credited
                        if (mInfo.status == MemberStatus.VALID) {
                            mInfo.status = MemberStatus.USER_LEFT;
                            uint256 rAmount = mInfo.cEscrowAmount +
                                mInfo.ISEscorwAmount;
                            mInfo.cEscrowAmount = 0;
                            mInfo.ISEscorwAmount = 0;
                            mInfo.availableToWithdraw = rAmount;
                        }
                    }
                }
            }

            // Count the number of valid members and calculate the base premium
            uint256 VMCount;
            for (uint256 i = 1; i < memberId + 1; i++) {
                if (memberIdToMemberInfo[i].status == MemberStatus.VALID) {
                    VMCount++;
                }
            }

            if (periodId > 1) {
                if (VMCount == 0) {
                    communityStates = CommunityStates.COLLAPSED;
                    emit CommunityCollapsed(block.timestamp);
                    
                } else {
                    basePremium = totalCoverage / VMCount;
                }
                
            }
        }

        pInfo.willEndAt = block.timestamp + (30 days);
        pInfo.coverage = totalCoverage;

        emit NextPeriodInitiated(periodId, totalCoverage, basePremium);
    }

    /**
     * @dev Updates the status of all members based on their premium payment status and the current community state.
     */
    function updateMemberStatus() public isNotEmergency isNotCollapsed {
        // assign memberId to local variable for gas saving
        for (uint256 i = 1; i < memberId + 1; i++) {
            MemberInfo storage mInfo = memberIdToMemberInfo[i];
            if (
                mInfo.status != MemberStatus.UnAssigned &&
                mInfo.status != MemberStatus.New &&
                mInfo.status != MemberStatus.Assigned
            ) {
                if (mInfo.isPremiumPaid[periodId]) {
                    mInfo.status = MemberStatus.VALID;
                } else {
                    if (
                        mInfo.status == MemberStatus.VALID &&
                        !isAllMemberNotPaidInPeriod[periodId - 1]
                    ) {
                        isAllMemberNotPaidInPeriod[periodId - 1] = true;
                    }
                }

                // if community is in a fine state and member has not paid premium, update member info
                if (
                    communityStates == CommunityStates.DEFAULT &&
                    !mInfo.isPremiumPaid[periodId]
                ) {
                    mInfo.status = MemberStatus.UNPAID_INVALID;
                    mInfo.eligibleForCoverageInPeriod[periodId] = false;
                }

                if (
                    communityStates == CommunityStates.FRACTURED &&
                    mInfo.status != MemberStatus.DEFECTED &&
                    !mInfo.isPremiumPaid[periodId]
                ) {
                    mInfo.status = MemberStatus.USER_LEFT;
                    mInfo.eligibleForCoverageInPeriod[periodId] = false;
                }

                emit MemberStatusUpdated(mInfo.member, mInfo.status);
            }
        }
    }

    /**
     * @dev Allows a member to withdraw their claim fund, either fully or forfeiting it, depending on the provided flag.
     * @param isForfeit allows member to choose to leave their claim instead
     */
    function withdrawClaimFund(bool isForfeit) external nonReentrant isNotEmergency isNotCollapsed {
        // claims can only happen between day 16 and day 26 of the period
        if (
            block.timestamp <
            periodIdToPeriodInfo[periodId].startedAt + (16 days) ||
            block.timestamp >=
            periodIdToPeriodInfo[periodId].startedAt + (26 days)
        ) {
            revert NotClaimWindow();
        }

        // get claim object, check that sender is claimant, and that it exists (plus other basic checks)
        uint256 prevPeriod = periodId - 1;
        ClaimInfo storage cInfo = periodIdToClaimIdToClaimInfo[prevPeriod][
            memberAndPeriodIdToClaimId[msg.sender][prevPeriod]
        ];
        if (msg.sender != cInfo.claimant) {
            revert NotClaimant();
        }
        if (!cInfo.isWhitelistd) {
            revert NotWhiteListed();
        }
        if (cInfo.isClaimed) {
            revert AlreadyClaimed();
        }
        if (
            memberIdToMemberInfo[memberToMemberId[cInfo.claimant]].status !=
            MemberStatus.VALID
        ) {
            revert ClaimantNotValidMember();
        }
        cInfo.isClaimed = true;
        if (isForfeit) {
            cInfo.claimAmount = 0;
            emit ForfeitClaim(cInfo.claimant, cInfo.id);
            return;
        }

        // this checks for how many approved claims exist for the period in question
        // wlCount is the number of approved claims
        uint256[] memory __ids = periodIdToClaimIds[prevPeriod];
        uint256 wlCount;
        for (uint256 i = 0; i < __ids.length; i++) {
            if (
                periodIdToClaimIdToClaimInfo[prevPeriod][__ids[i]].isWhitelistd
            ) {
                wlCount++;
            }
        }
        // cAmount equals total amount of coverage in the previous period divided by the total number of approved claims for that period?
        uint256 cAmount = periodIdToPeriodInfo[prevPeriod].coverage / wlCount;
        uint256 totalClaimableAmount;
        uint256 VMCount;

        // VMCount is # of valid members
        for (uint256 j = 1; j < memberId + 1; j++) {
            if (memberIdToMemberInfo[j].status == MemberStatus.VALID) {
                VMCount++;
            }
        }

        // here we check for the users who defected in this current period. If there are defectors in this current period, we add them to the count of "valid members"
        uint256[] memory _dids;
        if (isAMemberDefectedInPeriod[periodId]) {
            _dids = periodIdToDefectorsId[periodId];
            VMCount += _dids.length;
        }
        

        uint256 pmAmount = cAmount / VMCount;
        uint256 pmShortAmount;
        
        for (uint256 k = 1; k < memberId + 1; k++) {
            MemberInfo storage mInfo = memberIdToMemberInfo[k];
            if (mInfo.status == MemberStatus.VALID) {
                if (mInfo.cEscrowAmount < pmAmount) {
                    pmShortAmount += (pmAmount - mInfo.cEscrowAmount);
                    pmAmount = mInfo.cEscrowAmount;
                }
                mInfo.cEscrowAmount -= pmAmount;
                totalClaimableAmount += pmAmount;
            }
        }

        // dids > 0 means there are defectors in this scenario
        if (_dids.length > 0) {
            // if shortAmount is zero, leave pmAmount alone. Else, add to it (shortAmount divided by defectors)
            pmAmount = pmShortAmount == 0
                ? pmAmount
                : pmAmount + (pmShortAmount / _dids.length);
            // loop through each defector...
            for (uint256 i = 0; i < _dids.length; i++) {

                // get subinfo group by finding out defectedMembers last subgroup but also looking up address by defector number...
                SubGroupInfo storage sInfo = subGroupIdToSubGroupInfo[
                    defectedMembersLastSubGroupId[
                        memberIdToMemberInfo[_dids[i]].member
                    ]
                ];
                address[] memory __members = sInfo.members;

                uint256 vmInG;
                uint256 minimumVMAmount;

                // iterate over subgroup members
                for (uint256 k = 0; k < __members.length; k++) {
                    MemberInfo storage mInfoG = memberIdToMemberInfo[
                        memberToMemberId[__members[k]]
                    ];
                    if (mInfoG.status == MemberStatus.VALID) {
                        vmInG++;
                        if (
                            minimumVMAmount != 0 &&
                            minimumVMAmount > mInfoG.ISEscorwAmount
                        ) {
                            minimumVMAmount = mInfoG.ISEscorwAmount;
                        } else if (minimumVMAmount == 0) {
                            minimumVMAmount = mInfoG.ISEscorwAmount * 2;
                        }
                    }
                }
                // pmAmount divided by number of valid members in group
                // If this is less than minVMAmount, leave it. Otherwise, set to minVMAmount
                uint256 ATDeduct = pmAmount / vmInG;
                ATDeduct = ATDeduct < minimumVMAmount
                    ? ATDeduct
                    : minimumVMAmount;

                // iterate over members, deduct ATDeduct from ISEscrowAmount (per user)
                // add ATDeduct to total claimable
                for (uint256 m = 0; m < __members.length; m++) {
                    MemberInfo storage mInfoG2 = memberIdToMemberInfo[
                        memberToMemberId[__members[m]]
                    ];
                    if (mInfoG2.status == MemberStatus.VALID) {
                        mInfoG2.ISEscorwAmount -= ATDeduct;
                        totalClaimableAmount += ATDeduct;
                    }
                }
            }
        }

        if (totalClaimableAmount >= cAmount) {
            cInfo.claimAmount = cAmount;
            paymentToken.transfer(cInfo.claimant, cAmount); // ADDTODOC: perform transfer last
            
            emit FundClaimed(cInfo.claimant, cAmount, cInfo.id);
        } else {
            communityStates = CommunityStates.COLLAPSED;
            emit CommunityCollapsed(block.timestamp);
        }
    }

    /**
     * @dev Allows a member to submit a claim during the claim submission window.
     */
    function submitClaim() external isNotEmergency isNotCollapsed {
        // Validate submission time window
        // submission window is the first 14 days of period.
        if (
            block.timestamp >
            periodIdToPeriodInfo[periodId].startedAt + (14 days) ||
            block.timestamp < periodIdToPeriodInfo[periodId].startedAt
        ) {
            revert NotClaimSubmittionWindow();
        }

        // Validate member eligibility for coverage
        if (
            periodId > 1 &&
            !memberIdToMemberInfo[memberToMemberId[msg.sender]]
                .eligibleForCoverageInPeriod[periodId]
        ) {
            revert NotInCovereged();
        }

        claimId++;

        // Ensure the member has not already submitted a claim
        if (memberAndPeriodIdToClaimId[msg.sender][periodId] == 0) {
            memberAndPeriodIdToClaimId[msg.sender][periodId] = claimId;
        } else {
            revert AlreadySubmitted();
        }

        // Stores claim information
        // This function does not take into account any details regarding the claim. Just acts as a record.
        ClaimInfo storage cInfo = periodIdToClaimIdToClaimInfo[periodId][claimId];
        periodIdToClaimIds[periodId].push(claimId);
        periodIdToPeriodInfo[periodId].claimIds.push(claimId);
        cInfo.id = claimId;
        cInfo.claimant = msg.sender;
        cInfo.SGId = memberIdToMemberInfo[memberToMemberId[msg.sender]]
            .associatedGroupId;

        emit ClaimSubmitted(cInfo.claimant, claimId);
    }

    /**
     * @dev Issues refunds to members during the refund window, optionally transferring the funds directly to the members.
     * @param _shouldTransfer whether refunds should be transferred to users or not
     */
    function issueRefund(bool _shouldTransfer) external nonReentrant isNotEmergency isNotCollapsed onlySecretary {
        // Validate refund window and ensure no whitelisted claims exist
        if (
            block.timestamp >
            periodIdToPeriodInfo[periodId].startedAt + (4 days) ||
            block.timestamp <
            periodIdToPeriodInfo[periodId].startedAt + (3 days)
        ) {
            revert NotRefundWindow();
        }
        if (periodIdWhiteListedClaims[periodId - 1].length > 0) {
            revert WLCAvailable();
        }

        _issueRefund(_shouldTransfer);
    }

    /**
     * @dev emergency refund. Makes all funds refundable to members.
     */
    function emergencyRefund() public nonReentrant {
        if (communityStates != CommunityStates.COLLAPSED && communityStates != CommunityStates.EMERGENCY) {
            revert CannotEmergencyRefund();
        }
        uint256 memId = memberId;
        for (uint256 i = 1; i < memId + 1; i++) {
            MemberInfo storage mInfo = memberIdToMemberInfo[i];
            uint256 totalRefund;
            totalRefund += mInfo.cEscrowAmount + mInfo.ISEscorwAmount + mInfo.pendingRefundAmount + mInfo.availableToWithdraw;
            if (periodId > 3) {
                for(uint256 k = periodId; k <= periodId - 3; k--) {
                
                    totalRefund += mInfo.idToQuedRefundAmount[k];
                    mInfo.idToQuedRefundAmount[k] = 0;
                }
            } else {
                for(uint256 k; k <= periodId; k++) {
                
                    totalRefund += mInfo.idToQuedRefundAmount[k];
                    mInfo.idToQuedRefundAmount[k] = 0;
                }
            }
            
            mInfo.cEscrowAmount = 0;
            mInfo.ISEscorwAmount = 0;
            mInfo.pendingRefundAmount = 0;
            mInfo.availableToWithdraw = totalRefund;
        }
    }

    /**
     * @dev internal logic for refund issuance.
     * @dev also called when emergency state initiated.
     * @param _shouldTransfer whether refunds should be transferred to users or not
     */
    function _issueRefund(bool _shouldTransfer) internal {
        // Issue refunds for pending amounts and update availability to withdraw
        uint256 memId = memberId;
        for (uint256 i = 1; i < memId + 1; i++) {
            MemberInfo storage mInfo = memberIdToMemberInfo[i];
            if (mInfo.pendingRefundAmount > 0) {
                // TODO: optimize here
                uint256 pAmount = mInfo.pendingRefundAmount;
                mInfo.pendingRefundAmount = 0;
                mInfo.availableToWithdraw = pAmount;
            }

            // Handle refunds for previous periods based on community state
            
            if (
                periodId > 1 &&
                periodIdWhiteListedClaims[periodId - 1].length == 0 &&
                mInfo.cEscrowAmount > 0
            ) {
                if (
                    communityStates == CommunityStates.FRACTURED &&
                    periodIdWhiteListedClaims[periodId - 1].length == 0
                ) { 
                    uint256 qrAmount = mInfo.cEscrowAmount;
                    mInfo.cEscrowAmount = 0;
                    mInfo.idToQuedRefundAmount[periodId - 1] = qrAmount;
                } else {
                    uint256 uAmount = mInfo.cEscrowAmount;
                    mInfo.cEscrowAmount = 0;
                    mInfo.availableToWithdraw = uAmount;
                }
            }

            // Handle refunds from older periods
            if (periodId > 3) {
                if (mInfo.idToQuedRefundAmount[periodId - 3] > 0) {
                    mInfo.availableToWithdraw += mInfo.idToQuedRefundAmount[
                        periodId - 3
                    ];
                    mInfo.idToQuedRefundAmount[periodId - 3] = 0;
                }
            }

            // Transfer refund amounts if required
            if (_shouldTransfer && mInfo.availableToWithdraw > 0) {
                uint256 wAmount = mInfo.availableToWithdraw;
                mInfo.availableToWithdraw = 0;
                paymentToken.transfer(mInfo.member, wAmount);
            }
        }

        emit RefundIssued();
    }

    /**
     * @dev Allows a member to withdraw their available refund amount.
     */
    function withdrawRefund() external nonReentrant {
        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[msg.sender]
        ];

        uint256 wAmount = mInfo.availableToWithdraw;
        // Ensure there is a refund amount to withdraw
        if (wAmount == 0) {
            revert AmountZero();
        }
        mInfo.availableToWithdraw = 0;

        paymentToken.transfer(mInfo.member, wAmount);
        emit RefundWithdrawn(mInfo.member, wAmount);
    }

    // Various getter functions to retrieve contract state

    /**
     * @dev returns the address of the payment token
     */
    function getPaymentToken() external view returns (address) {
        return address(paymentToken);
    }

    /**
     * @dev returns the most recent memberId
     */
    function getCurrentMemberId() external view returns (uint256) {
        return memberId;
    }

    /**
     * @dev returns the most recent subGroupId
     */
    function getCurrentSubGroupId() external view returns (uint256) {
        return subGroupId;
    }

    /**
     * @dev returns the most recent claim Id
     */
    function getCurrentClaimId() external view returns (uint256) {
        return claimId;
    }

    /**
     * @dev returns the most recent period Id
     */
    function getPeriodId() external view returns (uint256) {
        return periodId;
    }

    /**
     * @dev returns the total coverage
     */
    function getTotalCoverage() external view returns (uint256) {
        return totalCoverage;
    }

    /**
     * @dev returns the base premium
     */
    function getBasePremium() external view returns (uint256) {
        return basePremium;
    }

    /**
     * @dev returns the manually collapsed Period
     * @notice the id of the period at which the community was collapsed
     */
    function getManuallyCollapsedPeriod() external view returns (uint256) {
        return manuallyCollapsedPeriod;
    }

    /**
     * @dev returns flag if community was manually collapsed
     */
    function getIsManuallyCollapsed() external view returns (bool) {
        return isManuallyCollapsed;
    }

    /**
     * @dev returns community states
     */
    function getCommunityState() external view returns (CommunityStates) {
        return communityStates;
    }

    /**
     * @dev returns subgroup information
     * @param _sId id of the subgroup
     */
    function getSubGroupIdToSubGroupInfo(
        uint256 _sId
    ) external view returns (SubGroupInfo memory) {
        return subGroupIdToSubGroupInfo[_sId];
    }

    /**
     * @dev returns claim info based on period and claim Id
     * @param _pId period Id
     * @param _cId claim Id (specific to period)
     */
    function getPeriodIdToClaimIdToClaimInfo(
        uint256 _pId,
        uint256 _cId
    ) external view returns (ClaimInfo memory) {
        return periodIdToClaimIdToClaimInfo[_pId][_cId];
    }

    /**
     * @dev returns array of claim Ids per period
     * @param _pId period Id
     */
    function getPeriodIdToClaimIds(
        uint256 _pId
    ) external view returns (uint256[] memory) {
        return periodIdToClaimIds[_pId];
    }

    /**
     * @dev returns array of defectors IDs per period
     * @param _pId period Id
     */
    function getPeriodIdToDefectorsId(
        uint256 _pId
    ) external view returns (uint256[] memory) {
        return periodIdToDefectorsId[_pId];
    }

    /**
     * @dev returns Manual Collapse info per period ID
     * @param _pId period Id
     */
    function getPeriodIdToManualCollapse(
        uint256 _pId
    ) external view returns (ManualCollapse memory) {
        return periodIdToManualCollapse[_pId];
    }

    /**
     * @dev returns the member Id
     * @param _member user address
     */
    function getMemberToMemberId(
        address _member
    ) external view returns (uint256) {
        return memberToMemberId[_member];
    }

    /**
     * @dev returns array of whitelisted claimIds per period
     * @param _pId period Id
     */
    function getPeriodIdWhiteListedClaims(
        uint256 _pId
    ) external view returns (uint256[] memory) {
        return periodIdWhiteListedClaims[_pId];
    }

    /**
     * @dev returns member info from address and member Id
     * @param _member user address
     * @param _pId member Id
     */
    function getMemberToMemberInfo(
        address _member,
        uint256 _pId
    ) external view returns (DemoMemberInfo memory) {
        MemberInfo storage mInfo = memberIdToMemberInfo[
            memberToMemberId[_member]
        ];
        uint256 pId = _pId == 0 ? periodId : _pId;
        DemoMemberInfo memory dInfo = DemoMemberInfo(
            mInfo.memberId,
            mInfo.associatedGroupId,
            mInfo.member,
            mInfo.cEscrowAmount,
            mInfo.ISEscorwAmount,
            mInfo.pendingRefundAmount,
            mInfo.availableToWithdraw,
            mInfo.eligibleForCoverageInPeriod[pId],
            mInfo.isPremiumPaid[pId],
            mInfo.idToQuedRefundAmount[pId],
            mInfo.status,
            mInfo.assignment
        );
        return dInfo;
    }

    /**
     * @dev returns flag if member has defected at a give period
     * @param _pId period Id
     */
    function getIsAMemberDefectedInPeriod(
        uint256 _pId
    ) external view returns (bool) {
        return isAMemberDefectedInPeriod[_pId];
    }

    /**
     * @dev returns period information
     * @param _pId period Id
     */
    function getPeriodIdToPeriodInfo(
        uint256 _pId
    ) external view returns (PeriodInfo memory) {
        return periodIdToPeriodInfo[_pId];
    }

    /**
     * @dev returns flag whether all members in a period have paid
     * @param _pId period Id
     */
    function getIsAllMemberNotPaidInPeriod(
        uint256 _pId
    ) external view returns (bool) {
        return isAllMemberNotPaidInPeriod[_pId];
    }
}