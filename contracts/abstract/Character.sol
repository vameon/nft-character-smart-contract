// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./WrappedAccessControl.sol";

abstract contract Character is WrappedAccessControl {
  error VampireNotExists();
  error EarnRatioIsZero();

  event VampireUpgrade(uint256 tokenId, uint256 gameLevel, uint256 earnRatio);
  event NewVampire(uint256 tokenId, address owner, uint256 earnRatio);

  struct Vampire {
    uint8 gameLevel;
    uint256 earnRatio;
  }

  mapping(uint256 => Vampire) private vampires;

  function upgradeVampire(
    uint256 _tokenId,
    uint256 _earnRatio
  ) external onlyRole(MINTER_ROLE) {
    if (vampires[_tokenId].earnRatio == 0) revert VampireNotExists();

    Vampire memory vampire = vampires[_tokenId];

    uint256 newEarnRatio = vampire.earnRatio + _earnRatio;
    uint8 newGameLevel = vampire.gameLevel + 1;

    vampires[_tokenId] = Vampire(newGameLevel, newEarnRatio);
    emit VampireUpgrade(_tokenId, newGameLevel, newEarnRatio);
  }

  function getVampire(uint256 _tokenId) external view returns (Vampire memory) {
    if (vampires[_tokenId].earnRatio == 0) revert VampireNotExists();
    return vampires[_tokenId];
  }

  function _initVampire(
    uint256 _tokenId,
    address _owner,
    uint256 _earnRatio
  ) internal {
    if (_earnRatio == 0) revert EarnRatioIsZero();

    vampires[_tokenId] = Vampire(1, _earnRatio);
    emit NewVampire(_tokenId, _owner, _earnRatio);
  }
}
