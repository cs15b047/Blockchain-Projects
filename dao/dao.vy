from vyper.interfaces import ERC20

implements: ERC20

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

struct Proposal:
    recipient: address
    amount: uint256
    approvedStake: uint256
    numApprovedStakeholders: uint256
    approved: bool

approvers: public(HashMap[uint256, HashMap[address, bool]])
numStakeholders: public(uint256)

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)

# TODO add state that tracks proposals here
name: public(String[32])
symbol: public(String[32])
proposalIds: public(HashMap[uint256, Proposal])

@external
def __init__():
    self.totalSupply = 0
    self.balanceOf[msg.sender] = 0
    self.name = "myToken"
    self.symbol = "MTK"
    self.numStakeholders = 0

@external
@payable
@nonreentrant("lock")
def buyToken():
    self.totalSupply += msg.value

    if self.balanceOf[msg.sender] == 0:
        self.numStakeholders += 1
    self.balanceOf[msg.sender] += msg.value

@external
@nonpayable
@nonreentrant("lock")
def sellToken(_value: uint256):
    assert self.balanceOf[msg.sender] >= _value
    self.balanceOf[msg.sender] -= _value
    self.totalSupply -= _value

# TODO add other ERC20 methods here
@external
def transfer(_to: address, _value: uint256) -> bool:
    assert self.balanceOf[msg.sender] >= _value
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log Transfer(msg.sender, _to, _value)
    return True

@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    self.internalTransfer(_from, _to, _value)
    return True

@internal
def internalTransfer(_from: address, _to: address, _value: uint256):
    assert self.balanceOf[_from] >= _value
    # assert self.allowance[_from][msg.sender] >= _value
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value
    # self.allowance[_from][msg.sender] -= _value
    log Transfer(_from, _to, _value)

@external
def approve(_spender: address, _value: uint256) -> bool:
    self.allowance[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True

@internal
def proposalExists(_uid: uint256) -> bool:
    return (self.proposalIds[_uid].recipient != ZERO_ADDRESS)

@external
@nonpayable
@nonreentrant("lock")
def createProposal(_uid: uint256, _recipient: address, _amount: uint256):
    assert self.proposalExists(_uid) == False
    assert _amount > 0

    self.proposalIds[_uid] = Proposal({
        recipient: _recipient, amount: _amount, 
        approvedStake: 0, numApprovedStakeholders: 0, approved: False
    })

@external
@nonpayable
@nonreentrant("lock")
def approveProposal(_uid: uint256):
    assert (self.proposalExists(_uid) == True)
    assert (self.balanceOf[msg.sender] > 0)
    assert (self.approvers[_uid][msg.sender] == False)

    # Check if already approved
    if self.proposalIds[_uid].approved == True:
        return
    
    # Check if already approved by same approver

    self.proposalIds[_uid].approvedStake += self.balanceOf[msg.sender]
    self.proposalIds[_uid].numApprovedStakeholders += 1
    self.approvers[_uid][msg.sender] = True

    # Check if proposal has been approved: majority in stake
    if (self.proposalIds[_uid].approvedStake > self.totalSupply / 2):
        self.proposalIds[_uid].approved = True
        send(self.proposalIds[_uid].recipient, self.proposalIds[_uid].amount) # Send ether to recipient

