const { constants } = require('hardlydifficult-ethereum-contracts')
const BigNumber = require('bignumber.js')
const { reverts } = require('truffle-assertions')
const deployLocks = require('../helpers/deployLocks')

const unlockContract = artifacts.require('Unlock.sol')
const TestEventHooks = artifacts.require('TestEventHooks.sol')
const getProxy = require('../helpers/proxy')

let lock
let locks
let unlock
let testEventHooks

contract('Lock / onKeyPurchaseHook', accounts => {
  const from = accounts[1]
  const to = accounts[2]
  const dataField = web3.utils.asciiToHex('TestData')
  let keyPrice

  before(async () => {
    unlock = await getProxy(unlockContract)
    locks = await deployLocks(unlock, accounts[0])
    lock = locks.FIRST
    testEventHooks = await TestEventHooks.new()
    await lock.setEventHooks(testEventHooks.address, constants.ZERO_ADDRESS)
    keyPrice = new BigNumber(await lock.keyPrice())
    await lock.purchase(0, to, constants.ZERO_ADDRESS, dataField, {
      from,
      value: keyPrice.toFixed(),
    })
  })

  it('key sales should log the hook event', async () => {
    const log = (await testEventHooks.getPastEvents('OnKeyPurchase'))[0]
      .returnValues
    assert.equal(log.lock, lock.address)
    assert.equal(log.from, from)
    assert.equal(log.to, to)
    assert.equal(log.referrer, web3.utils.padLeft(0, 40))
    assert.equal(log.keyPrice, keyPrice.toFixed())
    assert.equal(log.data, dataField)
  })

  it('Sanity check: cannot buy at half price', async () => {
    await reverts(
      lock.purchase(0, to, constants.ZERO_ADDRESS, dataField, {
        from,
        value: keyPrice.div(2).toFixed(),
      }),
      'NOT_ENOUGH_FUNDS'
    )
  })

  it('cannot set the hook to a non-contract address', async () => {
    await reverts(
      lock.setEventHooks(accounts[1], constants.ZERO_ADDRESS),
      'INVALID_ON_KEY_SOLD_HOOK'
    )
  })

  describe('with a 50% off discount', () => {
    beforeEach(async () => {
      await testEventHooks.setDiscount(keyPrice.div(2).toFixed())
    })

    it('can estimate the price', async () => {
      const price = await lock.purchasePriceFor(
        to,
        constants.ZERO_ADDRESS,
        dataField
      )
      assert.equal(price, keyPrice.div(2).toFixed())
    })

    it('can buy at half price', async () => {
      await lock.purchase(0, to, constants.ZERO_ADDRESS, dataField, {
        from,
        value: keyPrice.div(2).toFixed(),
      })
    })
  })

  describe('with a huge discount', () => {
    beforeEach(async () => {
      await testEventHooks.setDiscount(constants.MAX_UINT)
    })

    it('purchases are now free', async () => {
      await lock.purchase(0, to, constants.ZERO_ADDRESS, dataField, {
        from,
        value: '0',
      })
    })

    it('can still send tips', async () => {
      await lock.purchase(0, to, constants.ZERO_ADDRESS, dataField, {
        from,
        value: '42',
      })
    })
  })
})
