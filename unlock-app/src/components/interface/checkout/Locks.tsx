import React, { useState } from 'react'
import { Lock } from './Lock'
import { LoadingLock } from './LockVariations'
import { usePaywallLocks } from '../../../hooks/usePaywallLocks'
import { useGetTokenBalance } from '../../../hooks/useGetTokenBalance'
import { TransactionInfo } from '../../../hooks/useCheckoutCommunication'

interface LocksProps {
  accountAddress: string
  lockAddresses: string[]
  emitTransactionInfo: (info: TransactionInfo) => void
}

type PurchasingLockAddress = string | null

export const Locks = ({
  lockAddresses,
  accountAddress,
  emitTransactionInfo,
}: LocksProps) => {
  const [purchasingLockAddress, setPurchasingLockAddress] = useState(
    null as PurchasingLockAddress
  )
  const { getTokenBalance, balances } = useGetTokenBalance(accountAddress)
  const { locks, loading } = usePaywallLocks(lockAddresses, getTokenBalance)

  if (loading) {
    return (
      <div>
        {lockAddresses.map(address => (
          <LoadingLock key={address} />
        ))}
      </div>
    )
  }

  return (
    <div>
      {locks.map(lock => (
        <Lock
          key={lock.name}
          lock={lock}
          purchasingLockAddress={purchasingLockAddress}
          setPurchasingLockAddress={setPurchasingLockAddress}
          emitTransactionInfo={emitTransactionInfo}
          balances={balances}
        />
      ))}
    </div>
  )
}
