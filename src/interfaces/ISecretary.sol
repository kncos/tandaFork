// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISecretary {

    function secretary() external view returns (address);

    function getSecretarySuccessors() external view returns (address[] memory);

    function getUpcomingSecretary() external view returns (address);

    function getEmergencySecretaries() external view returns (address[2] memory);

    function getIsHandingOver() external view returns (bool);

    function getEmergencyHandOverStartedPeriod() external view returns (uint256);

    function getHandoverStartedAt() external view returns (uint256);

    function getEmergencyHandoverStartedAt() external view returns (uint256);
}