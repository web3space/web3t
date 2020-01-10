import * as libsodium from 'libsodium-wrappers-sumo';
import KeysGen from "./KeysGen";
import TxGen from "./TxGen";

export default class VelasCrypto {
	public keysGen: KeysGen;
	public tx: TxGen;

	constructor(sodium) {
		this.keysGen = new KeysGen(sodium);
		this.tx = new TxGen(sodium);
	}

	public static init = async (): Promise<VelasCrypto> => {
		await libsodium.ready;
		return new VelasCrypto(libsodium);
	};
}