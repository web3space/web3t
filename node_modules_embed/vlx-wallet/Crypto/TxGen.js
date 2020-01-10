"use strict";
exports.__esModule = true;
var Transaction_1 = require("./Transaction");
var default_1 = /** @class */ (function () {
    function default_1(sodium) {
        var _this = this;
        this.generate = function (unspents, amount, velasKey, changeAddress, to, commission) {
            return new Transaction_1["default"](_this.sodium, unspents, amount, velasKey, changeAddress, to, commission);
        };
        this.sodium = sodium;
    }
    return default_1;
}());
exports["default"] = default_1;
