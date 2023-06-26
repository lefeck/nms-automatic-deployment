
#ClickHouse v23.2.4.12 can't start by systemctl on CentOS 7.9

## Installation type
The os version is CentOS 7.9
Install clickhouse 23.2.4.12 by use yum install -y clickhouse-server clickhouse-client

## The actual result
After install, I run systemctl start clickhouse-server to start clickhouse server, but failed;

# method 
Then you modify /usr/lib/systemd/system/clickhouse-server.service  TimeoutStartSec=infinity with TimeoutStartSec=0, clickhouse server start successfully.

replace
```shell
TimeoutStartSec=infinity
```
to
```shell
TimeoutStartSec=0
```

## reference

[Clickhouse48090](https://github.com/ClickHouse/ClickHouse/issues/48090)

fixed [ClickHouse47689](https://github.com/ClickHouse/ClickHouse/pull/47689/files)