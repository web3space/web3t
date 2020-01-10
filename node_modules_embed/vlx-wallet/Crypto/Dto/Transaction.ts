export interface Out<T> {
  hash: string;
  index: number;
  value: T;
}

export interface TxIn<T> {
  signature_script: string;
  public_key: string;
  previous_output: Out<T>;
  sequence: number;
  wallet_address: string;
}

// export interface TxInDto extends TxIn<number> {}

export class TxOut<T> {
  pk_script: string;
  node_id = '0000000000000000000000000000000000000000000000000000000000000000';
  payload: object;
  value: T;
  index: number;
  wallet_address?: string;
}

export class TransactionBase<T>{
  hash: string;
  version = 1;
  lock_time = 0;
  tx_in: TxIn<T>[];
  tx_out: TxOut<T>[];
}

export class TransactionDto extends TransactionBase<number> {}
