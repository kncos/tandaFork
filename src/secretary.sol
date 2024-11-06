// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secretary is Context {
    address internal _secretary;
    address[] internal secretarySuccessors;
    address internal upcomingSecretary;
    address[2] internal _emergencySecretaries;
    bool internal isHandingOver;
    uint256 internal emergencyHandOverStartedPeriod;
    uint256 internal handoverStartedAt;
    uint256 internal emergencyHandoverStartedAt;
    error SecretaryUnauthorizedSecretary(address account);
    error SecretaryInvalidOwner(address owner);
    event SecretaryTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialSecretary) {
        if (initialSecretary == address(0)) {
            revert SecretaryInvalidOwner(address(0));
        }
        _transferSecretary(initialSecretary);
    }
    modifier onlySecretary() {
        _checkSecretary();
        _;
    }

    function secretary() public view virtual returns (address) {
        return _secretary;
    }

    function getSecretarySuccessors() public view returns (address[] memory) {
        return secretarySuccessors;
    }

    function getUpcomingSecretary() public view returns (address) {
        return upcomingSecretary;
    }

    function getEmergencySecretaries() public view returns (address[2] memory) {
        return _emergencySecretaries;
    }

    function getIsHandingOver() public view returns (bool) {
        return isHandingOver;
    }

    function getEmergencyHandOverStartedPeriod() public view returns (uint256) {
        return emergencyHandOverStartedPeriod;
    }

    function getHandoverStartedAt() public view returns (uint256) {
        return handoverStartedAt;
    }

    function getEmergencyHandoverStartedAt() public view returns (uint256) {
        return emergencyHandoverStartedAt;
    }
    function _checkSecretary() internal view virtual {
        if (secretary() != _msgSender()) {
            revert SecretaryUnauthorizedSecretary(_msgSender());
        }
    }

    function _transferSecretary(address newSecretary) internal virtual {
        address oldOwner = _secretary;
        _secretary = newSecretary;
        emit SecretaryTransferred(oldOwner, newSecretary);
    }
}