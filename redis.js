const redis = require('ioredis');
const Promise = require('bluebird');

const cluster = new redis.Cluster([
  { host: 'redis1', port: 6379 },
  { host: 'redis2', port: 6379 },
  { host: 'redis3', port: 6379 },
  { host: 'redis4', port: 6379 },
  { host: 'redis5', port: 6379 },
  { host: 'redis6', port: 6379 },
], {});

(async () => {
  while (true) {
    console.log("req")
    const val = await cluster.get('key');
    console.log(val);
    await Promise.delay(1000);
  }
})();
