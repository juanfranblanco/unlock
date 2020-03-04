pragma solidity 0.5.16;

import '../interfaces/hooks/ILockKeyPurchaseHook.sol';
import '../interfaces/hooks/ILockKeyCancelHook.sol';

/**
 * @title Test contract for lock event hooks.
 * @author Nick Mancuso (unlock-protocol.com)
 */
contract TestEventHooks is ILockKeyPurchaseHook, ILockKeyCancelHook
{
  event OnKeyPurchase(
    address lock,
    address from,
    address to,
    address referrer,
    uint keyPrice,
    bytes data
  );
  event OnKeyCancel(
    address lock,
    address operator,
    address to,
    uint refund
  );

  uint public discount;

  function setDiscount(
    uint _discount
  ) public
  {
    discount = _discount;
  }

  function keyPurchase(
    address from,
    address to,
    address referrer,
    uint keyPrice,
    bytes calldata data
  ) external
    returns (uint)
  {
    emit OnKeyPurchase(msg.sender, from, to, referrer, keyPrice, data);
    return discount;
  }

  function keyPurchaseDiscount(
    address /*from*/,
    address /*to*/,
    address /*referrer*/,
    uint /*keyPrice*/,
    bytes calldata /*data*/
  ) external view
    returns (uint)
  {
    return discount;
  }

  function keyCancel(
    address operator,
    address to,
    uint refund
  ) external
  {
    emit OnKeyCancel(msg.sender, operator, to, refund);
  }
}