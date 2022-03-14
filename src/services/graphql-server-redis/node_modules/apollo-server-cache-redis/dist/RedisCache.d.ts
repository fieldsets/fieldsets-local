import { TestableKeyValueCache } from 'apollo-server-caching';
import { RedisOptions } from 'ioredis';
export declare class RedisCache implements TestableKeyValueCache<string> {
    readonly client: any;
    readonly defaultSetOptions: {
        ttl: number;
    };
    private loader;
    constructor(options?: RedisOptions);
    set(key: string, value: string, options?: {
        ttl?: number;
    }): Promise<void>;
    get(key: string): Promise<string | undefined>;
    delete(key: string): Promise<boolean>;
    flush(): Promise<void>;
    close(): Promise<void>;
}
//# sourceMappingURL=RedisCache.d.ts.map