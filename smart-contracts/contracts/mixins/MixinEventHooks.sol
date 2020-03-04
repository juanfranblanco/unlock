pragma solidity 0.5.16;

import '../interfaces/hooks/ILockKeyPurchaseHook.sol';
import '../interfaces/hooks/ILockKeyCancelHook.sol';
import './MixinLockCore.sol';
import '@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol';

/**
 * @title Implements callback hooks for Locks.
 * @author Nick Mancuso (unlock-protocol.com)
 */
contract MixinEventHooks is
  MixinLockCore
{
  using Address for address;

  ILockKeyPurchaseHook public onKeyPurchaseHook;
  ILockKeyCancelHook public onKeyCancelHook;

  /**
   * @notice Allows a lock manager to add or remove an event hook
   */
  function setEventHooks(
    address _onKeyPurchaseHook,
    address _onKeyCancelHook
  ) external
    onlyLockManager()
  {
    require(_onKeyPurchaseHook == address(0) || _onKeyPurchaseHook.isContract(), 'INVALID_ON_KEY_SOLD_HOOK');
    require(_onKeyCancelHook == address(0) || _onKeyCancelHook.isContract(), 'INVALID_ON_KEY_CANCEL_HOOK');
    onKeyPurchaseHook = ILockKeyPurchaseHook(_onKeyPurchaseHook);
    onKeyCancelHook = ILockKeyCancelHook(_onKeyCancelHook);
  }

  /**
   * @dev called anytime a key is sold in order to inform the hook if there is one registered.
   * Params are from ILockKeyPurchaseHook
   */
  function _onKeyPurchase(
    address _to,
    address _referrer,
    uint _keyPrice,
    bytes memory _data
  ) internal
    returns (uint discount)
  {
    if(address(onKeyPurchaseHook) != address(0))
    {
      return onKeyPurchaseHook.keyPurchase(msg.sender, _to, _referrer, _keyPrice, _data);
    }
    return 0;
  }

  /**
   * @notice Used to determine the purchase price before issueing a transaction.
   * @dev Params are from ILockKeyPurchaseHook
   * This should always return the same value that calling `keyPurchase` would.
   * However it's possible the hook implementation is not consistent / correct.
   */
  function _onKeyPurchaseDiscount(
    address _to,
    address _referrer,
    uint _keyPrice,
    bytes memory _data
  ) internal view
    returns (uint discount)
  {
    if(address(onKeyPurchaseHook) != address(0))
    {
      return onKeyPurchaseHook.keyPurchaseDiscount(msg.sender, _to, _referrer, _keyPrice, _data);
    }
    return 0;
  }

  /**
   * @dev called anytime a key is canceled in order to inform the hook if there is one registered.
   */
  function _onKeyCancel(
    address _to,
    uint _refund
  ) internal
  {
    if(address(onKeyCancelHook) != address(0))
    {
      onKeyCancelHook.keyCancel(msg.sender, _to, _refund);
    }
  }
}
