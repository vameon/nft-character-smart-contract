// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "./abstract/Character.sol";
import "./abstract/WrappedAccessControl.sol";

contract VameonNFT is ERC721AQueryable, WrappedAccessControl, Character {
  event MetadataUpdate(uint256 _tokenId);
  event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

  error BaseUriIsEmpty();
  error NoTokensMinted();
  error TokenNotExists();

  string private baseURI;

  constructor(
    string memory __baseURI
  ) ERC721A("VameonNFT", "NFTdEoV") WrappedAccessControl() {
    if (bytes(__baseURI).length == 0) revert BaseUriIsEmpty();
    baseURI = __baseURI;
  }

  function mint(
    address _receiver,
    uint256 _earnRatio
  ) external onlyRole(MINTER_ROLE) {
    _initVampire(_totalMinted(), _receiver, _earnRatio);
    _mint(_receiver, 1);
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  function setBaseURI(
    string memory _baseTokenURI
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    baseURI = _baseTokenURI;

    if (_totalMinted() > 0) {
      emit BatchMetadataUpdate(0, _totalMinted() - 1);
    }
  }

  function emitTokenMetadataUpdate(
    uint256 _tokenId
  ) external onlyRole(MINTER_ROLE) {
    if (!_exists(_tokenId)) revert TokenNotExists();
    emit MetadataUpdate(_tokenId);
  }

  function emitAllTokensMetadataUpdate() external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_totalMinted() == 0) revert NoTokensMinted();
    emit BatchMetadataUpdate(0, _totalMinted() - 1);
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public view override(ERC721A, IERC721A, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}
