"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
exports.__esModule = true;
// export interface TxInDto extends TxIn<number> {}
var TxOut = /** @class */ (function () {
    function TxOut() {
        this.node_id = '0000000000000000000000000000000000000000000000000000000000000000';
    }
    return TxOut;
}());
exports.TxOut = TxOut;
var TransactionBase = /** @class */ (function () {
    function TransactionBase() {
        this.version = 1;
        this.lock_time = 0;
    }
    return TransactionBase;
}());
exports.TransactionBase = TransactionBase;
var TransactionDto = /** @class */ (function (_super) {
    __extends(TransactionDto, _super);
    function TransactionDto() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    return TransactionDto;
}(TransactionBase));
exports.TransactionDto = TransactionDto;
