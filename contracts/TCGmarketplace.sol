// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC1155/IERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";

contract TCGmarketplace is ERC1155Receiver, Ownable {
    struct Escrow {
        address nftOwner;
        address nftContract;
        uint256 nftID;
        uint256 nftAmount;
        uint256 animeAmount; // in wei
    }

    Escrow[] public escrows;

    /// @notice Seller lists an NFT for sale. Price is in exact wei (e.g., 0.01 ANIME = 10000000000000000)
    function createEscrow(
        address _nftContract,
        uint256 _nftID,
        uint256 _nftAmount,
        uint256 _animeAmountInWei
    ) public {
        require(
            IERC1155(_nftContract).balanceOf(msg.sender, _nftID) >= _nftAmount,
            "You don't own enough of this NFT"
        );

        escrows.push(Escrow({
            nftOwner: msg.sender,
            nftContract: _nftContract,
            nftID: _nftID,
            nftAmount: _nftAmount,
            animeAmount: _animeAmountInWei
        }));
    }

    /// @notice Seller cancels their escrow listing
    function removeEscrow(uint256 i) public {
        require(msg.sender == escrows[i].nftOwner, "Not your escrow");
        escrows[i] = escrows[escrows.length - 1];
        escrows.pop();
    }

    /// @notice Buyer sends exact ANIME (native) to purchase
    function buyWithAnime(uint256 i) external payable {
        Escrow memory e = escrows[i];
        require(msg.value >= e.animeAmount, "Not enough ANIME sent");

        // Transfer NFT
        IERC1155(e.nftContract).safeTransferFrom(
            e.nftOwner,
            msg.sender,
            e.nftID,
            e.nftAmount,
            ""
        );

        // Pay seller
        payable(e.nftOwner).transfer(e.animeAmount);

        // Remove escrow
        escrows[i] = escrows[escrows.length - 1];
        escrows.pop();
    }

    function getEscrow(uint256 i) public view returns (Escrow memory) {
        return escrows[i];
    }

    function getMyEscrowIndexes() public view returns (uint256[] memory) {
        uint256 count;
        for (uint256 i = 0; i < escrows.length; i++) {
            if (escrows[i].nftOwner == msg.sender) {
                count++;
            }
        }

        uint256[] memory indexes = new uint256[](count);
        uint256 j;
        for (uint256 i = 0; i < escrows.length; i++) {
            if (escrows[i].nftOwner == msg.sender) {
                indexes[j++] = i;
            }
        }

        return indexes;
    }

    // ERC-1155 receiver hooks
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}
