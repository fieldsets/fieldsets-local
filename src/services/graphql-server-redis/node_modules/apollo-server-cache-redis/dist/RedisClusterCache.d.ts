import { KeyValueCache } from 'apollo-server-caching';
import { ClusterOptions, ClusterNode } from 'ioredis';
export declare class RedisClusterCache implements KeyValueCache {
    readonly client: any;
    readonly defaultSetOptions: {
        ttl: number;
    };
    private loader;
    constructor(nodes: ClusterNode[], options?: ClusterOptions);
    set(key: string, data: string, options?: {
        ttl?: number;
    }): Promise<void>;
    get(key: string): Promise<string | undefined>;
    delete(key: string): Promise<boolean>;
    flush(): Promise<void>;
    close(): Promise<void>;
}
//# sourceMappingURL=RedisClusterCache.d.ts.map