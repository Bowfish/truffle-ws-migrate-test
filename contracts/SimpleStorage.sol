pragma solidity >=0.4.21 <0.6.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * @author Zeppelin
 */

contract Ownable {

  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev revert()s if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 * @author Zeppelin
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract Mortal is Ownable {

	function kill() onlyOwner public {
		selfdestruct(msg.sender);
	}
}

contract Administrable is Ownable {

	mapping (address => bool) public Administrators;
	event AdministratorChanged(address indexed affectedAddress,bool isAdminStatus);

	/**
	* @dev The Administrable constructor sets the first Administrator to the Owner
	* of the contract
	*/
	constructor() public {
		Administrators[owner]=true;
	}

	/**
	* @dev revert()s if called by any account other than an Admin.
	*/
	modifier onlyAdmin() {
		require(Administrators[msg.sender] == true);
		_;
	}

	function isAdmin(address _address) public view returns(bool) {
		return Administrators[_address];
	}

	/**
	* @dev Allows the current owner to add a new Administrator
	* @param _newAdmin The address to grant Admin rights to.
	*/
	function grantAdmin(address _newAdmin) public onlyOwner {
		require(_newAdmin != address(0) && Administrators[_newAdmin]==false);
		emit AdministratorChanged(_newAdmin, true);
		Administrators[_newAdmin] = true;
	}

	/**
	* @dev Allows the current owner to remove an existing Administrator
	* @param _previousAdmin The address to revoke Admin rights from.
	*/
	function revokeAdmin(address _previousAdmin) public onlyOwner {
		require(_previousAdmin != address(0) && Administrators[_previousAdmin]==true);
		emit AdministratorChanged(_previousAdmin, false);
		Administrators[_previousAdmin] = false;
	}
}

/**
 * @title PoaProposals Contract
 * @dev handels the proposals of the POA chain
 * @author CoreLedger
 */
 /*
contract SimpleStorage is Mortal, Pausable, Administrable {

  uint storedData;

  function set(uint x) public {
    storedData = x;
  }

  function get() public view returns (uint) {
    return storedData;
  }
}
*/
contract SimpleStorage is Mortal, Pausable, Administrable {

	struct ProposalStruct {
    uint proposalIndex;
		bytes32 hash;
		address topic;
		address sender;
    bool status;
	}

	mapping (address => ProposalStruct) public proposals;
  address[] private proposalIds;    // all proposals

	string public ContractName;      //General purpose name
	string public ContractVersion;   //General purpose version

  event LogPoaCreateProposal(address indexed proposalId, bool indexed status, bytes32 hash, address topic, address sender);
  event LogPoaSetStatus(address indexed proposalId, bool indexed status);
  event LogPoaSetHash(address indexed proposalId, bytes32 hash);
  event LogPoaDeleteProposal(address indexed proposalId);

	constructor() public {
		ContractName = "POA Proposals";
		ContractVersion = "0.1";
	}

  function isProposal(address _proposalId) view public returns(bool isIdeed) {
    if (proposalIds.length == 0) return false;
    return(proposalIds[proposals[_proposalId].proposalIndex] == _proposalId);
  }

  function createProposal(address _proposalId) public {
		require(_proposalId != address(0), "Invalid Proposal Id");
    proposals[_proposalId].proposalIndex = proposalIds.push(_proposalId) - 1;
    proposals[_proposalId].hash = keccak256(abi.encodePacked(_proposalId, msg.sender, block.number));
    proposals[_proposalId].topic = _proposalId;
    proposals[_proposalId].sender = msg.sender;
    proposals[_proposalId].status = true;

    emit LogPoaCreateProposal(
      _proposalId,
      proposals[_proposalId].status,
      proposals[_proposalId].hash,
      proposals[_proposalId].topic,
      proposals[_proposalId].sender
    );

    emit LogPoaSetStatus(
      _proposalId,
      proposals[_proposalId].status
    );
  }

  function setStatus(address _proposalId, bool _status) public {
		require(_proposalId != address(0), "setStatus: Invalid Proposal Idi, Proposal does not exist");
    proposals[_proposalId].status = _status;
    emit LogPoaSetStatus(
      _proposalId,
      proposals[_proposalId].status
    );
  }

  function setHash(address _proposalId, bytes32 _hash) public {
		require(_proposalId != address(0), "setHash: Invalid Proposal Idi, Proposal does not exist");
    proposals[_proposalId].hash = _hash;
    emit LogPoaSetHash(
      _proposalId,
      proposals[_proposalId].hash
    );
  }

  function proposalsCount() public view returns(uint count) {
    return proposalIds.length;
  }

  function getProposalIds() public view returns(address[] memory) {
    return proposalIds;
  }

  function getProposalIdAtIndex(uint _index) public view returns(address proposalId){
    return(proposalIds[_index]);
  }

  //* Uncommen this and then the migration will fail
  /*
  function getProposal(address _proposalId) public view returns(uint index, bytes32 hash, address topic, address sender, bool status) {
    require(isProposal(_proposalId), "getProposal: Invalid Proposal Id. Proposal does not exist");
    return (
      proposals[_proposalId].proposalIndex,
      proposals[_proposalId].hash,
      proposals[_proposalId].topic,
      proposals[_proposalId].sender,
      proposals[_proposalId].status
    );
  }

  function deleteProposal(address _proposalId) public {
    require(isProposal(_proposalId), "deleteProposal: Invalid Proposal Id. Proposal does not exist");
    uint rowToDelete = proposals[_proposalId].proposalIndex;
    address keyToMove = proposalIds[proposalIds.length - 1];
    proposalIds[rowToDelete] = keyToMove;
    proposals[keyToMove].proposalIndex = rowToDelete;
    proposalIds.length--;
    emit LogPoaDeleteProposal(_proposalId);
  }
  */

}
