pragma solidity 0.5.16;


interface ILockKeyPurchaseHook
{
  /**
   * @notice If the lock owner has registered an implementer then this hook
   * is called with every key sold.
   * @param from the msg.sender making the purchase
   * @param to the account which will be granted a key
   * @param referrer the account which referred this key sale
   * @param keyPrice the amount paid for the key, in the lock's currency (ETH or a ERC-20 token)
   * This includes any discount granted by Unlock Protocol.
   * @param data arbitrary data populated by the front-end which initiated the sale
   * @return a discount off the `keyPrice` value
   * @dev the hook implementation may revert to cancel the sale
   */
  function keyPurchase(
    address from,
    address to,
    address referrer,
    uint256 keyPrice,
    bytes calldata data
  ) external
    returns (uint discount);

  /**
   * @notice Used to determine the purchase price before issueing a transaction.
   * @dev This should always return the same value that calling `keyPurchase` would.
   */
  function keyPurchaseDiscount(
    address from,
    address to,
    address referrer,
    uint256 keyPrice,
    bytes calldata data
  ) external view
    returns (uint discount);
}
