"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ioredis_1 = __importDefault(require("ioredis"));
const dataloader_1 = __importDefault(require("dataloader"));
class RedisClusterCache {
    constructor(nodes, options) {
        this.defaultSetOptions = {
            ttl: 300,
        };
        this.client = new ioredis_1.default.Cluster(nodes, options);
        this.loader = new dataloader_1.default((keys = []) => Promise.all(keys.map(key => this.client.get(key).catch(() => null))), { cache: false });
    }
    set(key, data, options) {
        return __awaiter(this, void 0, void 0, function* () {
            const { ttl } = Object.assign({}, this.defaultSetOptions, options);
            yield this.client.set(key, data, 'EX', ttl);
        });
    }
    get(key) {
        return __awaiter(this, void 0, void 0, function* () {
            const reply = yield this.loader.load(key);
            if (reply !== null) {
                return reply;
            }
            return;
        });
    }
    delete(key) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield this.client.del(key);
        });
    }
    flush() {
        return __awaiter(this, void 0, void 0, function* () {
            const masters = this.client.nodes('master') || [];
            yield Promise.all(masters.map((node) => node.flushdb()));
        });
    }
    close() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.client.quit();
            return;
        });
    }
}
exports.RedisClusterCache = RedisClusterCache;
//# sourceMappingURL=RedisClusterCache.js.map