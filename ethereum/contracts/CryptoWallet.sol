pragma solidity ^0.4.23;

contract CryptoWallet {
    
    //Users with access to the wallet 
    mapping(address => bool) public _owners;
    
    //Transactions (based on index)
    mapping(uint256 => Transaction) public _transactions;
    
    //minimum signatures needed to sign transactions 
    uint256 public minimumSignatures;

    // transaction index
    uint256 public _transactionIndex;
    
    // list of pending transactions
    uint256[] public _pendingTransactions;

    struct Transaction {
        address recipient;
        uint256 amount;
        string description;
        uint256 creationDate;
        uint8 signatureCount;
        mapping(address => uint8) signatures;
    }
    
    event Deposit(address from, uint256 amount);
    event Withdraw(address to, uint256 amount);
    event DeleteUser(address removedUser);
    event TransactionCreated(address from, address to, uint256 amount, uint256 transaction);
    event TransactionCompleted(address to, uint256 amount, uint256 transaction);
    event TransactionSigned(address by, uint transactionIndex);
    
    constructor(uint256 minSig) public {
        _owners[msg.sender] = true;
        minimumSignatures = minSig;
    }
    
    modifier isOwner() {
        require(_owners[msg.sender] == true);
        _;
    }
    
    // [deposit] adds [amount] to balance.
    function deposit(uint256 amount) isOwner payable public{
        require(msg.value == amount);
        
        emit Deposit(msg.sender, msg.value);
    }
    
    // [withdraw] sends the user [amount].
    function withdraw(uint amount) isOwner public {
        require(address(this).balance >= amount);
        
        msg.sender.transfer(amount);
        
        emit Withdraw(msg.sender, amount);
    }
    
    // [transferTo] sends [amount] to recipient [to].
    function transferTo(address to, uint amount, string des) isOwner public {
        require(address(this).balance >= amount);
        
        // initiate transaction
        uint transactionId = _transactionIndex++;
        Transaction memory transaction;
        transaction.recipient = to;
        transaction.amount = amount;
        transaction.description = des;
        transaction.creationDate = now;
        transaction.signatureCount = 0;
        
        _transactions[transactionId] = transaction;
        _pendingTransactions.push(transactionId);

        emit TransactionCreated(msg.sender, to, amount, transactionId);
    }
    
    /* [getPendingTransaction] returns all the transactions that have not been
       signed. */
    function getPendingTransaction() isOwner public view returns(uint[]) {
        return _pendingTransactions;
    }
    
    // [signTransaction] verifies transaction is valid by owners of wallet.
    function signTransaction(uint transactionId) isOwner public {

        Transaction storage transaction = _transactions[transactionId];

        // Transaction can only be signed once by signer
        require(transaction.signatures[msg.sender] != 1);

        transaction.signatures[msg.sender] = 1;
        transaction.signatureCount++;

        emit TransactionSigned(msg.sender, transactionId);

        if (transaction.signatureCount >= minimumSignatures) {
            require(address(this).balance >= transaction.amount);
            
            transaction.recipient.transfer(transaction.amount);
            
            emit TransactionCompleted(transaction.recipient, transaction.amount, transactionId);
            deleteTransaction(transactionId);
        }
    }
    
    // [deleteTransaction] deletes completed transaction.
    function deleteTransaction(uint transactionId) isOwner public {
        uint8 replace = 0;
        
        for(uint i = 0; i < _pendingTransactions.length; i++) {
            if(1 == replace) {
                _pendingTransactions[i-1] = _pendingTransactions[i];
            } else if(transactionId == _pendingTransactions[i]) {
                replace = 1;
            }
        }
        
        delete _pendingTransactions[_pendingTransactions.length - 1];
        _pendingTransactions.length--;
        delete _transactions[transactionId];
    } 
    
    function() payable public {}
    
    // [transactionInfo] returns the information related to the transaction.
    function transactionInfo(uint256 transactionId) public view returns(address, uint256, string, uint256) {
        Transaction storage transaction = _transactions[transactionId];

        return (transaction.recipient, transaction.amount, 
        transaction.description, transaction.creationDate);
    }
    
    // [walletBalance] is the total balance in the wallet.
    function walletBalance() view public returns(uint) {
        return address(this).balance;
    } 
    
}