interface BalanceRequest {
    //Definition in coin-interface.ts
    network: Network; 
    address: number;
}

interface PushTxRequest {
    //Definition in coin-interface.ts
    network: Network;
    //Signed Transaction
    rawtx: number;
}

interface TransactionRequest {
    network: Network;
    sender: number; 
    recepient: number;
    amount: number; 
    amountFee: number; 
    data: number;
}

interface Protocol {
    //Get Current Balance from FullNode
    getBalance(request: BalanceRequest, callback: Function): void;
    //Notify FullNode about new signed transaction
    pushTx(request: PushTxRequest, callback: Function): void;
    //verify encoded transaction for data. Mostly for Smart Contract Systems
    checkDecodedData(decoded-data: string, data: number): bool;
    //Create new signed transaction
    createTransaction(request: TransactionRequest, callback: Function): void;
    //Get transaction history
    getTransactions(request: BalanceRequest, callback: Function ): void;
}